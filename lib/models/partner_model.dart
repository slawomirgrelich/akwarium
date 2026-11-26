import 'package:cloud_firestore/cloud_firestore.dart';

enum PartnerCategory { creator, shop, breeder, unknown }

enum PartnerFilter { all, creators, shops }

List<Partner> filterPartners(
  Iterable<Partner> partners,
  PartnerFilter filter,
) {
  return partners.where((partner) {
    return switch (filter) {
      PartnerFilter.all => true,
      PartnerFilter.creators => partner.category == PartnerCategory.creator,
      PartnerFilter.shops => partner.category == PartnerCategory.shop,
    };
  }).toList(growable: false);
}

class Partner {
  const Partner({
    required this.id,
    required this.name,
    required this.category,
    required this.subtitle,
    required this.description,
    required this.url,
    required this.promoCode,
    required this.promoText,
    required this.tipText,
    required this.order,
    required this.isActive,
  });

  final String id;
  final String name;
  final PartnerCategory category;
  final String subtitle;
  final String description;
  final String url;
  final String? promoCode;
  final String? promoText;
  final String? tipText;
  final int order;
  final bool isActive;

  factory Partner.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    return Partner.fromMap(snapshot.id, snapshot.data());
  }

  factory Partner.fromMap(String id, Map<String, dynamic>? data) {
    final map = data ?? const <String, dynamic>{};
    return Partner(
      id: id,
      name: map['name'] as String? ?? '',
      category: _categoryFromValue(map['category']),
      subtitle: map['subtitle'] as String? ?? '',
      description: map['description'] as String? ?? '',
      url: map['url'] as String? ?? '',
      promoCode: _optionalString(map['promoCode']),
      promoText: _optionalString(map['promoText']),
      tipText: _optionalString(map['tipText']),
      order: (map['order'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] == true,
    );
  }
}

class PartnerDraft {
  const PartnerDraft({
    required this.name,
    required this.category,
    required this.subtitle,
    required this.description,
    required this.url,
    required this.promoCode,
    required this.promoText,
    required this.tipText,
    required this.order,
    required this.isActive,
  });

  final String name;
  final PartnerCategory category;
  final String subtitle;
  final String description;
  final String url;
  final String? promoCode;
  final String? promoText;
  final String? tipText;
  final int order;
  final bool isActive;

  Map<String, dynamic> toFirestoreMap() => {
    'name': name.trim(),
    'category': category.firestoreValue,
    'subtitle': subtitle.trim().isEmpty ? null : subtitle.trim(),
    'description': description.trim(),
    'url': url.trim(),
    'promoCode': _optionalString(promoCode),
    'promoText': _optionalString(promoText),
    'tipText': _optionalString(tipText),
    'order': order,
    'isActive': isActive,
  };
}

extension PartnerCategoryValue on PartnerCategory {
  String get firestoreValue => switch (this) {
    PartnerCategory.creator => 'creator',
    PartnerCategory.shop => 'shop',
    PartnerCategory.breeder => 'breeder',
    PartnerCategory.unknown => 'creator',
  };
}

PartnerCategory _categoryFromValue(Object? value) {
  return switch (value) {
    'creator' => PartnerCategory.creator,
    'shop' => PartnerCategory.shop,
    'breeder' => PartnerCategory.breeder,
    _ => PartnerCategory.unknown,
  };
}

String? _optionalString(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
