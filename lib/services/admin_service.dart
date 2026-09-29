import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/ticket_models.dart';

class AdminService {
  AdminService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<bool> watchAdminAccess(String userId) => _firestore
      .collection('users')
      .doc(userId)
      .snapshots()
      .map((snapshot) => _isAdmin(snapshot.data()));

  Future<bool> isCurrentUserAdmin() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;
    try {
      final document = await _firestore.collection('users').doc(userId).get();
      return _isAdmin(document.data());
    } on Object catch (error) {
      debugPrint('Admin access check failed: $error');
      return false;
    }
  }

  Future<AdminOverview> loadOverview() async {
    await _requireAdmin();
    final results = await Future.wait([
      _firestore.collection('users').get(),
      _firestore.collection('tickets').count().get(),
      _firestore
          .collection('tickets')
          .where('status', whereIn: ['OPEN', 'IN_PROGRESS'])
          .count()
          .get(),
      _firestore
          .collection('referrals')
          .where('status', isEqualTo: 'completed')
          .count()
          .get(),
    ]);
    final users = results[0] as QuerySnapshot<Map<String, dynamic>>;
    final totalTickets = results[1] as AggregateQuerySnapshot;
    final openTickets = results[2] as AggregateQuerySnapshot;
    final successfulReferrals = results[3] as AggregateQuerySnapshot;
    final now = DateTime.now();
    var activePro = 0;
    var monthlyPlans = 0;
    var yearlyPlans = 0;
    var manualGrants = 0;

    for (final document in users.docs) {
      final user = AdminUserRecord.fromDocument(document);
      if (!user.isProActiveAt(now)) continue;
      activePro++;
      final plan = user.subscriptionPlan.toLowerCase();
      if (user.isManualGrant) {
        manualGrants++;
      } else if (plan.contains('month')) {
        monthlyPlans++;
      } else if (plan.contains('year') || plan.contains('annual')) {
        yearlyPlans++;
      }
    }

    return AdminOverview(
      totalUsers: users.size,
      activePro: activePro,
      monthlyPlans: monthlyPlans,
      yearlyPlans: yearlyPlans,
      manualGrants: manualGrants,
      totalTickets: totalTickets.count ?? 0,
      openTickets: openTickets.count ?? 0,
      successfulReferrals: successfulReferrals.count ?? 0,
    );
  }

  Stream<List<TicketModel>> watchTickets() => _firestore
      .collection('tickets')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(TicketModel.fromDocument).toList());

  Future<void> updateTicket({
    required String ticketId,
    required TicketStatus status,
    required String adminResponse,
  }) async {
    await _requireAdmin();
    await _firestore.collection('tickets').doc(ticketId).update({
      'adminResponse': adminResponse.trim(),
      'status': status.firestoreValue,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<AdminUserRecord>> loadUsers() async {
    await _requireAdmin();
    final snapshot = await _firestore.collection('users').get();
    final users = snapshot.docs.map(AdminUserRecord.fromDocument).toList();
    users.sort((first, second) {
      final nameOrder = first.displayName.toLowerCase().compareTo(
        second.displayName.toLowerCase(),
      );
      return nameOrder == 0
          ? first.email.toLowerCase().compareTo(second.email.toLowerCase())
          : nameOrder;
    });
    return users;
  }

  Future<List<AdminInvitedUser>> loadInvitedUsers(String referrerId) async {
    await _requireAdmin();
    final referrals = await _firestore
        .collection('referrals')
        .where('referrerId', isEqualTo: referrerId)
        .get();
    final invited = await Future.wait(
      referrals.docs.map((referral) async {
        final data = referral.data();
        final userId = data['referredUserId'] as String? ?? '';
        final userDocument = userId.isEmpty
            ? null
            : await _firestore.collection('users').doc(userId).get();
        final userData = userDocument?.data() ?? const <String, dynamic>{};
        return AdminInvitedUser(
          userId: userId,
          email: userData['email'] as String? ?? '',
          displayName:
              userData['displayName'] as String? ??
              userData['name'] as String? ??
              '',
          isCompleted: data['status'] == 'completed',
        );
      }),
    );
    invited.sort((first, second) {
      final firstName = first.displayName.isNotEmpty
          ? first.displayName
          : first.email;
      final secondName = second.displayName.isNotEmpty
          ? second.displayName
          : second.email;
      return firstName.toLowerCase().compareTo(secondName.toLowerCase());
    });
    return invited;
  }

  Future<void> grantPro({
    required String userId,
    required DateTime? expiresAt,
  }) async {
    final adminId = await _requireAdmin();
    await _firestore.collection('users').doc(userId).set({
      'isPro': true,
      'subscriptionStatus': 'pro',
      'subscriptionPlan': 'manual',
      'adminGrantedPro': true,
      'adminGrantedBy': adminId,
      'adminGrantedAt': FieldValue.serverTimestamp(),
      if (expiresAt == null) 'proExpiryDate': FieldValue.delete(),
      if (expiresAt != null) 'proExpiryDate': Timestamp.fromDate(expiresAt),
    }, SetOptions(merge: true));
  }

  Future<void> revokePro(String userId) async {
    await _requireAdmin();
    await _firestore.collection('users').doc(userId).set({
      'isPro': false,
      'subscriptionStatus': 'free',
      'subscriptionPlan': FieldValue.delete(),
      'proExpiryDate': FieldValue.delete(),
      'adminGrantedPro': FieldValue.delete(),
      'adminGrantedBy': FieldValue.delete(),
      'adminGrantedAt': FieldValue.delete(),
    }, SetOptions(merge: true));
  }

  Future<String> _requireAdmin() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw const AdminAccessException();
    final document = await _firestore.collection('users').doc(userId).get();
    if (!_isAdmin(document.data())) throw const AdminAccessException();
    return userId;
  }

  bool _isAdmin(Map<String, dynamic>? data) =>
      data?['isAdmin'] == true || data?['role'] == 'admin';
}

class AdminAccessException implements Exception {
  const AdminAccessException();
}

class AdminOverview {
  const AdminOverview({
    required this.totalUsers,
    required this.activePro,
    required this.monthlyPlans,
    required this.yearlyPlans,
    required this.manualGrants,
    required this.totalTickets,
    required this.openTickets,
    required this.successfulReferrals,
  });

  final int totalUsers;
  final int activePro;
  final int monthlyPlans;
  final int yearlyPlans;
  final int manualGrants;
  final int totalTickets;
  final int openTickets;
  final int successfulReferrals;
}

class AdminUserRecord {
  const AdminUserRecord({
    required this.id,
    required this.email,
    required this.displayName,
    required this.isPro,
    required this.subscriptionPlan,
    required this.proExpiryDate,
    required this.successfulReferralsCount,
    required this.adminGrantedPro,
  });

  final String id;
  final String email;
  final String displayName;
  final bool isPro;
  final String subscriptionPlan;
  final DateTime? proExpiryDate;
  final int successfulReferralsCount;
  final bool adminGrantedPro;

  bool get isManualGrant =>
      subscriptionPlan.toLowerCase() == 'manual' ||
      subscriptionPlan.toLowerCase() == 'admin' ||
      adminGrantedPro;

  bool isProActiveAt(DateTime now) =>
      isPro && (proExpiryDate == null || proExpiryDate!.isAfter(now));

  factory AdminUserRecord.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    return AdminUserRecord(
      id: document.id,
      email: data['email'] as String? ?? '',
      displayName:
          data['displayName'] as String? ?? data['name'] as String? ?? '',
      isPro: data['isPro'] == true,
      subscriptionPlan: data['subscriptionPlan'] as String? ?? '',
      proExpiryDate: _dateFromValue(data['proExpiryDate']),
      successfulReferralsCount:
          (data['successfulReferralsCount'] as num?)?.toInt() ?? 0,
      adminGrantedPro: data['adminGrantedPro'] == true,
    );
  }
}

class AdminInvitedUser {
  const AdminInvitedUser({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.isCompleted,
  });

  final String userId;
  final String email;
  final String displayName;
  final bool isCompleted;
}

DateTime? _dateFromValue(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}
