import 'package:cloud_firestore/cloud_firestore.dart';

class ReferralModel {
  const ReferralModel({
    required this.id,
    required this.referrerId,
    required this.referredUserId,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  final String id;
  final String referrerId;
  final String referredUserId;
  final ReferralStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  factory ReferralModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    return ReferralModel(
      id: document.id,
      referrerId: data['referrerId'] as String? ?? '',
      referredUserId: data['referredUserId'] as String? ?? '',
      status: ReferralStatus.fromValue(data['status'] as String?),
      createdAt: _dateFromValue(data['createdAt']) ?? DateTime.now().toUtc(),
      completedAt: _dateFromValue(data['completedAt']),
    );
  }
}

enum ReferralStatus {
  pending,
  completed;

  static ReferralStatus fromValue(String? value) =>
      value == 'completed' ? ReferralStatus.completed : ReferralStatus.pending;

  String get firestoreValue => name;
}

class ReferralCodeValidation {
  const ReferralCodeValidation({
    required this.isValid,
    this.message,
  });

  final bool isValid;
  final String? message;
}

DateTime? _dateFromValue(dynamic value) {
  if (value is Timestamp) return value.toDate().toUtc();
  if (value is DateTime) return value.toUtc();
  return null;
}
