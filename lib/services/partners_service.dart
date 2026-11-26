import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/partner_model.dart';

class PartnersServiceException implements Exception {
  const PartnersServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PartnersService {
  PartnersService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<List<Partner>> watchActivePartners() {
    if (_auth.currentUser == null) {
      return Stream<List<Partner>>.error(
        const PartnersServiceException(
          'Zaloguj się, aby otworzyć strefę partnerów.',
        ),
      );
    }

    return _firestore
        .collection('partners')
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .limit(100)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(Partner.fromFirestore)
              .where((partner) => partner.isActive)
              .toList(growable: false),
        );
  }
}
