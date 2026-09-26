import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pl, this message translates to:
  /// **'Akwarysta PRO'**
  String get appTitle;

  /// No description provided for @loginWelcome.
  ///
  /// In pl, this message translates to:
  /// **'Witaj ponownie'**
  String get loginWelcome;

  /// No description provided for @createAccount.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz konto'**
  String get createAccount;

  /// No description provided for @loginSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj się, aby wrócić do swojego akwarium.'**
  String get loginSubtitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Zacznij spokojnie dbać o swoje akwarium.'**
  String get registerSubtitle;

  /// No description provided for @email.
  ///
  /// In pl, this message translates to:
  /// **'Adres e-mail'**
  String get email;

  /// No description provided for @emailRequired.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz adres e-mail.'**
  String get emailRequired;

  /// No description provided for @password.
  ///
  /// In pl, this message translates to:
  /// **'Hasło'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In pl, this message translates to:
  /// **'Powtórz hasło'**
  String get confirmPassword;

  /// No description provided for @login.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj się'**
  String get login;

  /// No description provided for @forgotPassword.
  ///
  /// In pl, this message translates to:
  /// **'Zapomniałeś hasła?'**
  String get forgotPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In pl, this message translates to:
  /// **'Mam już konto'**
  String get alreadyHaveAccount;

  /// No description provided for @createNewAccount.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz nowe konto'**
  String get createNewAccount;

  /// No description provided for @dashboard.
  ///
  /// In pl, this message translates to:
  /// **'Pulpit'**
  String get dashboard;

  /// No description provided for @journal.
  ///
  /// In pl, this message translates to:
  /// **'Dziennik'**
  String get journal;

  /// No description provided for @tools.
  ///
  /// In pl, this message translates to:
  /// **'Narzędzia'**
  String get tools;

  /// No description provided for @profile.
  ///
  /// In pl, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @notifications.
  ///
  /// In pl, this message translates to:
  /// **'Powiadomienia'**
  String get notifications;

  /// No description provided for @settings.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In pl, this message translates to:
  /// **'Motyw aplikacji'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In pl, this message translates to:
  /// **'Język aplikacji'**
  String get language;

  /// No description provided for @system.
  ///
  /// In pl, this message translates to:
  /// **'Systemowy'**
  String get system;

  /// No description provided for @light.
  ///
  /// In pl, this message translates to:
  /// **'Jasny'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In pl, this message translates to:
  /// **'Ciemny'**
  String get dark;

  /// No description provided for @polish.
  ///
  /// In pl, this message translates to:
  /// **'Polski (PL)'**
  String get polish;

  /// No description provided for @english.
  ///
  /// In pl, this message translates to:
  /// **'English (EN)'**
  String get english;

  /// No description provided for @activeAquarium.
  ///
  /// In pl, this message translates to:
  /// **'Aktywne akwarium'**
  String get activeAquarium;

  /// No description provided for @addNewAquarium.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj nowe akwarium'**
  String get addNewAquarium;

  /// No description provided for @freePlan.
  ///
  /// In pl, this message translates to:
  /// **'Plan Free: do 3 zbiorników'**
  String get freePlan;

  /// No description provided for @proPlan.
  ///
  /// In pl, this message translates to:
  /// **'Plan PRO: nielimitowana liczba zbiorników'**
  String get proPlan;

  /// No description provided for @aquariumManagement.
  ///
  /// In pl, this message translates to:
  /// **'Akwaria i obsada'**
  String get aquariumManagement;

  /// No description provided for @fauna.
  ///
  /// In pl, this message translates to:
  /// **'Fauna'**
  String get fauna;

  /// No description provided for @flora.
  ///
  /// In pl, this message translates to:
  /// **'Flora'**
  String get flora;

  /// No description provided for @searchSpecies.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj gatunku lub odmiany'**
  String get searchSpecies;

  /// No description provided for @invalidEmail.
  ///
  /// In pl, this message translates to:
  /// **'Podany adres e-mail jest nieprawidłowy.'**
  String get invalidEmail;

  /// No description provided for @invalidCredentials.
  ///
  /// In pl, this message translates to:
  /// **'Nieprawidłowy e-mail lub hasło.'**
  String get invalidCredentials;

  /// No description provided for @userDisabled.
  ///
  /// In pl, this message translates to:
  /// **'To konto zostało wyłączone.'**
  String get userDisabled;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In pl, this message translates to:
  /// **'Konto z tym adresem e-mail już istnieje.'**
  String get emailAlreadyInUse;

  /// No description provided for @networkError.
  ///
  /// In pl, this message translates to:
  /// **'Brak połączenia z internetem. Sprawdź sieć i spróbuj ponownie.'**
  String get networkError;

  /// No description provided for @authError.
  ///
  /// In pl, this message translates to:
  /// **'Wystąpił problem z autoryzacją. Spróbuj ponownie.'**
  String get authError;

  /// No description provided for @passwordTooShort.
  ///
  /// In pl, this message translates to:
  /// **'Hasło musi mieć co najmniej 6 znaków.'**
  String get passwordTooShort;

  /// No description provided for @passwordsMustMatch.
  ///
  /// In pl, this message translates to:
  /// **'Hasła muszą być identyczne.'**
  String get passwordsMustMatch;

  /// No description provided for @yourDashboard.
  ///
  /// In pl, this message translates to:
  /// **'Twój pulpit'**
  String get yourDashboard;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Wszystko, co ważne dla Twojego akwarium.'**
  String get dashboardSubtitle;

  /// No description provided for @helloUser.
  ///
  /// In pl, this message translates to:
  /// **'Cześć, Sławek! 👋'**
  String get helloUser;

  /// No description provided for @noNewNotifications.
  ///
  /// In pl, this message translates to:
  /// **'Brak nowych powiadomień'**
  String get noNewNotifications;

  /// No description provided for @aquariumStatus.
  ///
  /// In pl, this message translates to:
  /// **'Status akwarium'**
  String get aquariumStatus;

  /// No description provided for @lastTest.
  ///
  /// In pl, this message translates to:
  /// **'Ostatni test'**
  String get lastTest;

  /// No description provided for @noData.
  ///
  /// In pl, this message translates to:
  /// **'Brak danych'**
  String get noData;

  /// No description provided for @addFirstTest.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwszy test'**
  String get addFirstTest;

  /// No description provided for @parametersCount.
  ///
  /// In pl, this message translates to:
  /// **'7 parametrów'**
  String get parametersCount;

  /// No description provided for @waterChange.
  ///
  /// In pl, this message translates to:
  /// **'Podmiana'**
  String get waterChange;

  /// No description provided for @daysCount.
  ///
  /// In pl, this message translates to:
  /// **'{count} dni'**
  String daysCount(int count);

  /// No description provided for @freshWater.
  ///
  /// In pl, this message translates to:
  /// **'Woda świeża'**
  String get freshWater;

  /// No description provided for @timeForWaterChange.
  ///
  /// In pl, this message translates to:
  /// **'Czas na podmianę'**
  String get timeForWaterChange;

  /// No description provided for @recentParameters.
  ///
  /// In pl, this message translates to:
  /// **'Ostatnie parametry'**
  String get recentParameters;

  /// No description provided for @quickActions.
  ///
  /// In pl, this message translates to:
  /// **'Szybkie akcje'**
  String get quickActions;

  /// No description provided for @enterWaterTest.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz wyniki testu wody'**
  String get enterWaterTest;

  /// No description provided for @saveTankParameters.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz aktualne parametry zbiornika'**
  String get saveTankParameters;

  /// No description provided for @addWaterChange.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj podmianę wody'**
  String get addWaterChange;

  /// No description provided for @saveVolumeAndNote.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz litraż i notatkę'**
  String get saveVolumeAndNote;

  /// No description provided for @historyOfTank.
  ///
  /// In pl, this message translates to:
  /// **'HISTORIA ZBIORNIKA'**
  String get historyOfTank;

  /// No description provided for @journalSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Pełna historia opieki nad akwarium.'**
  String get journalSubtitle;

  /// No description provided for @recentEntries.
  ///
  /// In pl, this message translates to:
  /// **'Ostatnie wpisy'**
  String get recentEntries;

  /// No description provided for @showOlderEntries.
  ///
  /// In pl, this message translates to:
  /// **'Pokaż starsze wpisy'**
  String get showOlderEntries;

  /// No description provided for @journalEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Dziennik jest jeszcze pusty'**
  String get journalEmpty;

  /// No description provided for @addFirstWaterEntry.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwszy test wody lub podmianę.'**
  String get addFirstWaterEntry;

  /// No description provided for @toolsCenter.
  ///
  /// In pl, this message translates to:
  /// **'CENTRUM NARZĘDZI'**
  String get toolsCenter;

  /// No description provided for @toolsSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Praktyczne funkcje dla każdego akwarysty.'**
  String get toolsSubtitle;

  /// No description provided for @account.
  ///
  /// In pl, this message translates to:
  /// **'TWOJE KONTO'**
  String get account;

  /// No description provided for @profileTitle.
  ///
  /// In pl, this message translates to:
  /// **'Profil i PRO'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Zarządzaj akwarium oraz ustawieniami konta.'**
  String get profileSubtitle;

  /// No description provided for @aquariumName.
  ///
  /// In pl, this message translates to:
  /// **'Akwarium Roślinne'**
  String get aquariumName;

  /// No description provided for @tankDetails.
  ///
  /// In pl, this message translates to:
  /// **'112 litrów · Roślinne'**
  String get tankDetails;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienia o testach i podmianach'**
  String get notificationsSubtitle;

  /// No description provided for @syncData.
  ///
  /// In pl, this message translates to:
  /// **'Synchronizacja danych'**
  String get syncData;

  /// No description provided for @syncSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Przygotowane pod Firebase lub Supabase'**
  String get syncSubtitle;

  /// No description provided for @syncComingSoon.
  ///
  /// In pl, this message translates to:
  /// **'Synchronizacja zostanie podłączona w kolejnym etapie'**
  String get syncComingSoon;

  /// No description provided for @logOut.
  ///
  /// In pl, this message translates to:
  /// **'Wyloguj się'**
  String get logOut;

  /// No description provided for @logOutSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Zakończ bieżącą sesję na tym urządzeniu'**
  String get logOutSubtitle;

  /// No description provided for @cancel.
  ///
  /// In pl, this message translates to:
  /// **'Anuluj'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz'**
  String get save;

  /// No description provided for @volume.
  ///
  /// In pl, this message translates to:
  /// **'Objętość'**
  String get volume;

  /// No description provided for @note.
  ///
  /// In pl, this message translates to:
  /// **'Notatka'**
  String get note;

  /// No description provided for @liters.
  ///
  /// In pl, this message translates to:
  /// **'litrów'**
  String get liters;

  /// No description provided for @diagnosisSaved.
  ///
  /// In pl, this message translates to:
  /// **'Diagnoza została zapisana w dzienniku'**
  String get diagnosisSaved;

  /// No description provided for @saveToJournal.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz do Dziennika'**
  String get saveToJournal;

  /// No description provided for @tanksAndStock.
  ///
  /// In pl, this message translates to:
  /// **'Akwaria i obsada'**
  String get tanksAndStock;

  /// No description provided for @tanksAndStockDescription.
  ///
  /// In pl, this message translates to:
  /// **'Przełącz zbiornik i zarządzaj fauną oraz florą.'**
  String get tanksAndStockDescription;

  /// No description provided for @openManagement.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz zarządzanie'**
  String get openManagement;

  /// No description provided for @waterTests.
  ///
  /// In pl, this message translates to:
  /// **'Testy wody'**
  String get waterTests;

  /// No description provided for @waterTestsDescription.
  ///
  /// In pl, this message translates to:
  /// **'Zapisuj pH, NO3, PO4, Fe, KH, GH i temperaturę.'**
  String get waterTestsDescription;

  /// No description provided for @openTests.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz testy'**
  String get openTests;

  /// No description provided for @knowledgeBase.
  ///
  /// In pl, this message translates to:
  /// **'Baza wiedzy i Atlas'**
  String get knowledgeBase;

  /// No description provided for @knowledgeBaseDescription.
  ///
  /// In pl, this message translates to:
  /// **'Poznaj ryby, rośliny i sposoby walki z glonami.'**
  String get knowledgeBaseDescription;

  /// No description provided for @openAtlas.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz Atlas'**
  String get openAtlas;

  /// No description provided for @fertilizerCalculator.
  ///
  /// In pl, this message translates to:
  /// **'Kalkulator nawożenia'**
  String get fertilizerCalculator;

  /// No description provided for @fertilizerDescription.
  ///
  /// In pl, this message translates to:
  /// **'Oblicz dawki dzienne i tygodniowe dla zbiornika.'**
  String get fertilizerDescription;

  /// No description provided for @openCalculator.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz kalkulator'**
  String get openCalculator;

  /// No description provided for @calculatorsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Kalkulatory akwarystyczne'**
  String get calculatorsTitle;

  /// No description provided for @volumeTab.
  ///
  /// In pl, this message translates to:
  /// **'Objętość'**
  String get volumeTab;

  /// No description provided for @co2Tab.
  ///
  /// In pl, this message translates to:
  /// **'CO2'**
  String get co2Tab;

  /// No description provided for @fertilizersTab.
  ///
  /// In pl, this message translates to:
  /// **'Nawozy'**
  String get fertilizersTab;

  /// No description provided for @volumeCalculator.
  ///
  /// In pl, this message translates to:
  /// **'Objętość zbiornika'**
  String get volumeCalculator;

  /// No description provided for @volumeCalculatorSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Porównaj pojemność brutto z realną ilością wody.'**
  String get volumeCalculatorSubtitle;

  /// No description provided for @length.
  ///
  /// In pl, this message translates to:
  /// **'Długość'**
  String get length;

  /// No description provided for @width.
  ///
  /// In pl, this message translates to:
  /// **'Szerokość'**
  String get width;

  /// No description provided for @height.
  ///
  /// In pl, this message translates to:
  /// **'Wysokość'**
  String get height;

  /// No description provided for @glassThickness.
  ///
  /// In pl, this message translates to:
  /// **'Grubość szkła'**
  String get glassThickness;

  /// No description provided for @substrateThickness.
  ///
  /// In pl, this message translates to:
  /// **'Grubość podłoża'**
  String get substrateThickness;

  /// No description provided for @decorationsAndEquipment.
  ///
  /// In pl, this message translates to:
  /// **'Dekoracje i sprzęt'**
  String get decorationsAndEquipment;

  /// No description provided for @saveNetDefault.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz netto jako domyślne'**
  String get saveNetDefault;

  /// No description provided for @co2Calculator.
  ///
  /// In pl, this message translates to:
  /// **'Kalkulator CO2'**
  String get co2Calculator;

  /// No description provided for @co2CalculatorSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz pH i KH, aby sprawdzić stężenie rozpuszczonego CO2.'**
  String get co2CalculatorSubtitle;

  /// No description provided for @fertilizerCalculatorTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dawkowanie nawozów'**
  String get fertilizerCalculatorTitle;

  /// No description provided for @fertilizerCalculatorSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź, ile pierwiastka wnosi każdy mililitr roztworu.'**
  String get fertilizerCalculatorSubtitle;

  /// No description provided for @netCapacity.
  ///
  /// In pl, this message translates to:
  /// **'Pojemność netto'**
  String get netCapacity;

  /// No description provided for @solutionCapacity.
  ///
  /// In pl, this message translates to:
  /// **'Pojemność roztworu'**
  String get solutionCapacity;

  /// No description provided for @saltAmount.
  ///
  /// In pl, this message translates to:
  /// **'Wsypana sól'**
  String get saltAmount;

  /// No description provided for @baseSalt.
  ///
  /// In pl, this message translates to:
  /// **'Sól bazowa'**
  String get baseSalt;

  /// No description provided for @weeklyTarget.
  ///
  /// In pl, this message translates to:
  /// **'Cel tygodniowy'**
  String get weeklyTarget;

  /// No description provided for @freshWaterLastChange.
  ///
  /// In pl, this message translates to:
  /// **'Woda jest świeża. Ostatnia podmiana była {count} dni temu.'**
  String freshWaterLastChange(int count);

  /// No description provided for @scheduleNextChange.
  ///
  /// In pl, this message translates to:
  /// **'Czas zaplanować kolejną podmianę wody.'**
  String get scheduleNextChange;

  /// No description provided for @noSavedMeasurements.
  ///
  /// In pl, this message translates to:
  /// **'Brak zapisanych pomiarów'**
  String get noSavedMeasurements;

  /// No description provided for @addFirstTestTrack.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwszy test, aby śledzić kondycję wody.'**
  String get addFirstTestTrack;

  /// No description provided for @addFirstMeasurement.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwszy pomiar'**
  String get addFirstMeasurement;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
