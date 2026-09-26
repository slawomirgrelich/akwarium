import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_data_model.dart';

class ProAccessService extends ChangeNotifier {
  ProAccessService({UserDataModel? user, this.preferences})
    : _user = user ?? const UserDataModel(uid: '');

  static const proStatusKey = 'is_pro_active';

  UserDataModel _user;
  SharedPreferences? preferences;

  bool get isProUser => _user.isProUser;
  UserDataModel get user => _user;

  Future<void> init() async {
    final storedPreferences = preferences ??=
        await SharedPreferences.getInstance();
    final isProActive = storedPreferences.getBool(proStatusKey) ?? false;
    if (_user.isProUser == isProActive) return;

    _user = _user.copyWith(isProUser: isProActive);
    notifyListeners();
  }

  Future<void> setProUser(bool value) async {
    final storedPreferences = preferences ??=
        await SharedPreferences.getInstance();
    await storedPreferences.setBool(proStatusKey, value);
    if (_user.isProUser == value) return;

    _user = _user.copyWith(isProUser: value);
    notifyListeners();
  }

  Future<void> enableProForDevelopment() => setProUser(true);
}
