import 'package:flutter/foundation.dart';

import '../models/user_data_model.dart';

class ProAccessService extends ChangeNotifier {
  ProAccessService({UserDataModel? user}) : _user = user ?? const UserDataModel(uid: '');

  UserDataModel _user;

  bool get isProUser => _user.isProUser;
  UserDataModel get user => _user;

  void setProUser(bool value) {
    if (_user.isProUser == value) return;
    _user = _user.copyWith(isProUser: value);
    notifyListeners();
  }

  void enableProForDevelopment() => setProUser(true);
}