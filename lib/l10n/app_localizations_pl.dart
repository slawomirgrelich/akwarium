// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Akwarysta PRO';

  @override
  String get loginWelcome => 'Witaj ponownie';

  @override
  String get createAccount => 'Utwórz konto';

  @override
  String get loginSubtitle => 'Zaloguj się, aby wrócić do swojego akwarium.';

  @override
  String get registerSubtitle => 'Zacznij spokojnie dbać o swoje akwarium.';

  @override
  String get email => 'Adres e-mail';

  @override
  String get emailRequired => 'Wpisz adres e-mail.';

  @override
  String get password => 'Hasło';

  @override
  String get confirmPassword => 'Powtórz hasło';

  @override
  String get login => 'Zaloguj się';

  @override
  String get forgotPassword => 'Zapomniałeś hasła?';

  @override
  String get alreadyHaveAccount => 'Mam już konto';

  @override
  String get createNewAccount => 'Utwórz nowe konto';

  @override
  String get dashboard => 'Pulpit';

  @override
  String get journal => 'Dziennik';

  @override
  String get tools => 'Narzędzia';

  @override
  String get profile => 'Profil';

  @override
  String get notifications => 'Powiadomienia';

  @override
  String get settings => 'Ustawienia';

  @override
  String get theme => 'Motyw aplikacji';

  @override
  String get language => 'Język aplikacji';

  @override
  String get system => 'Systemowy';

  @override
  String get light => 'Jasny';

  @override
  String get dark => 'Ciemny';

  @override
  String get polish => 'Polski (PL)';

  @override
  String get english => 'English (EN)';

  @override
  String get activeAquarium => 'Aktywne akwarium';

  @override
  String get addNewAquarium => 'Dodaj nowe akwarium';

  @override
  String get freePlan => 'Plan Free: do 3 zbiorników';

  @override
  String get proPlan => 'Plan PRO: nielimitowana liczba zbiorników';

  @override
  String get aquariumManagement => 'Akwaria i obsada';

  @override
  String get fauna => 'Fauna';

  @override
  String get flora => 'Flora';

  @override
  String get searchSpecies => 'Szukaj gatunku lub odmiany';

  @override
  String get invalidEmail => 'Podany adres e-mail jest nieprawidłowy.';

  @override
  String get invalidCredentials => 'Nieprawidłowy e-mail lub hasło.';

  @override
  String get userDisabled => 'To konto zostało wyłączone.';

  @override
  String get emailAlreadyInUse => 'Konto z tym adresem e-mail już istnieje.';

  @override
  String get networkError =>
      'Brak połączenia z internetem. Sprawdź sieć i spróbuj ponownie.';

  @override
  String get authError => 'Wystąpił problem z autoryzacją. Spróbuj ponownie.';

  @override
  String get passwordTooShort => 'Hasło musi mieć co najmniej 6 znaków.';

  @override
  String get passwordsMustMatch => 'Hasła muszą być identyczne.';
}
