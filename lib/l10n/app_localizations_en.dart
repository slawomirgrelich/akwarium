// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Aquarist PRO';

  @override
  String get loginWelcome => 'Welcome back';

  @override
  String get createAccount => 'Create account';

  @override
  String get loginSubtitle => 'Sign in to return to your aquarium.';

  @override
  String get registerSubtitle =>
      'Start taking care of your aquarium with confidence.';

  @override
  String get email => 'Email address';

  @override
  String get emailRequired => 'Enter your email address.';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get login => 'Sign in';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get alreadyHaveAccount => 'I already have an account';

  @override
  String get createNewAccount => 'Create a new account';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get journal => 'Journal';

  @override
  String get tools => 'Tools';

  @override
  String get profile => 'Profile';

  @override
  String get notifications => 'Notifications';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'App theme';

  @override
  String get language => 'App language';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get polish => 'Polski (PL)';

  @override
  String get english => 'English (EN)';

  @override
  String get activeAquarium => 'Active aquarium';

  @override
  String get addNewAquarium => 'Add a new aquarium';

  @override
  String get freePlan => 'Free plan: up to 3 aquariums';

  @override
  String get proPlan => 'PRO plan: unlimited aquariums';

  @override
  String get aquariumManagement => 'Aquariums and stock';

  @override
  String get fauna => 'Fauna';

  @override
  String get flora => 'Flora';

  @override
  String get searchSpecies => 'Search species or variety';

  @override
  String get invalidEmail => 'The email address is invalid.';

  @override
  String get invalidCredentials => 'Invalid email or password.';

  @override
  String get userDisabled => 'This account has been disabled.';

  @override
  String get emailAlreadyInUse => 'An account with this email already exists.';

  @override
  String get networkError =>
      'No internet connection. Check your network and try again.';

  @override
  String get authError => 'There was a problem with authentication. Try again.';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters.';

  @override
  String get passwordsMustMatch => 'Passwords must match.';
}
