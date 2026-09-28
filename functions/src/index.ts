import { randomBytes } from 'node:crypto';
import { initializeApp } from 'firebase-admin/app';
import { FieldValue, getFirestore, Timestamp } from 'firebase-admin/firestore';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { auth } from 'firebase-functions/v1';

initializeApp();
const db = getFirestore();
const MAX_REFERRALS_PER_REWARD = 3;
const CODE_LENGTH = 8;
const REFERRAL_CODE_PATTERN = /^[A-Z0-9-]{6,20}$/;

function requireAuth(request: Parameters<typeof onCall>[0] extends never ? never : any) {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Authentication required.');
  return request.auth.uid;
}

function normalizeCode(value: unknown): string {
  return typeof value === 'string' ? value.trim().toUpperCase() : '';
}

function isValidReferralCode(code: string): boolean {
  return REFERRAL_CODE_PATTERN.test(code);
}

function makeCode(): string {
  return randomBytes(8).toString('hex').slice(0, CODE_LENGTH).toUpperCase();
}

async function createUniqueCode(): Promise<string> {
  for (let attempt = 0; attempt < 5; attempt += 1) {
    const code = makeCode();
    const ref = db.collection('referral_codes').doc(code);
    if (!(await ref.get()).exists) return code;
  }
  throw new HttpsError('resource-exhausted', 'Could not allocate referral code.');
}

export const onAuthUserCreated = auth.user().onCreate(async (user) => {
  const uid = user.uid;
  const userRef = db.collection('users').doc(uid);
  const current = await userRef.get();
  if (current.exists && current.get('referralCode')) return;

  const code = await createUniqueCode();
  await db.runTransaction(async (transaction) => {
    const freshUser = await transaction.get(userRef);
    if (freshUser.exists && freshUser.get('referralCode')) return;
    transaction.set(userRef, {
      uid,
      email: user.email ?? null,
      referralCode: code,
      successfulReferralsCount: 0,
      isPro: freshUser.get('isPro') === true,
      subscriptionStatus: freshUser.get('subscriptionStatus') ?? 'free',
      createdAt: freshUser.get('createdAt') ?? FieldValue.serverTimestamp(),
    }, { merge: true });
    transaction.create(db.collection('referral_codes').doc(code), {
      ownerId: uid,
      createdAt: FieldValue.serverTimestamp(),
    });
  });
});

export const ensureReferralCode = onCall(async (request) => {
  const uid = requireAuth(request);
  const userRef = db.collection('users').doc(uid);
  const current = await userRef.get();
  const existing = current.get('referralCode');
  if (typeof existing === 'string' && existing.length > 0) {
    return { referralCode: existing };
  }

  const requestedCode = normalizeCode(request.data?.fallbackCode);
  const requestedReference = requestedCode
    ? db.collection('referral_codes').doc(requestedCode)
    : null;
  const requestedExists = requestedReference
    ? (await requestedReference.get()).exists
    : true;
  const code = isValidReferralCode(requestedCode) && !requestedExists
    ? requestedCode
    : await createUniqueCode();
  await db.runTransaction(async (transaction) => {
    const freshUser = await transaction.get(userRef);
    const freshCode = freshUser.get('referralCode');
    if (typeof freshCode === 'string' && freshCode.length > 0) return;
    transaction.set(userRef, {
      referralCode: code,
      successfulReferralsCount: freshUser.get('successfulReferralsCount') ?? 0,
    }, { merge: true });
    transaction.create(db.collection('referral_codes').doc(code), {
      ownerId: uid,
      createdAt: FieldValue.serverTimestamp(),
    });
  });
  const updated = await userRef.get();
  return { referralCode: updated.get('referralCode') ?? code };
});

export const validateReferralCode = onCall(async (request) => {
  const code = normalizeCode(request.data?.code);
  if (!isValidReferralCode(code)) return { valid: false };
  const codeDocument = await db.collection('referral_codes').doc(code).get();
  if (!codeDocument.exists) return { valid: false };
  if (request.auth && codeDocument.get('ownerId') === request.auth.uid) {
    return { valid: false, reason: 'self-referral' };
  }
  return { valid: true };
});

export const applyReferralCode = onCall(async (request) => {
  const uid = requireAuth(request);
  const code = normalizeCode(request.data?.code);
  const deviceId = typeof request.data?.deviceId === 'string'
    ? request.data.deviceId.trim()
    : '';
  if (!isValidReferralCode(code) || !deviceId || deviceId.length > 512) {
    throw new HttpsError('invalid-argument', 'Invalid referral data.');
  }

  const userRef = db.collection('users').doc(uid);
  const codeRef = db.collection('referral_codes').doc(code);
  const deviceRef = db.collection('used_devices').doc(deviceId);
  const referralRef = db.collection('referrals').doc(uid);

  await db.runTransaction(async (transaction) => {
    const [user, codeDocument, device, existingReferral] = await Promise.all([
      transaction.get(userRef),
      transaction.get(codeRef),
      transaction.get(deviceRef),
      transaction.get(referralRef),
    ]);
    if (!codeDocument.exists) throw new HttpsError('not-found', 'invalid-referral-code');
    const referrerId = codeDocument.get('ownerId') as string;
    if (referrerId === uid) throw new HttpsError('failed-precondition', 'self-referral');
    if (device.exists) throw new HttpsError('already-exists', 'already-used-device');
    if (existingReferral.exists || user.get('referredBy')) {
      throw new HttpsError('already-exists', 'already-referred');
    }

    transaction.create(deviceRef, { userId: uid, usedAt: FieldValue.serverTimestamp() });
    transaction.create(referralRef, {
      referrerId,
      referredUserId: uid,
      deviceId,
      status: 'pending',
      createdAt: FieldValue.serverTimestamp(),
    });
    transaction.set(userRef, { referredBy: referrerId, referralCodeUsed: code }, { merge: true });
  });
  return { applied: true };
});

export const completeReferral = onCall(async (request) => {
  const uid = requireAuth(request);
  if (request.auth?.token.email_verified !== true) {
    throw new HttpsError('failed-precondition', 'email-not-verified');
  }

  const referredUserRef = db.collection('users').doc(uid);
  const referralRef = db.collection('referrals').doc(uid);
  await db.runTransaction(async (transaction) => {
    const referral = await transaction.get(referralRef);
    if (!referral.exists || referral.get('status') === 'completed') return;
    const referrerId = referral.get('referrerId') as string;
    const referrerRef = db.collection('users').doc(referrerId);
    const referrer = await transaction.get(referrerRef);
    const count = Math.min(
      Number(referrer.get('successfulReferralsCount') ?? 0),
      MAX_REFERRALS_PER_REWARD,
    );
    const nextCount = count + 1;
    transaction.update(referralRef, {
      status: 'completed',
      completedAt: FieldValue.serverTimestamp(),
    });
    if (nextCount >= MAX_REFERRALS_PER_REWARD) {
      const currentExpiry = referrer.get('proExpirationDate') as Timestamp | undefined;
      const base = currentExpiry && currentExpiry.toDate() > new Date()
        ? currentExpiry.toDate()
        : new Date();
      base.setUTCDate(base.getUTCDate() + 30);
      transaction.update(referrerRef, {
        successfulReferralsCount: 0,
        isPro: true,
        subscriptionStatus: 'referral_reward',
        proExpirationDate: Timestamp.fromDate(base),
      });
    } else {
      transaction.update(referrerRef, { successfulReferralsCount: nextCount });
    }
    transaction.set(referredUserRef, { referralCompletedAt: FieldValue.serverTimestamp() }, { merge: true });
  });
  return { completed: true };
});
