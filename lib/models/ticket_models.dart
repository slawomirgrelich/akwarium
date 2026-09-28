import 'package:cloud_firestore/cloud_firestore.dart';

enum TicketCategory {
  bug,
  feature,
  subscription,
  business,
  other;

  String get firestoreValue => name;

  String get label {
    switch (this) {
      case TicketCategory.bug:
        return 'Zgłoś błąd w aplikacji';
      case TicketCategory.feature:
        return 'Propozycja funkcji / pomysł';
      case TicketCategory.subscription:
        return 'Problem z płatnością / subskrypcją PRO';
      case TicketCategory.business:
        return 'Współpraca / kontakt biznesowy';
      case TicketCategory.other:
        return 'Inne zapytanie';
    }
  }

  String get shortLabel {
    switch (this) {
      case TicketCategory.bug:
        return 'Błąd aplikacji';
      case TicketCategory.feature:
        return 'Pomysł';
      case TicketCategory.subscription:
        return 'Płatność / PRO';
      case TicketCategory.business:
        return 'Współpraca';
      case TicketCategory.other:
        return 'Inne';
    }
  }

  String get emoji {
    switch (this) {
      case TicketCategory.bug:
        return '🐛';
      case TicketCategory.feature:
        return '💡';
      case TicketCategory.subscription:
        return '💳';
      case TicketCategory.business:
        return '🤝';
      case TicketCategory.other:
        return '❓';
    }
  }

  static TicketCategory fromValue(String? value) {
    return TicketCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => TicketCategory.other,
    );
  }
}

enum TicketStatus {
  open,
  inProgress,
  resolved,
  closed;

  String get firestoreValue {
    switch (this) {
      case TicketStatus.open:
        return 'OPEN';
      case TicketStatus.inProgress:
        return 'IN_PROGRESS';
      case TicketStatus.resolved:
        return 'RESOLVED';
      case TicketStatus.closed:
        return 'CLOSED';
    }
  }

  String get label {
    switch (this) {
      case TicketStatus.open:
        return 'Otwarty';
      case TicketStatus.inProgress:
        return 'W trakcie';
      case TicketStatus.resolved:
        return 'Rozwiązane';
      case TicketStatus.closed:
        return 'Zamknięte';
    }
  }

  static TicketStatus fromValue(String? value) {
    switch (value) {
      case 'IN_PROGRESS':
        return TicketStatus.inProgress;
      case 'RESOLVED':
        return TicketStatus.resolved;
      case 'CLOSED':
        return TicketStatus.closed;
      default:
        return TicketStatus.open;
    }
  }
}

class TicketModel {
  const TicketModel({
    required this.ticketId,
    required this.userId,
    required this.userEmail,
    required this.category,
    required this.subject,
    required this.description,
    required this.status,
    required this.deviceInfo,
    required this.createdAt,
    required this.updatedAt,
    this.adminResponse,
  });

  final String ticketId;
  final String userId;
  final String userEmail;
  final TicketCategory category;
  final String subject;
  final String description;
  final TicketStatus status;
  final Map<String, String> deviceInfo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? adminResponse;

  factory TicketModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    final rawDeviceInfo = data['deviceInfo'] as Map<String, dynamic>?;
    return TicketModel(
      ticketId: data['ticketId'] as String? ?? document.id,
      userId: data['userId'] as String? ?? '',
      userEmail: data['userEmail'] as String? ?? '',
      category: TicketCategory.fromValue(data['category'] as String?),
      subject: data['subject'] as String? ?? '',
      description: data['description'] as String? ?? '',
      status: TicketStatus.fromValue(data['status'] as String?),
      deviceInfo: rawDeviceInfo == null
          ? const <String, String>{}
          : rawDeviceInfo.map(
              (key, value) => MapEntry(key, value?.toString() ?? ''),
            ),
      createdAt: _dateFromValue(data['createdAt']) ?? DateTime.now().toUtc(),
      updatedAt: _dateFromValue(data['updatedAt']) ?? DateTime.now().toUtc(),
      adminResponse: data['adminResponse'] as String?,
    );
  }
}

DateTime? _dateFromValue(dynamic value) {
  if (value is Timestamp) return value.toDate().toLocal();
  if (value is DateTime) return value.toLocal();
  return null;
}
