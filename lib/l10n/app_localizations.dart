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

  /// No description provided for @signInWithGoogle.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj się przez Google'**
  String get signInWithGoogle;

  /// No description provided for @orContinueWith.
  ///
  /// In pl, this message translates to:
  /// **'lub kontynuuj przez'**
  String get orContinueWith;

  /// No description provided for @signedInAccount.
  ///
  /// In pl, this message translates to:
  /// **'Zalogowane konto'**
  String get signedInAccount;

  /// No description provided for @googleSignInConfigurationError.
  ///
  /// In pl, this message translates to:
  /// **'Logowanie Google nie jest skonfigurowane. Skonfiguruj klientów OAuth w Firebase i podaj identyfikator klienta web podczas budowania aplikacji.'**
  String get googleSignInConfigurationError;

  /// No description provided for @googleSignInUnsupported.
  ///
  /// In pl, this message translates to:
  /// **'Logowanie Google nie jest dostępne na tej platformie.'**
  String get googleSignInUnsupported;

  /// No description provided for @googleSignInFailed.
  ///
  /// In pl, this message translates to:
  /// **'Logowanie przez Google nie powiodło się. Sprawdź połączenie i spróbuj ponownie.'**
  String get googleSignInFailed;

  /// No description provided for @googleConfigurationHint.
  ///
  /// In pl, this message translates to:
  /// **'Logowanie Google wymaga włączenia dostawcy Google w Firebase Authentication, odcisków SHA podpisu Androida i identyfikatora klienta OAuth web. Dla iOS skonfiguruj klienta OAuth i schemat URL.'**
  String get googleConfigurationHint;

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
  /// **'Plan Free: 1 akwarium'**
  String get freePlan;

  /// No description provided for @proPlan.
  ///
  /// In pl, this message translates to:
  /// **'Plan PRO: nielimitowana liczba akwariów'**
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
  /// **'8 parametrów'**
  String get parametersCount;

  /// No description provided for @waterChange.
  ///
  /// In pl, this message translates to:
  /// **'Podmiana'**
  String get waterChange;

  /// No description provided for @daysCount.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, =1{1 dzień} other{{count} dni}}'**
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
  /// **'Nazwa'**
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

  /// No description provided for @add.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj'**
  String get add;

  /// No description provided for @netVolume.
  ///
  /// In pl, this message translates to:
  /// **'Pojemność netto'**
  String get netVolume;

  /// No description provided for @grossVolume.
  ///
  /// In pl, this message translates to:
  /// **'Pojemność brutto'**
  String get grossVolume;

  /// No description provided for @setupDateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Data założenia'**
  String get setupDateLabel;

  /// No description provided for @tankType.
  ///
  /// In pl, this message translates to:
  /// **'Typ zbiornika'**
  String get tankType;

  /// No description provided for @freshwater.
  ///
  /// In pl, this message translates to:
  /// **'Słodkowodne'**
  String get freshwater;

  /// No description provided for @saltwater.
  ///
  /// In pl, this message translates to:
  /// **'Morskie'**
  String get saltwater;

  /// No description provided for @brackish.
  ///
  /// In pl, this message translates to:
  /// **'Brackawe'**
  String get brackish;

  /// No description provided for @netVolumeShort.
  ///
  /// In pl, this message translates to:
  /// **'{volume} l netto'**
  String netVolumeShort(num volume);

  /// No description provided for @litersCount.
  ///
  /// In pl, this message translates to:
  /// **'{volume} litrów'**
  String litersCount(num volume);

  /// No description provided for @inhabitantsCount.
  ///
  /// In pl, this message translates to:
  /// **'{count, plural, =0{0 mieszkańców} =1{1 mieszkańiec} few{{count} mieszkańców} many{{count} mieszkańców} other{{count} mieszkańców}}'**
  String inhabitantsCount(int count);

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

  /// No description provided for @newActivity.
  ///
  /// In pl, this message translates to:
  /// **'Nowa czynność'**
  String get newActivity;

  /// No description provided for @title.
  ///
  /// In pl, this message translates to:
  /// **'Tytuł'**
  String get title;

  /// No description provided for @activityType.
  ///
  /// In pl, this message translates to:
  /// **'Typ czynności'**
  String get activityType;

  /// No description provided for @waterReplaced.
  ///
  /// In pl, this message translates to:
  /// **'Podmieniona woda'**
  String get waterReplaced;

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

  /// No description provided for @actualWaterVolume.
  ///
  /// In pl, this message translates to:
  /// **'Rzeczywista objętość wody'**
  String get actualWaterVolume;

  /// No description provided for @netWater.
  ///
  /// In pl, this message translates to:
  /// **'Woda netto'**
  String get netWater;

  /// No description provided for @substrate.
  ///
  /// In pl, this message translates to:
  /// **'Podłoże'**
  String get substrate;

  /// No description provided for @grossVolumeValue.
  ///
  /// In pl, this message translates to:
  /// **'Brutto: {value} l'**
  String grossVolumeValue(String value);

  /// No description provided for @rocksWood.
  ///
  /// In pl, this message translates to:
  /// **'Skały / drewno'**
  String get rocksWood;

  /// No description provided for @glass.
  ///
  /// In pl, this message translates to:
  /// **'Szkło'**
  String get glass;

  /// No description provided for @estimatedTotalWeight.
  ///
  /// In pl, this message translates to:
  /// **'Szacowany ciężar całkowity: {value} kg'**
  String estimatedTotalWeight(String value);

  /// No description provided for @co2Low.
  ///
  /// In pl, this message translates to:
  /// **'Niedobór CO2 - słaby wzrost roślin'**
  String get co2Low;

  /// No description provided for @co2Optimal.
  ///
  /// In pl, this message translates to:
  /// **'Poziom optymalny - bezpieczny dla ryb'**
  String get co2Optimal;

  /// No description provided for @co2High.
  ///
  /// In pl, this message translates to:
  /// **'Nadmiar CO2 - ryzyko przyduchy dla ryb'**
  String get co2High;

  /// No description provided for @co2Deficit.
  ///
  /// In pl, this message translates to:
  /// **'niedobór'**
  String get co2Deficit;

  /// No description provided for @co2Optimum.
  ///
  /// In pl, this message translates to:
  /// **'optimum'**
  String get co2Optimum;

  /// No description provided for @co2Risk.
  ///
  /// In pl, this message translates to:
  /// **'ryzyko'**
  String get co2Risk;

  /// No description provided for @proActive.
  ///
  /// In pl, this message translates to:
  /// **'Akwarysta PRO (aktywny)'**
  String get proActive;

  /// No description provided for @proName.
  ///
  /// In pl, this message translates to:
  /// **'Akwarysta PRO'**
  String get proName;

  /// No description provided for @allPremiumUnlocked.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie funkcje premium są odblokowane'**
  String get allPremiumUnlocked;

  /// No description provided for @unlockPremium.
  ///
  /// In pl, this message translates to:
  /// **'Odblokuj AI, wykresy i nielimitowane akwaria.'**
  String get unlockPremium;

  /// No description provided for @proPlanUnlimitedAquariums.
  ///
  /// In pl, this message translates to:
  /// **'Plan PRO: nielimitowana liczba akwariów'**
  String get proPlanUnlimitedAquariums;

  /// No description provided for @knowledgeBaseTitle.
  ///
  /// In pl, this message translates to:
  /// **'Baza wiedzy i Atlas'**
  String get knowledgeBaseTitle;

  /// No description provided for @knowledgeBaseDesc.
  ///
  /// In pl, this message translates to:
  /// **'Poznaj ryby, rośliny i metody zwalczania glonów.'**
  String get knowledgeBaseDesc;

  /// No description provided for @fertilizerCalcTitle.
  ///
  /// In pl, this message translates to:
  /// **'Kalkulator nawozów'**
  String get fertilizerCalcTitle;

  /// No description provided for @fertilizerCalcDesc.
  ///
  /// In pl, this message translates to:
  /// **'Oblicz dzienne i tygodniowe dawki dla swojego akwarium.'**
  String get fertilizerCalcDesc;

  /// No description provided for @aquaristProActive.
  ///
  /// In pl, this message translates to:
  /// **'Akwarysta PRO (aktywny)'**
  String get aquaristProActive;

  /// No description provided for @allFeaturesUnlocked.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie funkcje premium są odblokowane'**
  String get allFeaturesUnlocked;

  /// No description provided for @navTools.
  ///
  /// In pl, this message translates to:
  /// **'Narzędzia'**
  String get navTools;

  /// No description provided for @navJournal.
  ///
  /// In pl, this message translates to:
  /// **'Dziennik'**
  String get navJournal;

  /// No description provided for @navDashboard.
  ///
  /// In pl, this message translates to:
  /// **'Pulpit'**
  String get navDashboard;

  /// No description provided for @navProfile.
  ///
  /// In pl, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @tabTimeline.
  ///
  /// In pl, this message translates to:
  /// **'Oś czasu'**
  String get tabTimeline;

  /// No description provided for @tabCalendar.
  ///
  /// In pl, this message translates to:
  /// **'Kalendarz'**
  String get tabCalendar;

  /// No description provided for @forToday.
  ///
  /// In pl, this message translates to:
  /// **'Na dziś'**
  String get forToday;

  /// No description provided for @selectedDay.
  ///
  /// In pl, this message translates to:
  /// **'Wybrany dzień'**
  String get selectedDay;

  /// No description provided for @aiScannerTitle.
  ///
  /// In pl, this message translates to:
  /// **'Skaner AI ryb i roślin'**
  String get aiScannerTitle;

  /// No description provided for @aiScannerDesc.
  ///
  /// In pl, this message translates to:
  /// **'Rozpoznaj gatunek ze zdjęcia i poznaj jego wymagania.'**
  String get aiScannerDesc;

  /// No description provided for @tryPro.
  ///
  /// In pl, this message translates to:
  /// **'Subskrybuj'**
  String get tryPro;

  /// No description provided for @algaeAssistantTitle.
  ///
  /// In pl, this message translates to:
  /// **'Asystent glonów'**
  String get algaeAssistantTitle;

  /// No description provided for @algaeAssistantDesc.
  ///
  /// In pl, this message translates to:
  /// **'Zdiagnozuj problem i otrzymaj plan działania.'**
  String get algaeAssistantDesc;

  /// No description provided for @startDiagnosis.
  ///
  /// In pl, this message translates to:
  /// **'Rozpocznij diagnozę'**
  String get startDiagnosis;

  /// No description provided for @timeline.
  ///
  /// In pl, this message translates to:
  /// **'Oś czasu'**
  String get timeline;

  /// No description provided for @calendar.
  ///
  /// In pl, this message translates to:
  /// **'Kalendarz'**
  String get calendar;

  /// No description provided for @allEntries.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie'**
  String get allEntries;

  /// No description provided for @noEntriesForFilter.
  ///
  /// In pl, this message translates to:
  /// **'Brak wpisów dla wybranego filtra.'**
  String get noEntriesForFilter;

  /// No description provided for @searchAtlas.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj w Atlasie'**
  String get searchAtlas;

  /// No description provided for @knowledgeForStableTank.
  ///
  /// In pl, this message translates to:
  /// **'Wiedza dla stabilnego zbiornika'**
  String get knowledgeForStableTank;

  /// No description provided for @proPaywallTitle.
  ///
  /// In pl, this message translates to:
  /// **'Odblokuj Pełny Potencjał Akwarysta PRO'**
  String get proPaywallTitle;

  /// No description provided for @proPaywallSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Spokojniejsza opieka nad akwarium dzięki funkcjom dla wymagających zbiorników.'**
  String get proPaywallSubtitle;

  /// No description provided for @featureUnlimitedCharts.
  ///
  /// In pl, this message translates to:
  /// **'Nielimitowane wykresy i historia parametrów'**
  String get featureUnlimitedCharts;

  /// No description provided for @featureFertilizerCalc.
  ///
  /// In pl, this message translates to:
  /// **'Kalkulator nawożenia i receptury soli'**
  String get featureFertilizerCalc;

  /// No description provided for @featureReminders.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienia SMS i Push'**
  String get featureReminders;

  /// No description provided for @featureExportPdf.
  ///
  /// In pl, this message translates to:
  /// **'Eksport raportów do PDF'**
  String get featureExportPdf;

  /// No description provided for @trial7Days.
  ///
  /// In pl, this message translates to:
  /// **'Wypróbuj PRO przez 7 dni za darmo'**
  String get trial7Days;

  /// No description provided for @maybeLater.
  ///
  /// In pl, this message translates to:
  /// **'Później'**
  String get maybeLater;

  /// No description provided for @algaeQuestion.
  ///
  /// In pl, this message translates to:
  /// **'Co widzisz w akwarium?'**
  String get algaeQuestion;

  /// No description provided for @algaeBba.
  ///
  /// In pl, this message translates to:
  /// **'Krasnorosty / BBA'**
  String get algaeBba;

  /// No description provided for @algaeGreen.
  ///
  /// In pl, this message translates to:
  /// **'Zielenice'**
  String get algaeGreen;

  /// No description provided for @algaeCyanobacteria.
  ///
  /// In pl, this message translates to:
  /// **'Sinice / cyjanobakterie'**
  String get algaeCyanobacteria;

  /// No description provided for @algaeDiatoms.
  ///
  /// In pl, this message translates to:
  /// **'Okrzemki'**
  String get algaeDiatoms;

  /// No description provided for @algaeDust.
  ///
  /// In pl, this message translates to:
  /// **'Pył na szybie'**
  String get algaeDust;

  /// No description provided for @algaeThread.
  ///
  /// In pl, this message translates to:
  /// **'Nitkowate'**
  String get algaeThread;

  /// No description provided for @addAlgaePhotoOptional.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj zdjęcie glonu (opcjonalnie)'**
  String get addAlgaePhotoOptional;

  /// No description provided for @recentWaterParams.
  ///
  /// In pl, this message translates to:
  /// **'Ostatnie parametry wody'**
  String get recentWaterParams;

  /// No description provided for @paramsLoadedInfo.
  ///
  /// In pl, this message translates to:
  /// **'Wartości zostały wczytane z najnowszego testu. Możesz je poprawić przed analizą.'**
  String get paramsLoadedInfo;

  /// No description provided for @tankConditions.
  ///
  /// In pl, this message translates to:
  /// **'Warunki w akwarium'**
  String get tankConditions;

  /// No description provided for @lightHours.
  ///
  /// In pl, this message translates to:
  /// **'Światło'**
  String get lightHours;

  /// No description provided for @substrateType.
  ///
  /// In pl, this message translates to:
  /// **'Podłoże'**
  String get substrateType;

  /// No description provided for @gravelSand.
  ///
  /// In pl, this message translates to:
  /// **'Żwirek / piasek'**
  String get gravelSand;

  /// No description provided for @saveMeasurement.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz pomiar'**
  String get saveMeasurement;

  /// No description provided for @journalTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dziennik akwarysty'**
  String get journalTitle;

  /// No description provided for @filterWaterChange.
  ///
  /// In pl, this message translates to:
  /// **'Podmiana wody'**
  String get filterWaterChange;

  /// No description provided for @filterFilter.
  ///
  /// In pl, this message translates to:
  /// **'Filtr'**
  String get filterFilter;

  /// No description provided for @filterTrimming.
  ///
  /// In pl, this message translates to:
  /// **'Przycinanie'**
  String get filterTrimming;

  /// No description provided for @filterMeds.
  ///
  /// In pl, this message translates to:
  /// **'Leki'**
  String get filterMeds;

  /// No description provided for @filterCleaning.
  ///
  /// In pl, this message translates to:
  /// **'Czyszczenie'**
  String get filterCleaning;

  /// No description provided for @upcomingTasks.
  ///
  /// In pl, this message translates to:
  /// **'Nadchodzące zadania'**
  String get upcomingTasks;

  /// No description provided for @noTasksForDay.
  ///
  /// In pl, this message translates to:
  /// **'Brak zadań na ten dzień.'**
  String get noTasksForDay;

  /// No description provided for @tanksAndStockTitle.
  ///
  /// In pl, this message translates to:
  /// **'Akwaria i obsada'**
  String get tanksAndStockTitle;

  /// No description provided for @addTank.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj akwarium'**
  String get addTank;

  /// No description provided for @addNewTank.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj nowe akwarium'**
  String get addNewTank;

  /// No description provided for @speciesCount.
  ///
  /// In pl, this message translates to:
  /// **'Gatunki'**
  String get speciesCount;

  /// No description provided for @itemCount.
  ///
  /// In pl, this message translates to:
  /// **'Sztuki'**
  String get itemCount;

  /// No description provided for @searchSpeciesOrVar.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj gatunku lub odmiany'**
  String get searchSpeciesOrVar;

  /// No description provided for @noEntriesInCategory.
  ///
  /// In pl, this message translates to:
  /// **'Brak wpisów w tej kategorii.'**
  String get noEntriesInCategory;

  /// No description provided for @idealForYourTank.
  ///
  /// In pl, this message translates to:
  /// **'Idealne do Twojego akwarium'**
  String get idealForYourTank;

  /// No description provided for @co2Dosing.
  ///
  /// In pl, this message translates to:
  /// **'Podawanie CO2'**
  String get co2Dosing;

  /// No description provided for @includeCo2InDiagnosis.
  ///
  /// In pl, this message translates to:
  /// **'Uwzględnij instalację CO2 w diagnozie'**
  String get includeCo2InDiagnosis;

  /// No description provided for @diagnoseProblem.
  ///
  /// In pl, this message translates to:
  /// **'Zdiagnozuj problem'**
  String get diagnoseProblem;

  /// No description provided for @waterTestTitle.
  ///
  /// In pl, this message translates to:
  /// **'Test wody'**
  String get waterTestTitle;

  /// No description provided for @waterParameters.
  ///
  /// In pl, this message translates to:
  /// **'Parametry wody'**
  String get waterParameters;

  /// No description provided for @waterTestInfo.
  ///
  /// In pl, this message translates to:
  /// **'Pomiń niewykonane testy, pozostawiając pola puste. Wpisz co najmniej jeden parametr; pomiar zapisze się z aktualną datą i godziną.'**
  String get waterTestInfo;

  /// No description provided for @waterAtLeastOneParameter.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz co najmniej jeden parametr wody.'**
  String get waterAtLeastOneParameter;

  /// No description provided for @waterTestDeleteTitle.
  ///
  /// In pl, this message translates to:
  /// **'Usunąć test wody?'**
  String get waterTestDeleteTitle;

  /// No description provided for @waterTestDeletePrompt.
  ///
  /// In pl, this message translates to:
  /// **'Ten test wody i jego wpis w historii zostaną trwale usunięte.'**
  String get waterTestDeletePrompt;

  /// No description provided for @waterTestDeletedMessage.
  ///
  /// In pl, this message translates to:
  /// **'Test wody został usunięty.'**
  String get waterTestDeletedMessage;

  /// No description provided for @waterTestDeleteFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się usunąć testu wody. Spróbuj ponownie.'**
  String get waterTestDeleteFailed;

  /// No description provided for @dailyDose.
  ///
  /// In pl, this message translates to:
  /// **'Dawka dzienna'**
  String get dailyDose;

  /// No description provided for @weeklyDose.
  ///
  /// In pl, this message translates to:
  /// **'Dawka tygodniowa'**
  String get weeklyDose;

  /// No description provided for @addFishOrPlantPhoto.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj zdjęcie ryby lub rośliny'**
  String get addFishOrPlantPhoto;

  /// No description provided for @tapToSelectCameraOrGallery.
  ///
  /// In pl, this message translates to:
  /// **'Dotknij, aby wybrać Aparat lub Galerię'**
  String get tapToSelectCameraOrGallery;

  /// No description provided for @runRecognition.
  ///
  /// In pl, this message translates to:
  /// **'Uruchom rozpoznawanie'**
  String get runRecognition;

  /// No description provided for @smartDiagnosis.
  ///
  /// In pl, this message translates to:
  /// **'Inteligentna diagnoza'**
  String get smartDiagnosis;

  /// No description provided for @smartDiagnosisSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Wprowadź aktualne dane, aby otrzymać plan działania.'**
  String get smartDiagnosisSubtitle;

  /// No description provided for @currentPh.
  ///
  /// In pl, this message translates to:
  /// **'Aktualne pH'**
  String get currentPh;

  /// No description provided for @previousPh.
  ///
  /// In pl, this message translates to:
  /// **'pH z poprzedniego pomiaru'**
  String get previousPh;

  /// No description provided for @lightingTime.
  ///
  /// In pl, this message translates to:
  /// **'Czas świecenia'**
  String get lightingTime;

  /// No description provided for @runProDiagnosis.
  ///
  /// In pl, this message translates to:
  /// **'Uruchom diagnozę PRO'**
  String get runProDiagnosis;

  /// No description provided for @temperature.
  ///
  /// In pl, this message translates to:
  /// **'Temperatura'**
  String get temperature;

  /// No description provided for @changeAquariumTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Zmień akwarium'**
  String get changeAquariumTooltip;

  /// No description provided for @notificationSettings.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia powiadomień'**
  String get notificationSettings;

  /// No description provided for @taskReminders.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienia o zadaniach'**
  String get taskReminders;

  /// No description provided for @taskRemindersSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Podmiany, filtr i pielęgnacja'**
  String get taskRemindersSubtitle;

  /// No description provided for @waterTestReminders.
  ///
  /// In pl, this message translates to:
  /// **'Pomiary wody'**
  String get waterTestReminders;

  /// No description provided for @waterTestRemindersSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienie o regularnym teście'**
  String get waterTestRemindersSubtitle;

  /// No description provided for @weeklySummary.
  ///
  /// In pl, this message translates to:
  /// **'Tygodniowe podsumowanie'**
  String get weeklySummary;

  /// No description provided for @weeklySummarySubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Najważniejsze zmiany w akwarium'**
  String get weeklySummarySubtitle;

  /// No description provided for @proNotificationsNote.
  ///
  /// In pl, this message translates to:
  /// **'Powiadomienia PRO są aktywne dla tego urządzenia.'**
  String get proNotificationsNote;

  /// No description provided for @atlasSearchPlaceholder.
  ///
  /// In pl, this message translates to:
  /// **'np. neon, anubias, zielenice'**
  String get atlasSearchPlaceholder;

  /// No description provided for @proNotificationsRequired.
  ///
  /// In pl, this message translates to:
  /// **'Powiadomienia push i cykliczne harmonogramy wymagają aktywnego planu PRO.'**
  String get proNotificationsRequired;

  /// No description provided for @setProfileName.
  ///
  /// In pl, this message translates to:
  /// **'Ustaw imię profilu'**
  String get setProfileName;

  /// No description provided for @geminiApiKeyLabel.
  ///
  /// In pl, this message translates to:
  /// **'Klucz API Gemini'**
  String get geminiApiKeyLabel;

  /// No description provided for @aiScannerConfig.
  ///
  /// In pl, this message translates to:
  /// **'Konfiguracja skanera zdjęć AI'**
  String get aiScannerConfig;

  /// No description provided for @cloudBackupSyncTitle.
  ///
  /// In pl, this message translates to:
  /// **'Kopia w chmurze i synchronizacja'**
  String get cloudBackupSyncTitle;

  /// No description provided for @cloudBackupSyncSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Automatyczny zapis i tworzenie kopii zapasowej w chmurze'**
  String get cloudBackupSyncSubtitle;

  /// No description provided for @photoJournalTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dziennik zdjęć'**
  String get photoJournalTitle;

  /// No description provided for @addFirstPhotoOfAquarium.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwsze zdjęcie akwarium.'**
  String get addFirstPhotoOfAquarium;

  /// No description provided for @addPhoto.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj zdjęcie'**
  String get addPhoto;

  /// No description provided for @aquariumLivestockTitle.
  ///
  /// In pl, this message translates to:
  /// **'Obsada akwarium'**
  String get aquariumLivestockTitle;

  /// No description provided for @compatibilityPercent.
  ///
  /// In pl, this message translates to:
  /// **'{score}% kompatybilności'**
  String compatibilityPercent(int score);

  /// No description provided for @livestockWithinRange.
  ///
  /// In pl, this message translates to:
  /// **'Obsada mieści się w sprawdzonych zakresach.'**
  String get livestockWithinRange;

  /// No description provided for @noSpeciesAddedOpenAtlas.
  ///
  /// In pl, this message translates to:
  /// **'Brak dodanych gatunków. Otwórz atlas, aby dodać obsadę.'**
  String get noSpeciesAddedOpenAtlas;

  /// No description provided for @addSpecies.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj gatunek'**
  String get addSpecies;

  /// No description provided for @addSpeciesToStock.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj gatunek do obsady'**
  String get addSpeciesToStock;

  /// No description provided for @newReminder.
  ///
  /// In pl, this message translates to:
  /// **'Nowe przypomnienie'**
  String get newReminder;

  /// No description provided for @taskName.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa zadania'**
  String get taskName;

  /// No description provided for @reminderTaskPreset.
  ///
  /// In pl, this message translates to:
  /// **'Rodzaj zadania'**
  String get reminderTaskPreset;

  /// No description provided for @reminderCustomNameRequired.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz nazwę własnego zadania.'**
  String get reminderCustomNameRequired;

  /// No description provided for @reminderInvalidInterval.
  ///
  /// In pl, this message translates to:
  /// **'Podaj interwał powtarzania wynoszący co najmniej jeden dzień.'**
  String get reminderInvalidInterval;

  /// No description provided for @dueDate.
  ///
  /// In pl, this message translates to:
  /// **'Termin'**
  String get dueDate;

  /// No description provided for @repeatCyclically.
  ///
  /// In pl, this message translates to:
  /// **'Powtarzaj cyklicznie'**
  String get repeatCyclically;

  /// No description provided for @autoScheduleNextDate.
  ///
  /// In pl, this message translates to:
  /// **'Automatycznie planuj kolejny termin'**
  String get autoScheduleNextDate;

  /// No description provided for @proBenefitUnlimitedAquariums.
  ///
  /// In pl, this message translates to:
  /// **'Nielimitowane akwaria'**
  String get proBenefitUnlimitedAquariums;

  /// No description provided for @proBenefitAiScannerDiagnostics.
  ///
  /// In pl, this message translates to:
  /// **'Skaner AI i diagnostyka'**
  String get proBenefitAiScannerDiagnostics;

  /// No description provided for @proBenefitFullPhotoHistory.
  ///
  /// In pl, this message translates to:
  /// **'Pełna historia zdjęć'**
  String get proBenefitFullPhotoHistory;

  /// No description provided for @proBenefitNoAds.
  ///
  /// In pl, this message translates to:
  /// **'Brak reklam'**
  String get proBenefitNoAds;

  /// No description provided for @unlockProHeadline.
  ///
  /// In pl, this message translates to:
  /// **'Odblokuj Akwarysta PRO'**
  String get unlockProHeadline;

  /// No description provided for @experienceMode.
  ///
  /// In pl, this message translates to:
  /// **'Tryb korzystania z aplikacji'**
  String get experienceMode;

  /// No description provided for @experienceModeSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Dopasuj pulpit i wskazówki do swojego doświadczenia.'**
  String get experienceModeSubtitle;

  /// No description provided for @beginnerMode.
  ///
  /// In pl, this message translates to:
  /// **'Początkujący'**
  String get beginnerMode;

  /// No description provided for @advancedMode.
  ///
  /// In pl, this message translates to:
  /// **'Zaawansowany'**
  String get advancedMode;

  /// No description provided for @beginnerModeDescription.
  ///
  /// In pl, this message translates to:
  /// **'Prostszy pulpit i prowadzenie krok po kroku.'**
  String get beginnerModeDescription;

  /// No description provided for @advancedModeDescription.
  ///
  /// In pl, this message translates to:
  /// **'Pełne parametry, wykresy i narzędzia.'**
  String get advancedModeDescription;

  /// No description provided for @beginnerGuideTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zacznij krok po kroku'**
  String get beginnerGuideTitle;

  /// No description provided for @beginnerGuideIntro.
  ///
  /// In pl, this message translates to:
  /// **'Nie musisz znać wszystkich parametrów. Zacznij od tych czterech podstaw.'**
  String get beginnerGuideIntro;

  /// No description provided for @beginnerStepDimensions.
  ///
  /// In pl, this message translates to:
  /// **'Wymiary i pojemność'**
  String get beginnerStepDimensions;

  /// No description provided for @beginnerStepDimensionsDescription.
  ///
  /// In pl, this message translates to:
  /// **'Zmierz długość, szerokość i wysokość akwarium. Zanotuj, ile wody rzeczywiście wlewasz.'**
  String get beginnerStepDimensionsDescription;

  /// No description provided for @beginnerStepWater.
  ///
  /// In pl, this message translates to:
  /// **'Woda kranowa'**
  String get beginnerStepWater;

  /// No description provided for @beginnerStepWaterDescription.
  ///
  /// In pl, this message translates to:
  /// **'Przed wpuszczeniem zwierząt zbadaj wodę i uzdatnij ją zgodnie z instrukcją preparatu.'**
  String get beginnerStepWaterDescription;

  /// No description provided for @beginnerStepLighting.
  ///
  /// In pl, this message translates to:
  /// **'Oświetlenie'**
  String get beginnerStepLighting;

  /// No description provided for @beginnerStepLightingDescription.
  ///
  /// In pl, this message translates to:
  /// **'Zacznij od umiarkowanego czasu świecenia i zmieniaj go stopniowo, obserwując rośliny i glony.'**
  String get beginnerStepLightingDescription;

  /// No description provided for @beginnerStepPlants.
  ///
  /// In pl, this message translates to:
  /// **'Łatwe rośliny'**
  String get beginnerStepPlants;

  /// No description provided for @beginnerStepPlantsDescription.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz niewymagające rośliny, na przykład anubiasy, kryptokoryny lub rogatek.'**
  String get beginnerStepPlantsDescription;

  /// No description provided for @maintenanceTaskDeleteConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz usunąć zadanie „{title}”?'**
  String maintenanceTaskDeleteConfirm(String title);

  /// No description provided for @beginnerNextStep.
  ///
  /// In pl, this message translates to:
  /// **'Następny krok'**
  String get beginnerNextStep;

  /// No description provided for @beginnerPreviousStep.
  ///
  /// In pl, this message translates to:
  /// **'Poprzedni krok'**
  String get beginnerPreviousStep;

  /// No description provided for @beginnerFinishGuide.
  ///
  /// In pl, this message translates to:
  /// **'Zakończ samouczek'**
  String get beginnerFinishGuide;

  /// No description provided for @beginnerGuideSaveFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać ukończenia samouczka. Spróbuj ponownie.'**
  String get beginnerGuideSaveFailed;

  /// No description provided for @beginnerDimensionsAction.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz akwarium'**
  String get beginnerDimensionsAction;

  /// No description provided for @beginnerLightingAction.
  ///
  /// In pl, this message translates to:
  /// **'Zobacz wskazówki'**
  String get beginnerLightingAction;

  /// No description provided for @editAquariumTitle.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj akwarium'**
  String get editAquariumTitle;

  /// No description provided for @hoursPerDayShort.
  ///
  /// In pl, this message translates to:
  /// **'godz./dzień'**
  String get hoursPerDayShort;

  /// No description provided for @beginnerWaterStatusNoData.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwszy pomiar, aby sprawdzić kondycję wody.'**
  String get beginnerWaterStatusNoData;

  /// No description provided for @beginnerWaterStatusGood.
  ///
  /// In pl, this message translates to:
  /// **'Ostatni pomiar nie wskazuje pilnego problemu.'**
  String get beginnerWaterStatusGood;

  /// No description provided for @beginnerWaterStatusNeedsAttention.
  ///
  /// In pl, this message translates to:
  /// **'Warto sprawdzić ostatni pomiar i wprowadzić zalecane zmiany stopniowo.'**
  String get beginnerWaterStatusNeedsAttention;

  /// No description provided for @beginnerTestSaved.
  ///
  /// In pl, this message translates to:
  /// **'Pomiar zapisany.'**
  String get beginnerTestSaved;

  /// No description provided for @beginnerWaterMeasurementsHint.
  ///
  /// In pl, this message translates to:
  /// **'Wpisuj tylko wyniki, które udało Ci się zmierzyć. Pozostałe pola możesz pominąć.'**
  String get beginnerWaterMeasurementsHint;

  /// No description provided for @beginnerDimensionHint.
  ///
  /// In pl, this message translates to:
  /// **'Podaj wewnętrzne wymiary akwarium w centymetrach. Przybliżoną pojemność obliczymy za Ciebie.'**
  String get beginnerDimensionHint;

  /// No description provided for @tankLength.
  ///
  /// In pl, this message translates to:
  /// **'Długość'**
  String get tankLength;

  /// No description provided for @tankWidth.
  ///
  /// In pl, this message translates to:
  /// **'Szerokość'**
  String get tankWidth;

  /// No description provided for @tankHeight.
  ///
  /// In pl, this message translates to:
  /// **'Wysokość'**
  String get tankHeight;

  /// No description provided for @beginnerCalculatedCapacity.
  ///
  /// In pl, this message translates to:
  /// **'Przybliżona pojemność brutto: {liters} l'**
  String beginnerCalculatedCapacity(String liters);

  /// No description provided for @invalidTankDimensions.
  ///
  /// In pl, this message translates to:
  /// **'Wymiary muszą być dodatnimi liczbami.'**
  String get invalidTankDimensions;

  /// No description provided for @invalidNetVolume.
  ///
  /// In pl, this message translates to:
  /// **'Podaj prawidłową, dodatnią ilość wody w zbiorniku.'**
  String get invalidNetVolume;

  /// No description provided for @beginnerNetVolumeHint.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz przybliżoną ilość wody w zbiorniku. Nie musisz obliczać pojemności brutto.'**
  String get beginnerNetVolumeHint;

  /// No description provided for @monthlyPlan.
  ///
  /// In pl, this message translates to:
  /// **'Miesięczny'**
  String get monthlyPlan;

  /// No description provided for @yearlyPlan.
  ///
  /// In pl, this message translates to:
  /// **'Roczny'**
  String get yearlyPlan;

  /// No description provided for @mostPopularBadge.
  ///
  /// In pl, this message translates to:
  /// **'Najpopularniejszy'**
  String get mostPopularBadge;

  /// No description provided for @activatingEllipsis.
  ///
  /// In pl, this message translates to:
  /// **'Przetwarzanie…'**
  String get activatingEllipsis;

  /// No description provided for @proActivatedMessage.
  ///
  /// In pl, this message translates to:
  /// **'Subskrypcja Akwarysta PRO została aktywowana.'**
  String get proActivatedMessage;

  /// No description provided for @proActivationFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się aktywować PRO: {error}'**
  String proActivationFailed(String error);

  /// No description provided for @speciesAtlasTitle.
  ///
  /// In pl, this message translates to:
  /// **'Atlas gatunków'**
  String get speciesAtlasTitle;

  /// No description provided for @searchSpeciesLabel.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj gatunku'**
  String get searchSpeciesLabel;

  /// No description provided for @filterAll.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie'**
  String get filterAll;

  /// No description provided for @filterFish.
  ///
  /// In pl, this message translates to:
  /// **'Ryby'**
  String get filterFish;

  /// No description provided for @filterPlants.
  ///
  /// In pl, this message translates to:
  /// **'Rośliny'**
  String get filterPlants;

  /// No description provided for @filterInvertebrates.
  ///
  /// In pl, this message translates to:
  /// **'Bezkręgowce'**
  String get filterInvertebrates;

  /// No description provided for @noSpeciesFound.
  ///
  /// In pl, this message translates to:
  /// **'Nie znaleziono gatunków.'**
  String get noSpeciesFound;

  /// No description provided for @careNotesLabel.
  ///
  /// In pl, this message translates to:
  /// **'Wskazówki pielęgnacyjne'**
  String get careNotesLabel;

  /// No description provided for @minTankVolumeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Minimum akwarium: {value} l'**
  String minTankVolumeLabel(int value);

  /// No description provided for @temperatureRangeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Temperatura: {min}–{max}°C'**
  String temperatureRangeLabel(num min, num max);

  /// No description provided for @phRangeLabel.
  ///
  /// In pl, this message translates to:
  /// **'pH: {min}–{max}'**
  String phRangeLabel(num min, num max);

  /// No description provided for @ghRangeLabel.
  ///
  /// In pl, this message translates to:
  /// **'GH: {min}–{max}'**
  String ghRangeLabel(num min, num max);

  /// No description provided for @difficultyLabel.
  ///
  /// In pl, this message translates to:
  /// **'Trudność: {value}'**
  String difficultyLabel(String value);

  /// No description provided for @swimmingZoneLabel.
  ///
  /// In pl, this message translates to:
  /// **'Strefa pływania: {value}'**
  String swimmingZoneLabel(String value);

  /// No description provided for @plantsTabTitle.
  ///
  /// In pl, this message translates to:
  /// **'Rośliny'**
  String get plantsTabTitle;

  /// No description provided for @animalsTabTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ryby i bezkręgowce'**
  String get animalsTabTitle;

  /// No description provided for @plantTargetHeightLabel.
  ///
  /// In pl, this message translates to:
  /// **'Docelowa wysokość: {min}–{max} cm'**
  String plantTargetHeightLabel(num min, num max);

  /// No description provided for @plantPositionDetailsLabel.
  ///
  /// In pl, this message translates to:
  /// **'Pozycja w akwarium: {value}'**
  String plantPositionDetailsLabel(String value);

  /// No description provided for @plantKhRangeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Zakres KH: {min}–{max} dKH'**
  String plantKhRangeLabel(num min, num max);

  /// No description provided for @plantCo2Label.
  ///
  /// In pl, this message translates to:
  /// **'Wymagania CO2: {value}'**
  String plantCo2Label(String value);

  /// No description provided for @plantLightingPowerLabel.
  ///
  /// In pl, this message translates to:
  /// **'Minimalna moc oświetlenia: {value} W/L'**
  String plantLightingPowerLabel(String value);

  /// No description provided for @plantVarietiesLabel.
  ///
  /// In pl, this message translates to:
  /// **'Odmiany: {value}'**
  String plantVarietiesLabel(String value);

  /// No description provided for @plantLightingPowerNote.
  ///
  /// In pl, this message translates to:
  /// **'Orientacyjna moc dla oświetlenia LED; rzeczywista intensywność zależy od lampy i głębokości zbiornika.'**
  String get plantLightingPowerNote;

  /// No description provided for @co2Required.
  ///
  /// In pl, this message translates to:
  /// **'Wymagane'**
  String get co2Required;

  /// No description provided for @plantCareDataUnavailable.
  ///
  /// In pl, this message translates to:
  /// **'Brak danych pielęgnacyjnych dla tej rośliny.'**
  String get plantCareDataUnavailable;

  /// No description provided for @compatibleWithAquarium.
  ///
  /// In pl, this message translates to:
  /// **'Dopasowany do akwarium \"{name}\"'**
  String compatibleWithAquarium(String name);

  /// No description provided for @warningsForAquarium.
  ///
  /// In pl, this message translates to:
  /// **'Ostrzeżenia dla akwarium \"{name}\"'**
  String warningsForAquarium(String name);

  /// No description provided for @addToMyAquarium.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj do mojego akwarium'**
  String get addToMyAquarium;

  /// No description provided for @loginToAddSpecies.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj się, aby dodać gatunek do akwarium.'**
  String get loginToAddSpecies;

  /// No description provided for @chooseAquarium.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz akwarium'**
  String get chooseAquarium;

  /// No description provided for @noAquariumYet.
  ///
  /// In pl, this message translates to:
  /// **'Nie masz jeszcze żadnego akwarium. Utwórz akwarium, aby dodać do niego gatunek'**
  String get noAquariumYet;

  /// No description provided for @createAquariumAction.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz akwarium'**
  String get createAquariumAction;

  /// No description provided for @createNewAquariumAction.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz nowe akwarium'**
  String get createNewAquariumAction;

  /// No description provided for @openManagementToCreateAquarium.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz zarządzanie akwariami, aby utworzyć akwarium.'**
  String get openManagementToCreateAquarium;

  /// No description provided for @addedSpeciesToAquarium.
  ///
  /// In pl, this message translates to:
  /// **'Dodano {species} do akwarium {aquarium}'**
  String addedSpeciesToAquarium(String species, String aquarium);

  /// No description provided for @viewLivestock.
  ///
  /// In pl, this message translates to:
  /// **'Zobacz obsadę'**
  String get viewLivestock;

  /// No description provided for @difficultyVeryEasy.
  ///
  /// In pl, this message translates to:
  /// **'bardzo łatwa'**
  String get difficultyVeryEasy;

  /// No description provided for @difficultyEasy.
  ///
  /// In pl, this message translates to:
  /// **'łatwa'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In pl, this message translates to:
  /// **'średnia'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In pl, this message translates to:
  /// **'trudna'**
  String get difficultyHard;

  /// No description provided for @zoneBottom.
  ///
  /// In pl, this message translates to:
  /// **'dno'**
  String get zoneBottom;

  /// No description provided for @zoneMiddle.
  ///
  /// In pl, this message translates to:
  /// **'środek'**
  String get zoneMiddle;

  /// No description provided for @zoneTop.
  ///
  /// In pl, this message translates to:
  /// **'powierzchnia'**
  String get zoneTop;

  /// No description provided for @zoneAll.
  ///
  /// In pl, this message translates to:
  /// **'cały zbiornik'**
  String get zoneAll;

  /// No description provided for @addSpeciesDialogTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj {name}'**
  String addSpeciesDialogTitle(String name);

  /// No description provided for @additionDateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Data dodania'**
  String get additionDateLabel;

  /// No description provided for @notesOptionalLabel.
  ///
  /// In pl, this message translates to:
  /// **'Notatki (opcjonalnie)'**
  String get notesOptionalLabel;

  /// No description provided for @nameDisplayedOnDashboard.
  ///
  /// In pl, this message translates to:
  /// **'Imię wyświetlane na pulpicie'**
  String get nameDisplayedOnDashboard;

  /// No description provided for @apiKeyLabel.
  ///
  /// In pl, this message translates to:
  /// **'Klucz API'**
  String get apiKeyLabel;

  /// No description provided for @apiKeyHint.
  ///
  /// In pl, this message translates to:
  /// **'Pozostaw puste, aby użyć klucza domyślnego'**
  String get apiKeyHint;

  /// No description provided for @geminiApiKeyManualHint.
  ///
  /// In pl, this message translates to:
  /// **'Wprowadź klucz API Gemini, aby włączyć skaner AI.'**
  String get geminiApiKeyManualHint;

  /// No description provided for @testApiKey.
  ///
  /// In pl, this message translates to:
  /// **'Testuj klucz API'**
  String get testApiKey;

  /// No description provided for @useDefaultKey.
  ///
  /// In pl, this message translates to:
  /// **'Użyj domyślnego klucza'**
  String get useDefaultKey;

  /// No description provided for @cloudSyncDescription.
  ///
  /// In pl, this message translates to:
  /// **'Twoje dane są bezpiecznie synchronizowane w chmurze'**
  String get cloudSyncDescription;

  /// No description provided for @editProfileName.
  ///
  /// In pl, this message translates to:
  /// **'Imię profilu'**
  String get editProfileName;

  /// No description provided for @profileNameLabel.
  ///
  /// In pl, this message translates to:
  /// **'Imię'**
  String get profileNameLabel;

  /// No description provided for @profileNameSaved.
  ///
  /// In pl, this message translates to:
  /// **'Zapisano imię profilu: {name}'**
  String profileNameSaved(String name);

  /// No description provided for @profileNameSaveFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać imienia: {error}'**
  String profileNameSaveFailed(String error);

  /// No description provided for @signInToChangeProfileName.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj się, aby zmienić imię profilu.'**
  String get signInToChangeProfileName;

  /// No description provided for @referralSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Poleć znajomych i odbierz darmowy miesiąc PRO'**
  String get referralSubtitle;

  /// No description provided for @helpCenterSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'FAQ, nowe zgłoszenia i historia kontaktu'**
  String get helpCenterSubtitle;

  /// No description provided for @activeAquariumSection.
  ///
  /// In pl, this message translates to:
  /// **'Aktywne akwarium'**
  String get activeAquariumSection;

  /// No description provided for @noActiveAquarium.
  ///
  /// In pl, this message translates to:
  /// **'Brak aktywnego akwarium'**
  String get noActiveAquarium;

  /// No description provided for @addAquariumToStart.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj akwarium, aby rozpocząć'**
  String get addAquariumToStart;

  /// No description provided for @freshwaterType.
  ///
  /// In pl, this message translates to:
  /// **'Słodkowodne'**
  String get freshwaterType;

  /// No description provided for @saltwaterType.
  ///
  /// In pl, this message translates to:
  /// **'Morskie'**
  String get saltwaterType;

  /// No description provided for @plantedTankType.
  ///
  /// In pl, this message translates to:
  /// **'Roślinne / holenderskie'**
  String get plantedTankType;

  /// No description provided for @biotopeTankType.
  ///
  /// In pl, this message translates to:
  /// **'Biotopowe'**
  String get biotopeTankType;

  /// No description provided for @shrimpTankType.
  ///
  /// In pl, this message translates to:
  /// **'Krewetkarium'**
  String get shrimpTankType;

  /// No description provided for @dashboardNoAquarium.
  ///
  /// In pl, this message translates to:
  /// **'Nie masz jeszcze akwarium. Dodaj akwarium, aby zobaczyć jego pulpit.'**
  String get dashboardNoAquarium;

  /// No description provided for @noScheduledTasks.
  ///
  /// In pl, this message translates to:
  /// **'Brak zaplanowanych zadań.'**
  String get noScheduledTasks;

  /// No description provided for @unnamedReminder.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienie'**
  String get unnamedReminder;

  /// No description provided for @manageTaskReminders.
  ///
  /// In pl, this message translates to:
  /// **'Zarządzaj przypomnieniami zadań'**
  String get manageTaskReminders;

  /// No description provided for @remindersScreenTitle.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienia zadań'**
  String get remindersScreenTitle;

  /// No description provided for @activateProForReminders.
  ///
  /// In pl, this message translates to:
  /// **'Aktywuj PRO, aby zarządzać przypomnieniami'**
  String get activateProForReminders;

  /// No description provided for @addReminder.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj przypomnienie'**
  String get addReminder;

  /// No description provided for @remindersLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać przypomnień.'**
  String get remindersLoadError;

  /// No description provided for @overdueTasks.
  ///
  /// In pl, this message translates to:
  /// **'Zaległe'**
  String get overdueTasks;

  /// No description provided for @todayAndUpcomingTasks.
  ///
  /// In pl, this message translates to:
  /// **'Dzisiaj i nadchodzące'**
  String get todayAndUpcomingTasks;

  /// No description provided for @completedTasks.
  ///
  /// In pl, this message translates to:
  /// **'Wykonane'**
  String get completedTasks;

  /// No description provided for @snoozeOneDay.
  ///
  /// In pl, this message translates to:
  /// **'Odłóż o 1 dzień'**
  String get snoozeOneDay;

  /// No description provided for @markReminderIncomplete.
  ///
  /// In pl, this message translates to:
  /// **'Oznacz jako niewykonane'**
  String get markReminderIncomplete;

  /// No description provided for @markReminderComplete.
  ///
  /// In pl, this message translates to:
  /// **'Oznacz jako wykonane'**
  String get markReminderComplete;

  /// No description provided for @addReminderDialogTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj przypomnienie'**
  String get addReminderDialogTitle;

  /// No description provided for @taskTypeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Typ zadania'**
  String get taskTypeLabel;

  /// No description provided for @repeatLabel.
  ///
  /// In pl, this message translates to:
  /// **'Powtarzaj'**
  String get repeatLabel;

  /// No description provided for @oneTime.
  ///
  /// In pl, this message translates to:
  /// **'Jednorazowo'**
  String get oneTime;

  /// No description provided for @dailyRecurrence.
  ///
  /// In pl, this message translates to:
  /// **'Codziennie'**
  String get dailyRecurrence;

  /// No description provided for @everyXDays.
  ///
  /// In pl, this message translates to:
  /// **'Co X dni'**
  String get everyXDays;

  /// No description provided for @weeklyRecurrence.
  ///
  /// In pl, this message translates to:
  /// **'Co tydzień'**
  String get weeklyRecurrence;

  /// No description provided for @monthlyRecurrence.
  ///
  /// In pl, this message translates to:
  /// **'Co miesiąc'**
  String get monthlyRecurrence;

  /// No description provided for @aquariumTaskSaveFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać zadania. Spróbuj ponownie.'**
  String get aquariumTaskSaveFailed;

  /// No description provided for @aquariumTaskUpdateFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zaktualizować zadania. Spróbuj ponownie.'**
  String get aquariumTaskUpdateFailed;

  /// No description provided for @repeatEveryDays.
  ///
  /// In pl, this message translates to:
  /// **'Powtarzaj co ile dni'**
  String get repeatEveryDays;

  /// No description provided for @daysProFeature.
  ///
  /// In pl, this message translates to:
  /// **'dni · funkcja PRO'**
  String get daysProFeature;

  /// No description provided for @daysUnit.
  ///
  /// In pl, this message translates to:
  /// **'dni'**
  String get daysUnit;

  /// No description provided for @enterPositiveDays.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz liczbę dni większą od zera.'**
  String get enterPositiveDays;

  /// No description provided for @everyDays.
  ///
  /// In pl, this message translates to:
  /// **'Co {days} dni'**
  String everyDays(int days);

  /// No description provided for @reminderTaskWaterChange.
  ///
  /// In pl, this message translates to:
  /// **'Podmiana wody'**
  String get reminderTaskWaterChange;

  /// No description provided for @reminderTaskFilterClean.
  ///
  /// In pl, this message translates to:
  /// **'Czyszczenie filtra'**
  String get reminderTaskFilterClean;

  /// No description provided for @reminderTaskWaterTest.
  ///
  /// In pl, this message translates to:
  /// **'Test parametrów'**
  String get reminderTaskWaterTest;

  /// No description provided for @reminderTaskFertilizer.
  ///
  /// In pl, this message translates to:
  /// **'Nawożenie'**
  String get reminderTaskFertilizer;

  /// No description provided for @reminderTaskCustom.
  ///
  /// In pl, this message translates to:
  /// **'Własne zadanie'**
  String get reminderTaskCustom;

  /// No description provided for @scheduledAquariumTaskNotification.
  ///
  /// In pl, this message translates to:
  /// **'Zaplanowane zadanie akwarystyczne'**
  String get scheduledAquariumTaskNotification;

  /// No description provided for @localNotificationScheduleFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zaplanować powiadomienia.'**
  String get localNotificationScheduleFailed;

  /// No description provided for @chartHistoryTitle.
  ///
  /// In pl, this message translates to:
  /// **'Historia parametrów wody'**
  String get chartHistoryTitle;

  /// No description provided for @chartTrendsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Trendy parametrów wody'**
  String get chartTrendsTitle;

  /// No description provided for @chartAddMeasurement.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pomiar'**
  String get chartAddMeasurement;

  /// No description provided for @chartLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać pomiarów. Spróbuj ponownie.'**
  String get chartLoadError;

  /// No description provided for @chartSaveError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zapisać pomiaru: {error}'**
  String chartSaveError(String error);

  /// No description provided for @chartNoParameterData.
  ///
  /// In pl, this message translates to:
  /// **'Brak zapisanych pomiarów parametru {parameter}.'**
  String chartNoParameterData(String parameter);

  /// No description provided for @chartNoParameterDataInRange.
  ///
  /// In pl, this message translates to:
  /// **'Brak pomiarów parametru {parameter} w wybranym zakresie.'**
  String chartNoParameterDataInRange(String parameter);

  /// No description provided for @chartChooseParameter.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz parametr'**
  String get chartChooseParameter;

  /// No description provided for @chartChangeOverTime.
  ///
  /// In pl, this message translates to:
  /// **'Zmiana w czasie · {parameter}'**
  String chartChangeOverTime(String parameter);

  /// No description provided for @chartOptimalRange.
  ///
  /// In pl, this message translates to:
  /// **'Optimum {min}–{max} {unit}'**
  String chartOptimalRange(String min, String max, String unit);

  /// No description provided for @chartAddAnotherMeasurement.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj kolejny pomiar'**
  String get chartAddAnotherMeasurement;

  /// No description provided for @chartLastMeasurement.
  ///
  /// In pl, this message translates to:
  /// **'Ostatni pomiar · {parameter}'**
  String chartLastMeasurement(String parameter);

  /// No description provided for @chartNoPreviousMeasurement.
  ///
  /// In pl, this message translates to:
  /// **'Brak wcześniejszego pomiaru'**
  String get chartNoPreviousMeasurement;

  /// No description provided for @chartStableTrend.
  ///
  /// In pl, this message translates to:
  /// **'Stabilnie względem poprzedniego'**
  String get chartStableTrend;

  /// No description provided for @chartRisingTrend.
  ///
  /// In pl, this message translates to:
  /// **'Wzrost względem poprzedniego'**
  String get chartRisingTrend;

  /// No description provided for @chartFallingTrend.
  ///
  /// In pl, this message translates to:
  /// **'Spadek względem poprzedniego'**
  String get chartFallingTrend;

  /// No description provided for @chartBelowRange.
  ///
  /// In pl, this message translates to:
  /// **'Poniżej zakresu'**
  String get chartBelowRange;

  /// No description provided for @chartAboveRange.
  ///
  /// In pl, this message translates to:
  /// **'Powyżej zakresu'**
  String get chartAboveRange;

  /// No description provided for @chartWithinRange.
  ///
  /// In pl, this message translates to:
  /// **'W zakresie'**
  String get chartWithinRange;

  /// No description provided for @chartStatus.
  ///
  /// In pl, this message translates to:
  /// **'Status: {status}'**
  String chartStatus(String status);

  /// No description provided for @chartEmptyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak pomiarów wody'**
  String get chartEmptyTitle;

  /// No description provided for @chartEmptyDescription.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwszy pomiar, aby zobaczyć trendy parametrów.'**
  String get chartEmptyDescription;

  /// No description provided for @chartAddFirstMeasurement.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwszy pomiar'**
  String get chartAddFirstMeasurement;

  /// No description provided for @chartRange7Days.
  ///
  /// In pl, this message translates to:
  /// **'7 dni'**
  String get chartRange7Days;

  /// No description provided for @chartRange30Days.
  ///
  /// In pl, this message translates to:
  /// **'30 dni'**
  String get chartRange30Days;

  /// No description provided for @chartRange90Days.
  ///
  /// In pl, this message translates to:
  /// **'90 dni'**
  String get chartRange90Days;

  /// No description provided for @chartRangeAll.
  ///
  /// In pl, this message translates to:
  /// **'Wszystko'**
  String get chartRangeAll;

  /// No description provided for @chartNewMeasurement.
  ///
  /// In pl, this message translates to:
  /// **'Nowy pomiar wody'**
  String get chartNewMeasurement;

  /// No description provided for @chartOptionalNote.
  ///
  /// In pl, this message translates to:
  /// **'Notatka (opcjonalnie)'**
  String get chartOptionalNote;

  /// No description provided for @chartEnterValue.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz wartość.'**
  String get chartEnterValue;

  /// No description provided for @chartInvalidNumber.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz poprawną liczbę.'**
  String get chartInvalidNumber;

  /// No description provided for @chartSaving.
  ///
  /// In pl, this message translates to:
  /// **'Zapisywanie...'**
  String get chartSaving;

  /// No description provided for @chartTwoMeasurementsRequired.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj co najmniej dwa pomiary, aby zobaczyć wykres.'**
  String get chartTwoMeasurementsRequired;

  /// Label for an interval-based task recurrence
  ///
  /// In pl, this message translates to:
  /// **'Powtarzaj co'**
  String get repeatEveryLabel;

  /// No description provided for @lastPerformedOn.
  ///
  /// In pl, this message translates to:
  /// **'Ostatnio: {date}'**
  String lastPerformedOn(String date);

  /// No description provided for @optionalLabel.
  ///
  /// In pl, this message translates to:
  /// **'opcjonalnie'**
  String get optionalLabel;

  /// No description provided for @speciesMinimumVolumeFrom.
  ///
  /// In pl, this message translates to:
  /// **'od {liters} l'**
  String speciesMinimumVolumeFrom(int liters);

  /// No description provided for @deleteLivestockConfirmation.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno usunąć {speciesName} z obsady akwarium?'**
  String deleteLivestockConfirmation(String speciesName);

  /// No description provided for @proFeatureTrialHeadline.
  ///
  /// In pl, this message translates to:
  /// **'Funkcja PRO - aktywuj darmowy okres próbny'**
  String get proFeatureTrialHeadline;

  /// No description provided for @geminiConnectionSucceeded.
  ///
  /// In pl, this message translates to:
  /// **'Połączenie z Gemini działa.'**
  String get geminiConnectionSucceeded;

  /// No description provided for @plantQuantityUnit.
  ///
  /// In pl, this message translates to:
  /// **'Jednostka ilości roślin'**
  String get plantQuantityUnit;

  /// No description provided for @quantityPieces.
  ///
  /// In pl, this message translates to:
  /// **'szt.'**
  String get quantityPieces;

  /// No description provided for @quantityPortions.
  ///
  /// In pl, this message translates to:
  /// **'porcje'**
  String get quantityPortions;

  /// No description provided for @quantityBaskets.
  ///
  /// In pl, this message translates to:
  /// **'koszyki'**
  String get quantityBaskets;

  /// No description provided for @equipmentTitle.
  ///
  /// In pl, this message translates to:
  /// **'Sprzęt i pielęgnacja'**
  String get equipmentTitle;

  /// No description provided for @equipmentLighting.
  ///
  /// In pl, this message translates to:
  /// **'Oświetlenie'**
  String get equipmentLighting;

  /// No description provided for @equipmentLightingPower.
  ///
  /// In pl, this message translates to:
  /// **'Moc oświetlenia'**
  String get equipmentLightingPower;

  /// No description provided for @equipmentPhotoperiod.
  ///
  /// In pl, this message translates to:
  /// **'Czas świecenia dziennie'**
  String get equipmentPhotoperiod;

  /// No description provided for @equipmentCo2System.
  ///
  /// In pl, this message translates to:
  /// **'System CO2'**
  String get equipmentCo2System;

  /// No description provided for @equipmentCo2Bubbles.
  ///
  /// In pl, this message translates to:
  /// **'Bąbelki CO2 na sekundę'**
  String get equipmentCo2Bubbles;

  /// No description provided for @equipmentFeeding.
  ///
  /// In pl, this message translates to:
  /// **'Informacje o karmieniu'**
  String get equipmentFeeding;

  /// No description provided for @equipmentNotConfigured.
  ///
  /// In pl, this message translates to:
  /// **'Nie dodano jeszcze informacji o sprzęcie ani pielęgnacji.'**
  String get equipmentNotConfigured;

  /// No description provided for @equipmentSaved.
  ///
  /// In pl, this message translates to:
  /// **'Zapisano informacje o sprzęcie i pielęgnacji.'**
  String get equipmentSaved;

  /// No description provided for @equipmentInvalidNumber.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz poprawną liczbę.'**
  String get equipmentInvalidNumber;

  /// No description provided for @compatibilityVolumeWarning.
  ///
  /// In pl, this message translates to:
  /// **'Pojemność akwarium jest za mała: {actual} l; wymagane minimum to {minimum} l.'**
  String compatibilityVolumeWarning(int actual, int minimum);

  /// No description provided for @compatibilityPhWarning.
  ///
  /// In pl, this message translates to:
  /// **'pH akwarium ({value}) jest poza zalecanym zakresem {min}-{max}.'**
  String compatibilityPhWarning(num value, num min, num max);

  /// No description provided for @compatibilityTemperatureWarning.
  ///
  /// In pl, this message translates to:
  /// **'Temperatura akwarium ({value}°C) jest poza zalecanym zakresem {min}-{max}°C.'**
  String compatibilityTemperatureWarning(num value, num min, num max);

  /// No description provided for @waterAssessmentCritical.
  ///
  /// In pl, this message translates to:
  /// **'Krytyczny'**
  String get waterAssessmentCritical;

  /// No description provided for @waterAssessmentWarning.
  ///
  /// In pl, this message translates to:
  /// **'Uwaga'**
  String get waterAssessmentWarning;

  /// No description provided for @waterAssessmentOutsideOptimum.
  ///
  /// In pl, this message translates to:
  /// **'Poza optimum'**
  String get waterAssessmentOutsideOptimum;

  /// No description provided for @waterAssessmentNormal.
  ///
  /// In pl, this message translates to:
  /// **'W normie'**
  String get waterAssessmentNormal;

  /// No description provided for @waterTestsSyncFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zsynchronizować historii pomiarów wody. Sprawdź połączenie i logowanie.'**
  String get waterTestsSyncFailed;

  /// No description provided for @waterAssessmentCriticalNo3.
  ///
  /// In pl, this message translates to:
  /// **'Krytyczny poziom NO3. Zalecana podmiana 30% wody.'**
  String get waterAssessmentCriticalNo3;

  /// No description provided for @waterAssessmentPhOutsideSafeRange.
  ///
  /// In pl, this message translates to:
  /// **'pH poza bezpiecznym zakresem 6,0-8,0.'**
  String get waterAssessmentPhOutsideSafeRange;

  /// No description provided for @waterAssessmentHighNo3.
  ///
  /// In pl, this message translates to:
  /// **'Wysoki poziom NO3. Zalecana podmiana 30% wody.'**
  String get waterAssessmentHighNo3;

  /// No description provided for @waterAssessmentLowPo4.
  ///
  /// In pl, this message translates to:
  /// **'Niski PO4 zwiększa ryzyko zielenic.'**
  String get waterAssessmentLowPo4;

  /// No description provided for @waterAssessmentHighPo4.
  ///
  /// In pl, this message translates to:
  /// **'Wysoki PO4 zwiększa ryzyko krasnorostów.'**
  String get waterAssessmentHighPo4;

  /// No description provided for @waterAssessmentOutsideMeasurementRange.
  ///
  /// In pl, this message translates to:
  /// **'{parameter} poza zakresem pomiarowym.'**
  String waterAssessmentOutsideMeasurementRange(String parameter);

  /// No description provided for @waterAssessmentOutsideOptimalRange.
  ///
  /// In pl, this message translates to:
  /// **'{parameter} poza optimum {min}-{max}{unit}.'**
  String waterAssessmentOutsideOptimalRange(
    String parameter,
    num min,
    num max,
    String unit,
  );

  /// No description provided for @waterAssessmentWithinOptimalRange.
  ///
  /// In pl, this message translates to:
  /// **'Parametr znajduje się w optymalnym zakresie.'**
  String get waterAssessmentWithinOptimalRange;

  /// No description provided for @waterAssessmentRedfieldRatio.
  ///
  /// In pl, this message translates to:
  /// **'Stosunek NO3:PO4 poza sugerowanym zakresem 10:1-16:1.'**
  String get waterAssessmentRedfieldRatio;

  /// No description provided for @diagnosticCyanobacteriaRiskTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ryzyko sinic'**
  String get diagnosticCyanobacteriaRiskTitle;

  /// No description provided for @diagnosticCyanobacteriaRiskMessage.
  ///
  /// In pl, this message translates to:
  /// **'Bardzo niski NO3 przy obecnym PO4 może sprzyjać sinicom.'**
  String get diagnosticCyanobacteriaRiskMessage;

  /// No description provided for @diagnosticGreenAlgaeRiskTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ryzyko zielenic'**
  String get diagnosticGreenAlgaeRiskTitle;

  /// No description provided for @diagnosticGreenAlgaeRiskMessage.
  ///
  /// In pl, this message translates to:
  /// **'Niski PO4 przy wyższym NO3 może sprzyjać zielenicom.'**
  String get diagnosticGreenAlgaeRiskMessage;

  /// No description provided for @diagnosticDangerousCo2Title.
  ///
  /// In pl, this message translates to:
  /// **'Niebezpieczny poziom CO2'**
  String get diagnosticDangerousCo2Title;

  /// No description provided for @diagnosticDangerousCo2Message.
  ///
  /// In pl, this message translates to:
  /// **'CO2 powyżej 30 ppm może powodować przyduchę ryb.'**
  String get diagnosticDangerousCo2Message;

  /// No description provided for @diagnosticLowCo2Title.
  ///
  /// In pl, this message translates to:
  /// **'Niestabilne lub niskie CO2'**
  String get diagnosticLowCo2Title;

  /// No description provided for @diagnosticLowCo2Message.
  ///
  /// In pl, this message translates to:
  /// **'Niski poziom CO2 może osłabiać rośliny i sprzyjać krasnorostom.'**
  String get diagnosticLowCo2Message;

  /// No description provided for @diagnosticRedAlgaeRiskTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ryzyko krasnorostów'**
  String get diagnosticRedAlgaeRiskTitle;

  /// No description provided for @diagnosticRedAlgaeRiskMessage.
  ///
  /// In pl, this message translates to:
  /// **'Wahania pH/CO2 osłabiają rośliny i sprzyjają krasnorostom.'**
  String get diagnosticRedAlgaeRiskMessage;

  /// No description provided for @diagnosticExcessiveLightingTitle.
  ///
  /// In pl, this message translates to:
  /// **'Długi czas świecenia'**
  String get diagnosticExcessiveLightingTitle;

  /// No description provided for @diagnosticExcessiveLightingMessage.
  ///
  /// In pl, this message translates to:
  /// **'Ponad 9 godzin światła może wzmacniać presję glonów.'**
  String get diagnosticExcessiveLightingMessage;

  /// No description provided for @diagnosticStableParametersTitle.
  ///
  /// In pl, this message translates to:
  /// **'Parametry wyglądają stabilnie'**
  String get diagnosticStableParametersTitle;

  /// No description provided for @diagnosticStableParametersMessage.
  ///
  /// In pl, this message translates to:
  /// **'Nie znaleziono typowych sygnałów nierównowagi.'**
  String get diagnosticStableParametersMessage;

  /// No description provided for @diagnosticActionStabilizeNo3.
  ///
  /// In pl, this message translates to:
  /// **'Przywróć mierzalny, stabilny poziom NO3 bez gwałtownego nawożenia.'**
  String get diagnosticActionStabilizeNo3;

  /// No description provided for @diagnosticActionSupplementPo4.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź i uzupełniaj PO4 stopniowo, kontrolując NO3.'**
  String get diagnosticActionSupplementPo4;

  /// No description provided for @diagnosticActionReduceCo2AndIncreaseSurfaceMovement.
  ///
  /// In pl, this message translates to:
  /// **'Natychmiast ogranicz CO2 i zwiększ ruch tafli wody.'**
  String get diagnosticActionReduceCo2AndIncreaseSurfaceMovement;

  /// No description provided for @diagnosticActionStabilizeCo2.
  ///
  /// In pl, this message translates to:
  /// **'Ustabilizuj podawanie CO2 i obserwuj reakcję roślin przez kilka dni.'**
  String get diagnosticActionStabilizeCo2;

  /// No description provided for @diagnosticActionStabilizeCo2AndCirculation.
  ///
  /// In pl, this message translates to:
  /// **'Utrzymuj stałe CO2 oraz popraw cyrkulację w całym zbiorniku.'**
  String get diagnosticActionStabilizeCo2AndCirculation;

  /// No description provided for @diagnosticActionReduceLighting.
  ///
  /// In pl, this message translates to:
  /// **'Na czas stabilizacji skróć świecenie do 6-8 godzin.'**
  String get diagnosticActionReduceLighting;

  /// No description provided for @diagnosticActionContinueRegularTesting.
  ///
  /// In pl, this message translates to:
  /// **'Kontynuuj regularne pomiary i utrzymuj stały harmonogram podmian.'**
  String get diagnosticActionContinueRegularTesting;

  /// No description provided for @diagnosticActionMaintainRedfieldRatio.
  ///
  /// In pl, this message translates to:
  /// **'Utrzymuj NO3:PO4 w stabilnym zakresie około 10-20:1.'**
  String get diagnosticActionMaintainRedfieldRatio;

  /// No description provided for @diagnosticRedfieldRatioNoData.
  ///
  /// In pl, this message translates to:
  /// **'Stosunek NO3:PO4: brak danych'**
  String get diagnosticRedfieldRatioNoData;

  /// No description provided for @diagnosticRedfieldRatio.
  ///
  /// In pl, this message translates to:
  /// **'Stosunek NO3:PO4: {ratio}:1'**
  String diagnosticRedfieldRatio(String ratio);

  /// No description provided for @diagnosticActionPlanTitle.
  ///
  /// In pl, this message translates to:
  /// **'Plan działania'**
  String get diagnosticActionPlanTitle;

  /// No description provided for @lastSyncLabel.
  ///
  /// In pl, this message translates to:
  /// **'Ostatnia synchronizacja:'**
  String get lastSyncLabel;

  /// No description provided for @lastSyncNone.
  ///
  /// In pl, this message translates to:
  /// **'brak zapisanych danych'**
  String get lastSyncNone;

  /// No description provided for @done.
  ///
  /// In pl, this message translates to:
  /// **'Gotowe'**
  String get done;

  /// No description provided for @editAction.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj'**
  String get editAction;

  /// No description provided for @deleteAction.
  ///
  /// In pl, this message translates to:
  /// **'Usuń'**
  String get deleteAction;

  /// No description provided for @referralTitle.
  ///
  /// In pl, this message translates to:
  /// **'Program poleceń'**
  String get referralTitle;

  /// No description provided for @referralHeroTitle.
  ///
  /// In pl, this message translates to:
  /// **'Polecaj Akwarysta PRO i zyskaj darmowy dostęp!'**
  String get referralHeroTitle;

  /// No description provided for @referralHeroDescription.
  ///
  /// In pl, this message translates to:
  /// **'Zyskaj 1 miesiąc PRO za każde 3 zaproszone osoby. Twoi znajomi otrzymają 50% zniżki na pierwszy rok.'**
  String get referralHeroDescription;

  /// No description provided for @referralCodeSection.
  ///
  /// In pl, this message translates to:
  /// **'Twój kod'**
  String get referralCodeSection;

  /// No description provided for @copyCode.
  ///
  /// In pl, this message translates to:
  /// **'Kopiuj'**
  String get copyCode;

  /// No description provided for @shareLink.
  ///
  /// In pl, this message translates to:
  /// **'Udostępnij'**
  String get shareLink;

  /// No description provided for @codeCopied.
  ///
  /// In pl, this message translates to:
  /// **'Kod został skopiowany do schowka!'**
  String get codeCopied;

  /// No description provided for @referralProgress.
  ///
  /// In pl, this message translates to:
  /// **'{count} / 3 zaliczonych poleceń'**
  String referralProgress(int count);

  /// No description provided for @invitedUsers.
  ///
  /// In pl, this message translates to:
  /// **'Zaproszone osoby'**
  String get invitedUsers;

  /// No description provided for @noReferrals.
  ///
  /// In pl, this message translates to:
  /// **'Nie masz jeszcze żadnych poleceń.'**
  String get noReferrals;

  /// No description provided for @referralAccepted.
  ///
  /// In pl, this message translates to:
  /// **'Rejestracja zaakceptowana'**
  String get referralAccepted;

  /// No description provided for @activePro.
  ///
  /// In pl, this message translates to:
  /// **'Aktywne PRO'**
  String get activePro;

  /// No description provided for @referralCompleted.
  ///
  /// In pl, this message translates to:
  /// **'Polecenie zaliczone'**
  String get referralCompleted;

  /// No description provided for @awaitingProActivation.
  ///
  /// In pl, this message translates to:
  /// **'Oczekuje na aktywację PRO'**
  String get awaitingProActivation;

  /// No description provided for @referralGoalReached.
  ///
  /// In pl, this message translates to:
  /// **'Cel osiągnięty! Twój darmowy miesiąc PRO jest gotowy.'**
  String get referralGoalReached;

  /// No description provided for @referralProgressHint.
  ///
  /// In pl, this message translates to:
  /// **'Każde aktywne polecenie przybliża Cię do darmowego miesiąca PRO.'**
  String get referralProgressHint;

  /// No description provided for @referralLoadErrorTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się załadować programu'**
  String get referralLoadErrorTitle;

  /// No description provided for @connectionRetry.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź połączenie i spróbuj ponownie.'**
  String get connectionRetry;

  /// No description provided for @retry.
  ///
  /// In pl, this message translates to:
  /// **'Spróbuj ponownie'**
  String get retry;

  /// No description provided for @refreshReferrals.
  ///
  /// In pl, this message translates to:
  /// **'Odśwież polecenia'**
  String get refreshReferrals;

  /// No description provided for @referralShareText.
  ///
  /// In pl, this message translates to:
  /// **'Dołącz do mnie w Akwarysta PRO i zgarnij 50% zniżki na pierwszy rok! Użyj mojego kodu: {code}'**
  String referralShareText(String code);

  /// No description provided for @referralCodeTooShort.
  ///
  /// In pl, this message translates to:
  /// **'Kod jest za krótki.'**
  String get referralCodeTooShort;

  /// No description provided for @referralInvalidCode.
  ///
  /// In pl, this message translates to:
  /// **'Nie znaleziono takiego kodu polecającego.'**
  String get referralInvalidCode;

  /// No description provided for @referralSelfReferral.
  ///
  /// In pl, this message translates to:
  /// **'Nie możesz użyć własnego kodu polecającego.'**
  String get referralSelfReferral;

  /// No description provided for @referralDeviceUsed.
  ///
  /// In pl, this message translates to:
  /// **'Ten kod został już wykorzystany na tym urządzeniu.'**
  String get referralDeviceUsed;

  /// No description provided for @referralAlreadyReferred.
  ///
  /// In pl, this message translates to:
  /// **'To konto ma już przypisany kod polecający.'**
  String get referralAlreadyReferred;

  /// No description provided for @referralEmailUnverified.
  ///
  /// In pl, this message translates to:
  /// **'Potwierdź adres e-mail, aby zaliczyć polecenie.'**
  String get referralEmailUnverified;

  /// No description provided for @referralOperationUnavailable.
  ///
  /// In pl, this message translates to:
  /// **'Nie można teraz wykonać tej operacji.'**
  String get referralOperationUnavailable;

  /// No description provided for @referralUnauthenticated.
  ///
  /// In pl, this message translates to:
  /// **'Sesja wygasła. Zaloguj się ponownie.'**
  String get referralUnauthenticated;

  /// No description provided for @referralUnavailable.
  ///
  /// In pl, this message translates to:
  /// **'Program poleceń jest chwilowo niedostępny. Spróbuj ponownie.'**
  String get referralUnavailable;

  /// No description provided for @referralInternal.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się przygotować kodu. Spróbuj ponownie.'**
  String get referralInternal;

  /// No description provided for @referralGenericError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wykonać operacji programu poleceń.'**
  String get referralGenericError;

  /// No description provided for @helpCenterTitle.
  ///
  /// In pl, this message translates to:
  /// **'Centrum pomocy'**
  String get helpCenterTitle;

  /// No description provided for @helpHeroTitle.
  ///
  /// In pl, this message translates to:
  /// **'Jesteśmy tu, żeby pomóc'**
  String get helpHeroTitle;

  /// No description provided for @helpHeroDescription.
  ///
  /// In pl, this message translates to:
  /// **'Opisz problem, a zespół Akwarysta PRO wróci do Ciebie z odpowiedzią.'**
  String get helpHeroDescription;

  /// No description provided for @createTicket.
  ///
  /// In pl, this message translates to:
  /// **'Utwórz nowe zgłoszenie'**
  String get createTicket;

  /// No description provided for @myTicketsCount.
  ///
  /// In pl, this message translates to:
  /// **'Moje zgłoszenia ({count})'**
  String myTicketsCount(int count);

  /// No description provided for @quickAnswers.
  ///
  /// In pl, this message translates to:
  /// **'Szybkie odpowiedzi'**
  String get quickAnswers;

  /// No description provided for @faqAiTitle.
  ///
  /// In pl, this message translates to:
  /// **'Jak działa skaner AI i weryfikacja parametrów?'**
  String get faqAiTitle;

  /// No description provided for @faqAiAnswer.
  ///
  /// In pl, this message translates to:
  /// **'Skaner AI pomaga rozpoznać problem na zdjęciu. Wyniki testów wody aplikacja porównuje z normami temperatury, pH i twardości dla wybranego akwarium.'**
  String get faqAiAnswer;

  /// No description provided for @faqNo3Title.
  ///
  /// In pl, this message translates to:
  /// **'Co zrobić, gdy azotany (NO3) są za wysokie?'**
  String get faqNo3Title;

  /// No description provided for @faqNo3Answer.
  ///
  /// In pl, this message translates to:
  /// **'Wykonaj częściową podmianę wody, ogranicz przekarmianie i sprawdź filtrację biologiczną. Powtarzaj pomiary po podmianie, zamiast obniżać NO3 gwałtownie.'**
  String get faqNo3Answer;

  /// No description provided for @faqRemindersTitle.
  ///
  /// In pl, this message translates to:
  /// **'Jak ustawić przypomnienia o podmianie i filtrze?'**
  String get faqRemindersTitle;

  /// No description provided for @faqRemindersAnswer.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz Dziennik i przypomnienia, wybierz dodanie zadania, ustaw termin oraz częstotliwość. Powiadomienia wymagają zgody systemu.'**
  String get faqRemindersAnswer;

  /// No description provided for @faqTransferTitle.
  ///
  /// In pl, this message translates to:
  /// **'Jak przenieść dane na nowe urządzenie?'**
  String get faqTransferTitle;

  /// No description provided for @faqTransferAnswer.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj się na nowym urządzeniu tym samym kontem. Dane zapisane w chmurze zostaną zsynchronizowane po chwili.'**
  String get faqTransferAnswer;

  /// No description provided for @faqSubscriptionTitle.
  ///
  /// In pl, this message translates to:
  /// **'Jak anulować lub zmienić plan PRO?'**
  String get faqSubscriptionTitle;

  /// No description provided for @faqSubscriptionAnswer.
  ///
  /// In pl, this message translates to:
  /// **'Subskrypcją zarządza się w ustawieniach Google Play lub App Store, zależnie od miejsca zakupu. Zmiany planu nie usuwają danych akwarium.'**
  String get faqSubscriptionAnswer;

  /// No description provided for @faqMultipleAquariumsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Czy mogę zarządzać kilkoma akwariami?'**
  String get faqMultipleAquariumsTitle;

  /// No description provided for @faqMultipleAquariumsAnswer.
  ///
  /// In pl, this message translates to:
  /// **'Tak. Przełączaj aktywne akwarium z poziomu zarządzania akwariami. Plan PRO nie ogranicza liczby zapisanych zbiorników.'**
  String get faqMultipleAquariumsAnswer;

  /// No description provided for @newTicketTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nowe zgłoszenie'**
  String get newTicketTitle;

  /// No description provided for @ticketCategory.
  ///
  /// In pl, this message translates to:
  /// **'Kategoria'**
  String get ticketCategory;

  /// No description provided for @adminDashboardTitle.
  ///
  /// In pl, this message translates to:
  /// **'Panel administratora'**
  String get adminDashboardTitle;

  /// No description provided for @adminDashboardSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Zarządzaj użytkownikami, zgłoszeniami i subskrypcjami'**
  String get adminDashboardSubtitle;

  /// No description provided for @adminStatsTab.
  ///
  /// In pl, this message translates to:
  /// **'Statystyki'**
  String get adminStatsTab;

  /// No description provided for @adminTicketsTab.
  ///
  /// In pl, this message translates to:
  /// **'Zgłoszenia'**
  String get adminTicketsTab;

  /// No description provided for @adminUsersTab.
  ///
  /// In pl, this message translates to:
  /// **'Użytkownicy'**
  String get adminUsersTab;

  /// No description provided for @adminAccessDenied.
  ///
  /// In pl, this message translates to:
  /// **'Wymagany dostęp administratora.'**
  String get adminAccessDenied;

  /// No description provided for @adminLoading.
  ///
  /// In pl, this message translates to:
  /// **'Wczytywanie danych administratora...'**
  String get adminLoading;

  /// No description provided for @adminLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać danych administratora: {error}'**
  String adminLoadError(String error);

  /// No description provided for @adminRetry.
  ///
  /// In pl, this message translates to:
  /// **'Spróbuj ponownie'**
  String get adminRetry;

  /// No description provided for @adminTotalUsers.
  ///
  /// In pl, this message translates to:
  /// **'Zarejestrowani użytkownicy'**
  String get adminTotalUsers;

  /// No description provided for @adminActivePro.
  ///
  /// In pl, this message translates to:
  /// **'Aktywne PRO'**
  String get adminActivePro;

  /// No description provided for @adminMonthlyPlans.
  ///
  /// In pl, this message translates to:
  /// **'Plany miesięczne'**
  String get adminMonthlyPlans;

  /// No description provided for @adminYearlyPlans.
  ///
  /// In pl, this message translates to:
  /// **'Plany roczne'**
  String get adminYearlyPlans;

  /// No description provided for @adminManualGrants.
  ///
  /// In pl, this message translates to:
  /// **'Ręczne nadania'**
  String get adminManualGrants;

  /// No description provided for @adminTotalTickets.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie zgłoszenia'**
  String get adminTotalTickets;

  /// No description provided for @adminOpenTickets.
  ///
  /// In pl, this message translates to:
  /// **'Otwarte zgłoszenia'**
  String get adminOpenTickets;

  /// No description provided for @adminSuccessfulReferrals.
  ///
  /// In pl, this message translates to:
  /// **'Pomyślne polecenia'**
  String get adminSuccessfulReferrals;

  /// No description provided for @adminFilterAll.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie'**
  String get adminFilterAll;

  /// No description provided for @adminFilterOpen.
  ///
  /// In pl, this message translates to:
  /// **'Otwarte'**
  String get adminFilterOpen;

  /// No description provided for @adminFilterInProgress.
  ///
  /// In pl, this message translates to:
  /// **'W trakcie'**
  String get adminFilterInProgress;

  /// No description provided for @adminFilterClosed.
  ///
  /// In pl, this message translates to:
  /// **'Zamknięte'**
  String get adminFilterClosed;

  /// No description provided for @adminNoTickets.
  ///
  /// In pl, this message translates to:
  /// **'Brak zgłoszeń do wyświetlenia.'**
  String get adminNoTickets;

  /// No description provided for @adminStatusOpen.
  ///
  /// In pl, this message translates to:
  /// **'Otwarte'**
  String get adminStatusOpen;

  /// No description provided for @adminStatusInProgress.
  ///
  /// In pl, this message translates to:
  /// **'W trakcie'**
  String get adminStatusInProgress;

  /// No description provided for @adminStatusResolved.
  ///
  /// In pl, this message translates to:
  /// **'Rozwiązane'**
  String get adminStatusResolved;

  /// No description provided for @adminStatusClosed.
  ///
  /// In pl, this message translates to:
  /// **'Zamknięte'**
  String get adminStatusClosed;

  /// No description provided for @adminTicketDetails.
  ///
  /// In pl, this message translates to:
  /// **'Szczegóły zgłoszenia'**
  String get adminTicketDetails;

  /// No description provided for @adminTicketDescription.
  ///
  /// In pl, this message translates to:
  /// **'Treść zgłoszenia'**
  String get adminTicketDescription;

  /// No description provided for @adminTicketEmail.
  ///
  /// In pl, this message translates to:
  /// **'E-mail zgłaszającego'**
  String get adminTicketEmail;

  /// No description provided for @adminTicketCategory.
  ///
  /// In pl, this message translates to:
  /// **'Kategoria'**
  String get adminTicketCategory;

  /// No description provided for @adminTicketCreated.
  ///
  /// In pl, this message translates to:
  /// **'Utworzono: {date}'**
  String adminTicketCreated(String date);

  /// No description provided for @adminTicketAttachment.
  ///
  /// In pl, this message translates to:
  /// **'Załącznik'**
  String get adminTicketAttachment;

  /// No description provided for @adminSupportReply.
  ///
  /// In pl, this message translates to:
  /// **'Odpowiedź wsparcia'**
  String get adminSupportReply;

  /// No description provided for @adminSaveTicket.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz zgłoszenie'**
  String get adminSaveTicket;

  /// No description provided for @adminTicketSaved.
  ///
  /// In pl, this message translates to:
  /// **'Zgłoszenie zostało zaktualizowane.'**
  String get adminTicketSaved;

  /// No description provided for @adminSearchUsers.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj po imieniu lub e-mailu'**
  String get adminSearchUsers;

  /// No description provided for @adminNoUsers.
  ///
  /// In pl, this message translates to:
  /// **'Nie znaleziono użytkowników.'**
  String get adminNoUsers;

  /// No description provided for @adminFreePlan.
  ///
  /// In pl, this message translates to:
  /// **'Darmowe'**
  String get adminFreePlan;

  /// No description provided for @adminProPlan.
  ///
  /// In pl, this message translates to:
  /// **'PRO'**
  String get adminProPlan;

  /// No description provided for @adminReferralsCount.
  ///
  /// In pl, this message translates to:
  /// **'{count} pomyślnych poleceń'**
  String adminReferralsCount(int count);

  /// No description provided for @adminUserDetails.
  ///
  /// In pl, this message translates to:
  /// **'Szczegóły użytkownika'**
  String get adminUserDetails;

  /// No description provided for @adminUserEmail.
  ///
  /// In pl, this message translates to:
  /// **'E-mail'**
  String get adminUserEmail;

  /// No description provided for @adminSubscriptionPlan.
  ///
  /// In pl, this message translates to:
  /// **'Plan subskrypcji'**
  String get adminSubscriptionPlan;

  /// No description provided for @adminExpiryDate.
  ///
  /// In pl, this message translates to:
  /// **'Wygasa: {date}'**
  String adminExpiryDate(String date);

  /// No description provided for @adminNoExpiry.
  ///
  /// In pl, this message translates to:
  /// **'Bezterminowo'**
  String get adminNoExpiry;

  /// No description provided for @adminGrantPro.
  ///
  /// In pl, this message translates to:
  /// **'Nadaj PRO'**
  String get adminGrantPro;

  /// No description provided for @adminRevokePro.
  ///
  /// In pl, this message translates to:
  /// **'Odbierz PRO'**
  String get adminRevokePro;

  /// No description provided for @adminGrantProTitle.
  ///
  /// In pl, this message translates to:
  /// **'Przyznaj dostęp PRO'**
  String get adminGrantProTitle;

  /// No description provided for @adminGrantDuration.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz czas dostępu'**
  String get adminGrantDuration;

  /// No description provided for @adminDuration7Days.
  ///
  /// In pl, this message translates to:
  /// **'7 dni'**
  String get adminDuration7Days;

  /// No description provided for @adminDuration14Days.
  ///
  /// In pl, this message translates to:
  /// **'14 dni'**
  String get adminDuration14Days;

  /// No description provided for @adminDuration1Month.
  ///
  /// In pl, this message translates to:
  /// **'1 miesiąc'**
  String get adminDuration1Month;

  /// No description provided for @adminDuration1Year.
  ///
  /// In pl, this message translates to:
  /// **'1 rok'**
  String get adminDuration1Year;

  /// No description provided for @adminDurationIndefinite.
  ///
  /// In pl, this message translates to:
  /// **'Bezterminowo'**
  String get adminDurationIndefinite;

  /// No description provided for @adminGrantSuccess.
  ///
  /// In pl, this message translates to:
  /// **'Dostęp PRO został przyznany.'**
  String get adminGrantSuccess;

  /// No description provided for @adminRevokeSuccess.
  ///
  /// In pl, this message translates to:
  /// **'Dostęp PRO został odebrany.'**
  String get adminRevokeSuccess;

  /// No description provided for @adminInvitedUsers.
  ///
  /// In pl, this message translates to:
  /// **'Zaproszone osoby'**
  String get adminInvitedUsers;

  /// No description provided for @adminNoInvitedUsers.
  ///
  /// In pl, this message translates to:
  /// **'Brak zaproszonych osób.'**
  String get adminNoInvitedUsers;

  /// No description provided for @adminReferralPending.
  ///
  /// In pl, this message translates to:
  /// **'Oczekujące'**
  String get adminReferralPending;

  /// No description provided for @adminReferralCompleted.
  ///
  /// In pl, this message translates to:
  /// **'Zakończone'**
  String get adminReferralCompleted;

  /// No description provided for @adminNameUnavailable.
  ///
  /// In pl, this message translates to:
  /// **'Brak nazwy'**
  String get adminNameUnavailable;

  /// No description provided for @adminConfirmRevokeTitle.
  ///
  /// In pl, this message translates to:
  /// **'Odebrać dostęp PRO?'**
  String get adminConfirmRevokeTitle;

  /// No description provided for @adminConfirmRevokeBody.
  ///
  /// In pl, this message translates to:
  /// **'Użytkownik natychmiast utraci dostęp PRO.'**
  String get adminConfirmRevokeBody;

  /// No description provided for @adminConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Potwierdź'**
  String get adminConfirm;

  /// No description provided for @adminCancel.
  ///
  /// In pl, this message translates to:
  /// **'Anuluj'**
  String get adminCancel;

  /// No description provided for @ticketBugCategory.
  ///
  /// In pl, this message translates to:
  /// **'🐛 Zgłoś błąd w aplikacji'**
  String get ticketBugCategory;

  /// No description provided for @ticketFeatureCategory.
  ///
  /// In pl, this message translates to:
  /// **'💡 Propozycja funkcji / pomysł'**
  String get ticketFeatureCategory;

  /// No description provided for @ticketSubscriptionCategory.
  ///
  /// In pl, this message translates to:
  /// **'💳 Problem z płatnością / subskrypcją PRO'**
  String get ticketSubscriptionCategory;

  /// No description provided for @ticketBusinessCategory.
  ///
  /// In pl, this message translates to:
  /// **'🤝 Współpraca / kontakt biznesowy'**
  String get ticketBusinessCategory;

  /// No description provided for @ticketOtherCategory.
  ///
  /// In pl, this message translates to:
  /// **'❓ Inne zapytanie'**
  String get ticketOtherCategory;

  /// No description provided for @ticketSubject.
  ///
  /// In pl, this message translates to:
  /// **'Tytuł'**
  String get ticketSubject;

  /// No description provided for @ticketSubjectHint.
  ///
  /// In pl, this message translates to:
  /// **'Krótko opisz problem'**
  String get ticketSubjectHint;

  /// No description provided for @ticketDescription.
  ///
  /// In pl, this message translates to:
  /// **'Szczegółowy opis'**
  String get ticketDescription;

  /// No description provided for @ticketDescriptionHint.
  ///
  /// In pl, this message translates to:
  /// **'Co się wydarzyło? Jak można odtworzyć problem?'**
  String get ticketDescriptionHint;

  /// No description provided for @ticketDescriptionMin.
  ///
  /// In pl, this message translates to:
  /// **'Opis musi mieć co najmniej 15 znaków.'**
  String get ticketDescriptionMin;

  /// No description provided for @ticketSubjectRequired.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz tytuł zgłoszenia.'**
  String get ticketSubjectRequired;

  /// No description provided for @ticketAuthRequired.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj się, aby wysłać zgłoszenie.'**
  String get ticketAuthRequired;

  /// No description provided for @ticketPermissionError.
  ///
  /// In pl, this message translates to:
  /// **'Brak uprawnień do zgłoszeń. Zaloguj się ponownie.'**
  String get ticketPermissionError;

  /// No description provided for @ticketOfflineError.
  ///
  /// In pl, this message translates to:
  /// **'Brak połączenia z internetem. Sprawdź sieć i spróbuj ponownie.'**
  String get ticketOfflineError;

  /// No description provided for @ticketIndexError.
  ///
  /// In pl, this message translates to:
  /// **'Nie można pobrać zgłoszeń. Baza danych wymaga indeksu Firestore.'**
  String get ticketIndexError;

  /// No description provided for @ticketGenericError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wykonać operacji. Spróbuj ponownie.'**
  String get ticketGenericError;

  /// No description provided for @attachImage.
  ///
  /// In pl, this message translates to:
  /// **'Załącz zdjęcie / zrzut ekranu'**
  String get attachImage;

  /// No description provided for @changeAttachment.
  ///
  /// In pl, this message translates to:
  /// **'Zmień załącznik: {name}'**
  String changeAttachment(String name);

  /// No description provided for @removeAttachment.
  ///
  /// In pl, this message translates to:
  /// **'Usuń załącznik'**
  String get removeAttachment;

  /// No description provided for @sendingTicket.
  ///
  /// In pl, this message translates to:
  /// **'Wysyłanie...'**
  String get sendingTicket;

  /// No description provided for @sendTicket.
  ///
  /// In pl, this message translates to:
  /// **'Wyślij zgłoszenie'**
  String get sendTicket;

  /// No description provided for @ticketSent.
  ///
  /// In pl, this message translates to:
  /// **'Zgłoszenie zostało wysłane.'**
  String get ticketSent;

  /// No description provided for @ticketPhotoReadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się odczytać zdjęcia: {error}'**
  String ticketPhotoReadError(String error);

  /// No description provided for @myTicketsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Moje zgłoszenia'**
  String get myTicketsTitle;

  /// No description provided for @noTickets.
  ///
  /// In pl, this message translates to:
  /// **'Nie masz jeszcze żadnych zgłoszeń.'**
  String get noTickets;

  /// No description provided for @ticketDetails.
  ///
  /// In pl, this message translates to:
  /// **'Szczegóły zgłoszenia'**
  String get ticketDetails;

  /// No description provided for @ticketSupportReply.
  ///
  /// In pl, this message translates to:
  /// **'Odpowiedź od wsparcia'**
  String get ticketSupportReply;

  /// No description provided for @ticketCreatedAt.
  ///
  /// In pl, this message translates to:
  /// **'Utworzono: {date}'**
  String ticketCreatedAt(String date);

  /// No description provided for @ticketDescriptionSection.
  ///
  /// In pl, this message translates to:
  /// **'Opis zgłoszenia'**
  String get ticketDescriptionSection;

  /// No description provided for @ticketTechnicalInfo.
  ///
  /// In pl, this message translates to:
  /// **'Informacje techniczne'**
  String get ticketTechnicalInfo;

  /// No description provided for @ticketAttachmentError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wyświetlić załącznika.'**
  String get ticketAttachmentError;

  /// No description provided for @ticketStatusOpen.
  ///
  /// In pl, this message translates to:
  /// **'Otwarte'**
  String get ticketStatusOpen;

  /// No description provided for @ticketStatusInProgress.
  ///
  /// In pl, this message translates to:
  /// **'W trakcie'**
  String get ticketStatusInProgress;

  /// No description provided for @ticketStatusResolved.
  ///
  /// In pl, this message translates to:
  /// **'Rozwiązane'**
  String get ticketStatusResolved;

  /// No description provided for @ticketStatusClosed.
  ///
  /// In pl, this message translates to:
  /// **'Zamknięte'**
  String get ticketStatusClosed;

  /// No description provided for @categoryShrimp.
  ///
  /// In pl, this message translates to:
  /// **'Krewetki'**
  String get categoryShrimp;

  /// No description provided for @categorySnails.
  ///
  /// In pl, this message translates to:
  /// **'Ślimaki'**
  String get categorySnails;

  /// No description provided for @categoryCrabs.
  ///
  /// In pl, this message translates to:
  /// **'Kraby'**
  String get categoryCrabs;

  /// No description provided for @categoryCorals.
  ///
  /// In pl, this message translates to:
  /// **'Korale'**
  String get categoryCorals;

  /// No description provided for @feedingNotes.
  ///
  /// In pl, this message translates to:
  /// **'Karmienie'**
  String get feedingNotes;

  /// No description provided for @behaviorNotes.
  ///
  /// In pl, this message translates to:
  /// **'Zachowanie'**
  String get behaviorNotes;

  /// No description provided for @careNotes.
  ///
  /// In pl, this message translates to:
  /// **'Wymagania pielęgnacyjne'**
  String get careNotes;

  /// No description provided for @compatibilityNotChecked.
  ///
  /// In pl, this message translates to:
  /// **'Niepełna ocena'**
  String get compatibilityNotChecked;

  /// No description provided for @livestockUnverifiedSpecies.
  ///
  /// In pl, this message translates to:
  /// **'Nie oceniono {count} pozycji spoza katalogu. Sprawdź ich wymagania ręcznie.'**
  String livestockUnverifiedSpecies(int count);

  /// No description provided for @categoryOther.
  ///
  /// In pl, this message translates to:
  /// **'Inne'**
  String get categoryOther;

  /// No description provided for @categoryFauna.
  ///
  /// In pl, this message translates to:
  /// **'Fauna'**
  String get categoryFauna;

  /// No description provided for @categoryFlora.
  ///
  /// In pl, this message translates to:
  /// **'Flora'**
  String get categoryFlora;

  /// No description provided for @speciesCategoryLabel.
  ///
  /// In pl, this message translates to:
  /// **'Gatunki'**
  String get speciesCategoryLabel;

  /// No description provided for @category.
  ///
  /// In pl, this message translates to:
  /// **'Kategoria'**
  String get category;

  /// No description provided for @livestockCount.
  ///
  /// In pl, this message translates to:
  /// **'Liczba: {count}'**
  String livestockCount(int count);

  /// No description provided for @plantPositionForeground.
  ///
  /// In pl, this message translates to:
  /// **'I plan'**
  String get plantPositionForeground;

  /// No description provided for @plantPositionMidground.
  ///
  /// In pl, this message translates to:
  /// **'II plan'**
  String get plantPositionMidground;

  /// No description provided for @plantPositionBackground.
  ///
  /// In pl, this message translates to:
  /// **'III plan'**
  String get plantPositionBackground;

  /// No description provided for @plantPositionEpiphyte.
  ///
  /// In pl, this message translates to:
  /// **'Epifit'**
  String get plantPositionEpiphyte;

  /// No description provided for @plantPositionFloating.
  ///
  /// In pl, this message translates to:
  /// **'Pływająca'**
  String get plantPositionFloating;

  /// No description provided for @plantPositionFieldLabel.
  ///
  /// In pl, this message translates to:
  /// **'Pozycja rośliny'**
  String get plantPositionFieldLabel;

  /// No description provided for @journalCategoryObservation.
  ///
  /// In pl, this message translates to:
  /// **'Obserwacja'**
  String get journalCategoryObservation;

  /// No description provided for @journalCategoryFishHealth.
  ///
  /// In pl, this message translates to:
  /// **'Zdrowie ryb'**
  String get journalCategoryFishHealth;

  /// No description provided for @journalCategoryPlantGrowth.
  ///
  /// In pl, this message translates to:
  /// **'Wzrost roślin'**
  String get journalCategoryPlantGrowth;

  /// No description provided for @journalCategoryAlgae.
  ///
  /// In pl, this message translates to:
  /// **'Glony'**
  String get journalCategoryAlgae;

  /// No description provided for @journalCategoryEquipment.
  ///
  /// In pl, this message translates to:
  /// **'Sprzęt / inwestycje'**
  String get journalCategoryEquipment;

  /// No description provided for @aquariumsSectionTitle.
  ///
  /// In pl, this message translates to:
  /// **'Moje akwaria'**
  String get aquariumsSectionTitle;

  /// No description provided for @cloudSyncSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Dane synchronizowane w chmurze'**
  String get cloudSyncSubtitle;

  /// No description provided for @addAquariumTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj akwarium'**
  String get addAquariumTooltip;

  /// No description provided for @aquariumAddedMessage.
  ///
  /// In pl, this message translates to:
  /// **'Akwarium zostało dodane.'**
  String get aquariumAddedMessage;

  /// No description provided for @aquariumUpdatedMessage.
  ///
  /// In pl, this message translates to:
  /// **'Akwarium zostało zapisane.'**
  String get aquariumUpdatedMessage;

  /// No description provided for @deleteAquariumTitle.
  ///
  /// In pl, this message translates to:
  /// **'Usunąć akwarium?'**
  String get deleteAquariumTitle;

  /// No description provided for @deleteAquariumPrompt.
  ///
  /// In pl, this message translates to:
  /// **'Akwarium „{name}” i wszystkie jego pomiary zostaną usunięte.'**
  String deleteAquariumPrompt(String name);

  /// No description provided for @aquariumDeletedMessage.
  ///
  /// In pl, this message translates to:
  /// **'Akwarium zostało usunięte.'**
  String get aquariumDeletedMessage;

  /// No description provided for @aquariumLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać akwariów. Spróbuj ponownie.'**
  String get aquariumLoadError;

  /// No description provided for @aquariumPickerLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać akwariów: {error}'**
  String aquariumPickerLoadError(String error);

  /// No description provided for @aquariumEstablishedOn.
  ///
  /// In pl, this message translates to:
  /// **'Założone {date}'**
  String aquariumEstablishedOn(String date);

  /// No description provided for @addAquariumTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj akwarium'**
  String get addAquariumTitle;

  /// No description provided for @aquariumNameLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa akwarium'**
  String get aquariumNameLabel;

  /// No description provided for @aquariumNameRequired.
  ///
  /// In pl, this message translates to:
  /// **'Podaj nazwę akwarium.'**
  String get aquariumNameRequired;

  /// No description provided for @aquariumCapacityLabel.
  ///
  /// In pl, this message translates to:
  /// **'Pojemność'**
  String get aquariumCapacityLabel;

  /// No description provided for @aquariumCapacityInvalid.
  ///
  /// In pl, this message translates to:
  /// **'Podaj pojemność większą od zera.'**
  String get aquariumCapacityInvalid;

  /// No description provided for @aquariumTypeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Typ akwarium'**
  String get aquariumTypeLabel;

  /// No description provided for @aquariumSetupDateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Data założenia'**
  String get aquariumSetupDateLabel;

  /// No description provided for @aquariumOptionsTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Opcje akwarium'**
  String get aquariumOptionsTooltip;

  /// No description provided for @noAquariumsAdded.
  ///
  /// In pl, this message translates to:
  /// **'Brak dodanych akwariów'**
  String get noAquariumsAdded;

  /// No description provided for @addFirstAquariumAction.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwsze akwarium'**
  String get addFirstAquariumAction;

  /// No description provided for @aquariumDetailsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Szczegóły akwarium'**
  String get aquariumDetailsTitle;

  /// No description provided for @aquariumDetailsLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać szczegółów akwarium.'**
  String get aquariumDetailsLoadError;

  /// No description provided for @noWaterMeasurements.
  ///
  /// In pl, this message translates to:
  /// **'Brak pomiarów parametrów wody.'**
  String get noWaterMeasurements;

  /// No description provided for @reportPdfAction.
  ///
  /// In pl, this message translates to:
  /// **'Generuj raport PDF'**
  String get reportPdfAction;

  /// No description provided for @reportProHeadline.
  ///
  /// In pl, this message translates to:
  /// **'Generuj profesjonalne raporty PDF swoich akwariów z Akwarysta PRO.'**
  String get reportProHeadline;

  /// No description provided for @reportGenerationError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wygenerować raportu: {error}'**
  String reportGenerationError(String error);

  /// No description provided for @estimatedWeightLabel.
  ///
  /// In pl, this message translates to:
  /// **'Szacowana waga'**
  String get estimatedWeightLabel;

  /// No description provided for @browseSpeciesAtlas.
  ///
  /// In pl, this message translates to:
  /// **'Przeglądaj atlas gatunków'**
  String get browseSpeciesAtlas;

  /// No description provided for @addCustomSpecies.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj własny gatunek'**
  String get addCustomSpecies;

  /// No description provided for @speciesNameLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa gatunkowa'**
  String get speciesNameLabel;

  /// No description provided for @speciesNameRequired.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz nazwę gatunku.'**
  String get speciesNameRequired;

  /// No description provided for @latinNameOptionalLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa łacińska (opcjonalnie)'**
  String get latinNameOptionalLabel;

  /// No description provided for @speciesCountLabel.
  ///
  /// In pl, this message translates to:
  /// **'Liczba sztuk'**
  String get speciesCountLabel;

  /// No description provided for @positiveCountRequired.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz liczbę większą od zera.'**
  String get positiveCountRequired;

  /// No description provided for @addFirstSpecies.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwszy gatunek'**
  String get addFirstSpecies;

  /// No description provided for @livestockLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać obsady akwarium.'**
  String get livestockLoadError;

  /// No description provided for @livestockSyncError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zsynchronizować obsady: {error}'**
  String livestockSyncError(String error);

  /// No description provided for @signInToViewLivestock.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj się, aby zobaczyć obsadę.'**
  String get signInToViewLivestock;

  /// No description provided for @unknownSpecies.
  ///
  /// In pl, this message translates to:
  /// **'Nieznany gatunek'**
  String get unknownSpecies;

  /// No description provided for @addedOnDate.
  ///
  /// In pl, this message translates to:
  /// **'Dodano: {date}'**
  String addedOnDate(String date);

  /// No description provided for @decreaseQuantityTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Zmniejsz ilość'**
  String get decreaseQuantityTooltip;

  /// No description provided for @increaseQuantityTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Zwiększ ilość'**
  String get increaseQuantityTooltip;

  /// No description provided for @stockHealthTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zdrowie i zgodność obsady'**
  String get stockHealthTitle;

  /// No description provided for @livestockWarnings.
  ///
  /// In pl, this message translates to:
  /// **'Ostrzeżenia'**
  String get livestockWarnings;

  /// No description provided for @livestockCompatible.
  ///
  /// In pl, this message translates to:
  /// **'Zgodna'**
  String get livestockCompatible;

  /// No description provided for @minimumVolumeForStock.
  ///
  /// In pl, this message translates to:
  /// **'Minimalna objętość dla obsady: {required} l / {capacity} l'**
  String minimumVolumeForStock(int required, String capacity);

  /// No description provided for @stockCapacityExceeded.
  ///
  /// In pl, this message translates to:
  /// **'Wymagania obsady przekraczają pojemność akwarium o {liters} l.'**
  String stockCapacityExceeded(int liters);

  /// No description provided for @noSharedRangeFor.
  ///
  /// In pl, this message translates to:
  /// **'Brak wspólnego zakresu dla: {conflicts}'**
  String noSharedRangeFor(String conflicts);

  /// No description provided for @calendarTasksTitle.
  ///
  /// In pl, this message translates to:
  /// **'Kalendarz zadań'**
  String get calendarTasksTitle;

  /// No description provided for @addTask.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj zadanie'**
  String get addTask;

  /// No description provided for @newTask.
  ///
  /// In pl, this message translates to:
  /// **'Nowe zadanie'**
  String get newTask;

  /// No description provided for @taskTitleLabel.
  ///
  /// In pl, this message translates to:
  /// **'Tytuł'**
  String get taskTitleLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In pl, this message translates to:
  /// **'Opis'**
  String get descriptionLabel;

  /// No description provided for @reminderTimeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Godzina przypomnienia'**
  String get reminderTimeLabel;

  /// No description provided for @noteLabel.
  ///
  /// In pl, this message translates to:
  /// **'Notatka'**
  String get noteLabel;

  /// No description provided for @tagsCommaSeparated.
  ///
  /// In pl, this message translates to:
  /// **'Tagi, oddziel przecinkami'**
  String get tagsCommaSeparated;

  /// No description provided for @attachLatestWaterMeasurement.
  ///
  /// In pl, this message translates to:
  /// **'Podepnij ostatni pomiar wody'**
  String get attachLatestWaterMeasurement;

  /// No description provided for @photosReadyToSave.
  ///
  /// In pl, this message translates to:
  /// **'{count} zdjęć gotowych do zapisu'**
  String photosReadyToSave(int count);

  /// No description provided for @entryAddedMessage.
  ///
  /// In pl, this message translates to:
  /// **'Wpis został dodany.'**
  String get entryAddedMessage;

  /// No description provided for @reminderAddedMessage.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienie zostało dodane.'**
  String get reminderAddedMessage;

  /// No description provided for @addEntryTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj wpis'**
  String get addEntryTooltip;

  /// No description provided for @addReminderTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj przypomnienie'**
  String get addReminderTooltip;

  /// No description provided for @calendarLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać kalendarza. Spróbuj ponownie później.'**
  String get calendarLoadError;

  /// No description provided for @journalLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać dziennika.'**
  String get journalLoadError;

  /// No description provided for @noJournalEntries.
  ///
  /// In pl, this message translates to:
  /// **'Brak wpisów. Dodaj pierwszą obserwację.'**
  String get noJournalEntries;

  /// No description provided for @compareBeforeAfterTitle.
  ///
  /// In pl, this message translates to:
  /// **'Porównywarka przed / po'**
  String get compareBeforeAfterTitle;

  /// No description provided for @photoCompareMinimumCount.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj co najmniej dwa zdjęcia do dziennika.'**
  String get photoCompareMinimumCount;

  /// No description provided for @photoThen.
  ///
  /// In pl, this message translates to:
  /// **'Wtedy'**
  String get photoThen;

  /// No description provided for @photoNow.
  ///
  /// In pl, this message translates to:
  /// **'Teraz'**
  String get photoNow;

  /// No description provided for @showPassword.
  ///
  /// In pl, this message translates to:
  /// **'Pokaż hasło'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In pl, this message translates to:
  /// **'Ukryj hasło'**
  String get hidePassword;

  /// No description provided for @back.
  ///
  /// In pl, this message translates to:
  /// **'Wróć'**
  String get back;

  /// No description provided for @referralCodeOptional.
  ///
  /// In pl, this message translates to:
  /// **'Masz kod polecający? (opcjonalnie)'**
  String get referralCodeOptional;

  /// No description provided for @firebaseGenericError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się połączyć z Firebase.'**
  String get firebaseGenericError;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In pl, this message translates to:
  /// **'Resetowanie hasła'**
  String get resetPasswordTitle;

  /// No description provided for @emailAddressLabel.
  ///
  /// In pl, this message translates to:
  /// **'Adres e-mail'**
  String get emailAddressLabel;

  /// No description provided for @sendResetLinkAction.
  ///
  /// In pl, this message translates to:
  /// **'Wyślij link'**
  String get sendResetLinkAction;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In pl, this message translates to:
  /// **'Link do resetu hasła został wysłany.'**
  String get passwordResetSuccess;

  /// No description provided for @signInToViewPhotos.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj się, aby zobaczyć zdjęcia.'**
  String get signInToViewPhotos;

  /// No description provided for @photoLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać zdjęć.'**
  String get photoLoadError;

  /// No description provided for @compareFirstLatestPhotos.
  ///
  /// In pl, this message translates to:
  /// **'Porównaj pierwsze i najnowsze zdjęcie'**
  String get compareFirstLatestPhotos;

  /// No description provided for @unlimitedPhotoJournal.
  ///
  /// In pl, this message translates to:
  /// **'Nielimitowany dziennik zdjęć'**
  String get unlimitedPhotoJournal;

  /// No description provided for @photoSavedMessage.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcie zostało zapisane.'**
  String get photoSavedMessage;

  /// No description provided for @photoCaptionTitle.
  ///
  /// In pl, this message translates to:
  /// **'Opis zdjęcia'**
  String get photoCaptionTitle;

  /// No description provided for @optionalPhotoDescription.
  ///
  /// In pl, this message translates to:
  /// **'Opcjonalny opis'**
  String get optionalPhotoDescription;

  /// No description provided for @mainPhoto.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcie główne'**
  String get mainPhoto;

  /// No description provided for @setAsAquariumCover.
  ///
  /// In pl, this message translates to:
  /// **'Ustaw jako okładkę akwarium'**
  String get setAsAquariumCover;

  /// No description provided for @twoPhotosRequired.
  ///
  /// In pl, this message translates to:
  /// **'Potrzebujesz co najmniej dwóch zdjęć.'**
  String get twoPhotosRequired;

  /// No description provided for @compareProgressTitle.
  ///
  /// In pl, this message translates to:
  /// **'Porównaj postęp'**
  String get compareProgressTitle;

  /// No description provided for @maintenanceScheduleTitle.
  ///
  /// In pl, this message translates to:
  /// **'Harmonogram pielęgnacji'**
  String get maintenanceScheduleTitle;

  /// No description provided for @maintenanceLoadError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wczytać harmonogramu.'**
  String get maintenanceLoadError;

  /// No description provided for @maintenanceEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Nie dodano jeszcze zadań pielęgnacyjnych.'**
  String get maintenanceEmpty;

  /// No description provided for @maintenanceTaskAddedError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się dodać zadania: {error}'**
  String maintenanceTaskAddedError(String error);

  /// No description provided for @maintenanceTaskUpdateError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zaktualizować zadania: {error}'**
  String maintenanceTaskUpdateError(String error);

  /// No description provided for @maintenanceTaskCompleted.
  ///
  /// In pl, this message translates to:
  /// **'Wykonano: {title}'**
  String maintenanceTaskCompleted(String title);

  /// No description provided for @editTaskTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj zadanie'**
  String get editTaskTooltip;

  /// No description provided for @performTask.
  ///
  /// In pl, this message translates to:
  /// **'Wykonaj'**
  String get performTask;

  /// No description provided for @taskOverdue.
  ///
  /// In pl, this message translates to:
  /// **'Po terminie!'**
  String get taskOverdue;

  /// No description provided for @taskDueInDays.
  ///
  /// In pl, this message translates to:
  /// **'Za {days} dni'**
  String taskDueInDays(int days);

  /// No description provided for @maintenanceTaskTypeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Rodzaj zadania'**
  String get maintenanceTaskTypeLabel;

  /// No description provided for @maintenanceLastPerformed.
  ///
  /// In pl, this message translates to:
  /// **'Ostatnio wykonano'**
  String get maintenanceLastPerformed;

  /// No description provided for @maintenanceTaskFeeding.
  ///
  /// In pl, this message translates to:
  /// **'Karmienie'**
  String get maintenanceTaskFeeding;

  /// No description provided for @maintenanceTaskWaterChange.
  ///
  /// In pl, this message translates to:
  /// **'Podmiana wody'**
  String get maintenanceTaskWaterChange;

  /// No description provided for @maintenanceTaskFilterCleaning.
  ///
  /// In pl, this message translates to:
  /// **'Czyszczenie filtra'**
  String get maintenanceTaskFilterCleaning;

  /// No description provided for @maintenanceTaskPlantTrimming.
  ///
  /// In pl, this message translates to:
  /// **'Przycinanie roślin'**
  String get maintenanceTaskPlantTrimming;

  /// No description provided for @maintenanceTaskFertilizing.
  ///
  /// In pl, this message translates to:
  /// **'Nawożenie'**
  String get maintenanceTaskFertilizing;

  /// No description provided for @maintenanceTaskQuickCheck.
  ///
  /// In pl, this message translates to:
  /// **'Szybka kontrola'**
  String get maintenanceTaskQuickCheck;

  /// No description provided for @maintenanceTaskCustom.
  ///
  /// In pl, this message translates to:
  /// **'Inne zadanie'**
  String get maintenanceTaskCustom;

  /// No description provided for @editMaintenanceTask.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj zadanie'**
  String get editMaintenanceTask;

  /// No description provided for @addMaintenanceTask.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj zadanie pielęgnacyjne'**
  String get addMaintenanceTask;

  /// No description provided for @fertilizerDoseInstructions.
  ///
  /// In pl, this message translates to:
  /// **'Podaj pojemność akwarium i wybierz rodzaj nawozu.'**
  String get fertilizerDoseInstructions;

  /// No description provided for @fertilizerVolumeExample.
  ///
  /// In pl, this message translates to:
  /// **'np. 100'**
  String get fertilizerVolumeExample;

  /// No description provided for @litersUnit.
  ///
  /// In pl, this message translates to:
  /// **'litrów'**
  String get litersUnit;

  /// No description provided for @fertilizerTypeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Rodzaj nawozu'**
  String get fertilizerTypeLabel;

  /// No description provided for @fertilizerMicro.
  ///
  /// In pl, this message translates to:
  /// **'Nawóz Mikro'**
  String get fertilizerMicro;

  /// No description provided for @fertilizerMacroNpk.
  ///
  /// In pl, this message translates to:
  /// **'Nawóz Makro (NPK)'**
  String get fertilizerMacroNpk;

  /// No description provided for @fertilizerPotassium.
  ///
  /// In pl, this message translates to:
  /// **'Potas (K)'**
  String get fertilizerPotassium;

  /// No description provided for @calculateDoseAction.
  ///
  /// In pl, this message translates to:
  /// **'Oblicz dawkę'**
  String get calculateDoseAction;

  /// No description provided for @enterAquariumVolume.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz pojemność akwarium.'**
  String get enterAquariumVolume;

  /// No description provided for @enterPositiveNumber.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz liczbę większą od zera.'**
  String get enterPositiveNumber;

  /// No description provided for @calculatorInvalidValues.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź wpisane wartości. Wymiary i objętość akwarium muszą być prawidłowe.'**
  String get calculatorInvalidValues;

  /// No description provided for @netCapacitySaved.
  ///
  /// In pl, this message translates to:
  /// **'Zapisano pojemność netto: {liters} l'**
  String netCapacitySaved(String liters);

  /// No description provided for @ammoniaNonDetectableTarget.
  ///
  /// In pl, this message translates to:
  /// **'Cel: poziom niewykrywalny (0 mg/L)'**
  String get ammoniaNonDetectableTarget;

  /// No description provided for @nitriteNonDetectableTarget.
  ///
  /// In pl, this message translates to:
  /// **'Cel: poziom niewykrywalny (0 mg/L)'**
  String get nitriteNonDetectableTarget;

  /// No description provided for @waterAssessmentNitriteDetected.
  ///
  /// In pl, this message translates to:
  /// **'Wykryto NO2. Azotyny są szkodliwe dla ryb; sprawdź pomiar i zareaguj szybko.'**
  String get waterAssessmentNitriteDetected;

  /// No description provided for @waterAssessmentAmmoniaDetected.
  ///
  /// In pl, this message translates to:
  /// **'Wykryto NH3/NH4. Nawet niskie stężenie może szkodzić; ryzyko zależy od pH i temperatury.'**
  String get waterAssessmentAmmoniaDetected;

  /// No description provided for @waterAssessmentReferenceOnly.
  ///
  /// In pl, this message translates to:
  /// **'Informacja orientacyjna'**
  String get waterAssessmentReferenceOnly;

  /// No description provided for @tdsNoUniversalTarget.
  ///
  /// In pl, this message translates to:
  /// **'TDS nie ma uniwersalnego zakresu — porównuj z potrzebami obsady i wodą źródłową.'**
  String get tdsNoUniversalTarget;

  /// No description provided for @knowledgeBaseAddAquariumPrompt.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj akwarium, aby sprawdzić zgodność gatunków.'**
  String get knowledgeBaseAddAquariumPrompt;

  /// No description provided for @diagnoseWithProTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Diagnostyka PRO'**
  String get diagnoseWithProTooltip;

  /// No description provided for @knowledgeCategoryAlgae.
  ///
  /// In pl, this message translates to:
  /// **'Glony'**
  String get knowledgeCategoryAlgae;

  /// No description provided for @temperamentLabel.
  ///
  /// In pl, this message translates to:
  /// **'Usposobienie: {value}'**
  String temperamentLabel(String value);

  /// No description provided for @plantRequirementsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wymagania rośliny'**
  String get plantRequirementsTitle;

  /// No description provided for @lightLabel.
  ///
  /// In pl, this message translates to:
  /// **'Światło'**
  String get lightLabel;

  /// No description provided for @co2Label.
  ///
  /// In pl, this message translates to:
  /// **'CO2'**
  String get co2Label;

  /// No description provided for @growthRateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Tempo wzrostu'**
  String get growthRateLabel;

  /// No description provided for @positionLabel.
  ///
  /// In pl, this message translates to:
  /// **'Pozycja'**
  String get positionLabel;

  /// No description provided for @algaeSymptomsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Objawy i zwalczanie'**
  String get algaeSymptomsTitle;

  /// No description provided for @causesLabel.
  ///
  /// In pl, this message translates to:
  /// **'Przyczyny'**
  String get causesLabel;

  /// No description provided for @symptomsLabel.
  ///
  /// In pl, this message translates to:
  /// **'Objawy'**
  String get symptomsLabel;

  /// No description provided for @controlPlanLabel.
  ///
  /// In pl, this message translates to:
  /// **'Plan'**
  String get controlPlanLabel;

  /// No description provided for @difficultyAdvanced.
  ///
  /// In pl, this message translates to:
  /// **'zaawansowana'**
  String get difficultyAdvanced;

  /// No description provided for @temperamentShoalingPeaceful.
  ///
  /// In pl, this message translates to:
  /// **'łagodny, stadny'**
  String get temperamentShoalingPeaceful;

  /// No description provided for @temperamentShoalingPeacefulFeminine.
  ///
  /// In pl, this message translates to:
  /// **'łagodna, stadna'**
  String get temperamentShoalingPeacefulFeminine;

  /// No description provided for @temperamentActivePeaceful.
  ///
  /// In pl, this message translates to:
  /// **'łagodny, aktywny'**
  String get temperamentActivePeaceful;

  /// No description provided for @temperamentTerritorialPeaceful.
  ///
  /// In pl, this message translates to:
  /// **'spokojna, terytorialna'**
  String get temperamentTerritorialPeaceful;

  /// No description provided for @temperamentTerritorialMale.
  ///
  /// In pl, this message translates to:
  /// **'samiec terytorialny'**
  String get temperamentTerritorialMale;

  /// No description provided for @lightLow.
  ///
  /// In pl, this message translates to:
  /// **'Niskie'**
  String get lightLow;

  /// No description provided for @lightLowMedium.
  ///
  /// In pl, this message translates to:
  /// **'Niskie do średniego'**
  String get lightLowMedium;

  /// No description provided for @lightMedium.
  ///
  /// In pl, this message translates to:
  /// **'Średnie'**
  String get lightMedium;

  /// No description provided for @lightMediumHigh.
  ///
  /// In pl, this message translates to:
  /// **'Średnie do wysokiego'**
  String get lightMediumHigh;

  /// No description provided for @co2NotRequired.
  ///
  /// In pl, this message translates to:
  /// **'Niewymagane'**
  String get co2NotRequired;

  /// No description provided for @co2Optional.
  ///
  /// In pl, this message translates to:
  /// **'Opcjonalne'**
  String get co2Optional;

  /// No description provided for @co2Recommended.
  ///
  /// In pl, this message translates to:
  /// **'Zalecane'**
  String get co2Recommended;

  /// No description provided for @growthSlow.
  ///
  /// In pl, this message translates to:
  /// **'Wolne'**
  String get growthSlow;

  /// No description provided for @growthMedium.
  ///
  /// In pl, this message translates to:
  /// **'Średnie'**
  String get growthMedium;

  /// No description provided for @growthFast.
  ///
  /// In pl, this message translates to:
  /// **'Szybkie'**
  String get growthFast;

  /// No description provided for @plantPositionMiddleRoot.
  ///
  /// In pl, this message translates to:
  /// **'Środek / korzeń'**
  String get plantPositionMiddleRoot;

  /// No description provided for @plantPositionMiddleBackground.
  ///
  /// In pl, this message translates to:
  /// **'Środek / tył'**
  String get plantPositionMiddleBackground;

  /// No description provided for @plantPositionMiddle.
  ///
  /// In pl, this message translates to:
  /// **'Środek'**
  String get plantPositionMiddle;

  /// No description provided for @plantPositionBack.
  ///
  /// In pl, this message translates to:
  /// **'Tył'**
  String get plantPositionBack;

  /// No description provided for @plantPositionFront.
  ///
  /// In pl, this message translates to:
  /// **'Przód'**
  String get plantPositionFront;

  /// No description provided for @plantPositionCarpet.
  ///
  /// In pl, this message translates to:
  /// **'Trawnik'**
  String get plantPositionCarpet;

  /// No description provided for @algaeNameBlackBeard.
  ///
  /// In pl, this message translates to:
  /// **'Krasnorosty'**
  String get algaeNameBlackBeard;

  /// No description provided for @algaeNameGreen.
  ///
  /// In pl, this message translates to:
  /// **'Zielenice'**
  String get algaeNameGreen;

  /// No description provided for @algaeNameCyanobacteria.
  ///
  /// In pl, this message translates to:
  /// **'Sinice'**
  String get algaeNameCyanobacteria;

  /// No description provided for @algaeNameDiatoms.
  ///
  /// In pl, this message translates to:
  /// **'Okrzemki'**
  String get algaeNameDiatoms;

  /// No description provided for @algaeCauseCo2Fluctuations.
  ///
  /// In pl, this message translates to:
  /// **'Wahania CO2'**
  String get algaeCauseCo2Fluctuations;

  /// No description provided for @algaeCausePoorCirculation.
  ///
  /// In pl, this message translates to:
  /// **'Słaba cyrkulacja'**
  String get algaeCausePoorCirculation;

  /// No description provided for @algaeCauseUnstableFertilization.
  ///
  /// In pl, this message translates to:
  /// **'Niestabilne nawożenie'**
  String get algaeCauseUnstableFertilization;

  /// No description provided for @algaeCauseExcessLight.
  ///
  /// In pl, this message translates to:
  /// **'Nadmiar światła'**
  String get algaeCauseExcessLight;

  /// No description provided for @algaeCausePo4Deficiency.
  ///
  /// In pl, this message translates to:
  /// **'Niedobór PO4'**
  String get algaeCausePo4Deficiency;

  /// No description provided for @algaeCauseUnstableCo2.
  ///
  /// In pl, this message translates to:
  /// **'Niestabilne CO2'**
  String get algaeCauseUnstableCo2;

  /// No description provided for @algaeCauseNo3Deficiency.
  ///
  /// In pl, this message translates to:
  /// **'Brak NO3'**
  String get algaeCauseNo3Deficiency;

  /// No description provided for @algaeCauseStagnantWater.
  ///
  /// In pl, this message translates to:
  /// **'Zastoiny wody'**
  String get algaeCauseStagnantWater;

  /// No description provided for @algaeCauseOrganicMatter.
  ///
  /// In pl, this message translates to:
  /// **'Nadmiar materii organicznej'**
  String get algaeCauseOrganicMatter;

  /// No description provided for @algaeCauseNewTank.
  ///
  /// In pl, this message translates to:
  /// **'Nowy zbiornik'**
  String get algaeCauseNewTank;

  /// No description provided for @algaeCauseSilicates.
  ///
  /// In pl, this message translates to:
  /// **'Krzemiany w wodzie'**
  String get algaeCauseSilicates;

  /// No description provided for @algaeCauseImmatureFilter.
  ///
  /// In pl, this message translates to:
  /// **'Niedojrzały filtr'**
  String get algaeCauseImmatureFilter;

  /// No description provided for @algaeSymptomBlackTufts.
  ///
  /// In pl, this message translates to:
  /// **'Czarne lub czerwone kępki na liściach i dekoracjach'**
  String get algaeSymptomBlackTufts;

  /// No description provided for @algaeSymptomGreenFilm.
  ///
  /// In pl, this message translates to:
  /// **'Zielony nalot na szybach lub punktowe plamy na liściach'**
  String get algaeSymptomGreenFilm;

  /// No description provided for @algaeSymptomCyanobacteriaMat.
  ///
  /// In pl, this message translates to:
  /// **'Śluzowata niebieskozielona warstwa o charakterystycznym zapachu'**
  String get algaeSymptomCyanobacteriaMat;

  /// No description provided for @algaeSymptomBrownDust.
  ///
  /// In pl, this message translates to:
  /// **'Brązowy pył na szybach, podłożu i dekoracjach'**
  String get algaeSymptomBrownDust;

  /// No description provided for @algaeActionStabilizeCo2.
  ///
  /// In pl, this message translates to:
  /// **'Ustabilizuj podawanie CO2 i popraw cyrkulację.'**
  String get algaeActionStabilizeCo2;

  /// No description provided for @algaeActionRemoveAffected.
  ///
  /// In pl, this message translates to:
  /// **'Usuń mechanicznie porażone liście i dekoracje.'**
  String get algaeActionRemoveAffected;

  /// No description provided for @algaeActionReduceLight.
  ///
  /// In pl, this message translates to:
  /// **'Ogranicz światło do 6–8 godzin i obserwuj zbiornik przez tydzień.'**
  String get algaeActionReduceLight;

  /// No description provided for @algaeActionCleanGlass.
  ///
  /// In pl, this message translates to:
  /// **'Skróć świecenie i regularnie czyść szyby.'**
  String get algaeActionCleanGlass;

  /// No description provided for @algaeActionSupplementPo4.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź PO4 i uzupełniaj je stopniowo.'**
  String get algaeActionSupplementPo4;

  /// No description provided for @algaeActionAddFastPlants.
  ///
  /// In pl, this message translates to:
  /// **'Zwiększ masę szybko rosnących roślin.'**
  String get algaeActionAddFastPlants;

  /// No description provided for @algaeActionRemoveMat.
  ///
  /// In pl, this message translates to:
  /// **'Usuń matę mechanicznie i wykonaj większą podmianę wody.'**
  String get algaeActionRemoveMat;

  /// No description provided for @algaeActionRestoreNo3.
  ///
  /// In pl, this message translates to:
  /// **'Przywróć mierzalny poziom NO3 i popraw przepływ.'**
  String get algaeActionRestoreNo3;

  /// No description provided for @algaeActionReduceFeeding.
  ///
  /// In pl, this message translates to:
  /// **'Ogranicz światło oraz karmienie do czasu ustabilizowania zbiornika.'**
  String get algaeActionReduceFeeding;

  /// No description provided for @algaeActionCleanDiatoms.
  ///
  /// In pl, this message translates to:
  /// **'Usuwaj nalot przy podmianach i utrzymuj regularność prac.'**
  String get algaeActionCleanDiatoms;

  /// No description provided for @algaeActionMatureFilter.
  ///
  /// In pl, this message translates to:
  /// **'Daj biologii czas na dojrzewanie i nie myj całego wkładu naraz.'**
  String get algaeActionMatureFilter;

  /// No description provided for @algaeActionCheckSilicates.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź krzemiany w wodzie kranowej, jeśli problem trwa długo.'**
  String get algaeActionCheckSilicates;

  /// No description provided for @substrateActiveSoil.
  ///
  /// In pl, this message translates to:
  /// **'Soil aktywny'**
  String get substrateActiveSoil;

  /// No description provided for @substrateMineral.
  ///
  /// In pl, this message translates to:
  /// **'Podłoże mineralne'**
  String get substrateMineral;

  /// No description provided for @substrateOther.
  ///
  /// In pl, this message translates to:
  /// **'Inne'**
  String get substrateOther;

  /// No description provided for @changeAlgaePhoto.
  ///
  /// In pl, this message translates to:
  /// **'Zmień zdjęcie glonu'**
  String get changeAlgaePhoto;

  /// No description provided for @analyzingConditions.
  ///
  /// In pl, this message translates to:
  /// **'Analizuję warunki...'**
  String get analyzingConditions;

  /// No description provided for @analyzingAlgaeAndParameters.
  ///
  /// In pl, this message translates to:
  /// **'Analizuję glony i parametry akwarium...'**
  String get analyzingAlgaeAndParameters;

  /// No description provided for @algaeDiagnosisTitle.
  ///
  /// In pl, this message translates to:
  /// **'Diagnoza glonów: {name}'**
  String algaeDiagnosisTitle(String name);

  /// No description provided for @actionPlanTitle.
  ///
  /// In pl, this message translates to:
  /// **'Plan działania'**
  String get actionPlanTitle;

  /// No description provided for @scannerAnalyzingPhoto.
  ///
  /// In pl, this message translates to:
  /// **'Analizuję zdjęcie...'**
  String get scannerAnalyzingPhoto;

  /// No description provided for @scannerAnalyzingSpecies.
  ///
  /// In pl, this message translates to:
  /// **'Analizuję zdjęcie ryby/rośliny...'**
  String get scannerAnalyzingSpecies;

  /// No description provided for @scannerPhotoOpenError.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się otworzyć zdjęcia: {error}'**
  String scannerPhotoOpenError(String error);

  /// No description provided for @scannerAnalysisTimeout.
  ///
  /// In pl, this message translates to:
  /// **'Analiza trwała zbyt długo. Sprawdź połączenie i spróbuj ponownie.'**
  String get scannerAnalysisTimeout;

  /// No description provided for @scannerLockedTitle.
  ///
  /// In pl, this message translates to:
  /// **'Odblokuj inteligentny skaner AI'**
  String get scannerLockedTitle;

  /// No description provided for @scannerLockedDescription.
  ///
  /// In pl, this message translates to:
  /// **'PRO analizuje zdrowie ryb, problemy roślin i glony na zdjęciach akwarium oraz proponuje konkretne dalsze kroki.'**
  String get scannerLockedDescription;

  /// No description provided for @scannerUnlockPro.
  ///
  /// In pl, this message translates to:
  /// **'Odblokuj skaner PRO'**
  String get scannerUnlockPro;

  /// No description provided for @scannerIntro.
  ///
  /// In pl, this message translates to:
  /// **'Zrób zdjęcie ryby, rośliny lub glonów, aby uzyskać ostrożną ocenę AI i zalecane działania.'**
  String get scannerIntro;

  /// No description provided for @scannerTakePhoto.
  ///
  /// In pl, this message translates to:
  /// **'Zrób zdjęcie'**
  String get scannerTakePhoto;

  /// No description provided for @scannerChoosePhoto.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz z galerii'**
  String get scannerChoosePhoto;

  /// No description provided for @scannerNoPhotoSelected.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz lub zrób zdjęcie akwarium, aby rozpocząć.'**
  String get scannerNoPhotoSelected;

  /// No description provided for @scannerSelectingPhoto.
  ///
  /// In pl, this message translates to:
  /// **'Wczytuję wybrane zdjęcie...'**
  String get scannerSelectingPhoto;

  /// No description provided for @scannerAnalyzeAction.
  ///
  /// In pl, this message translates to:
  /// **'Analizuj zdjęcie'**
  String get scannerAnalyzeAction;

  /// No description provided for @scannerNewAnalysis.
  ///
  /// In pl, this message translates to:
  /// **'Rozpocznij nową analizę'**
  String get scannerNewAnalysis;

  /// No description provided for @scannerLoadingTitle.
  ///
  /// In pl, this message translates to:
  /// **'Analizuję obraz i objawy w akwarium...'**
  String get scannerLoadingTitle;

  /// No description provided for @scannerLoadingDescription.
  ///
  /// In pl, this message translates to:
  /// **'AI sprawdza widoczne oznaki. To może chwilę potrwać.'**
  String get scannerLoadingDescription;

  /// No description provided for @scannerErrorTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zakończyć analizy'**
  String get scannerErrorTitle;

  /// No description provided for @scannerTryAgain.
  ///
  /// In pl, this message translates to:
  /// **'Spróbuj ponownie'**
  String get scannerTryAgain;

  /// No description provided for @scannerCameraPermissionDenied.
  ///
  /// In pl, this message translates to:
  /// **'Brak dostępu do aparatu. Zezwól na dostęp w ustawieniach urządzenia lub wybierz zdjęcie z galerii.'**
  String get scannerCameraPermissionDenied;

  /// No description provided for @scannerCameraUnavailable.
  ///
  /// In pl, this message translates to:
  /// **'Aparat jest niedostępny na tym urządzeniu. Wybierz zdjęcie z galerii.'**
  String get scannerCameraUnavailable;

  /// No description provided for @scannerPhotoPickerFailure.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wybrać zdjęcia. Sprawdź uprawnienia i spróbuj ponownie.'**
  String get scannerPhotoPickerFailure;

  /// No description provided for @scannerInvalidImage.
  ///
  /// In pl, this message translates to:
  /// **'Wybrane zdjęcie jest puste lub nie można go odczytać.'**
  String get scannerInvalidImage;

  /// No description provided for @scannerApiKeyMissing.
  ///
  /// In pl, this message translates to:
  /// **'Skaner AI nie jest skonfigurowany. Dodaj klucz API Gemini w ustawieniach profilu.'**
  String get scannerApiKeyMissing;

  /// No description provided for @scannerApiKeyInvalid.
  ///
  /// In pl, this message translates to:
  /// **'Usługa AI odrzuciła klucz API. Sprawdź klucz w ustawieniach profilu.'**
  String get scannerApiKeyInvalid;

  /// No description provided for @scannerNetworkFailure.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się połączyć z usługą AI. Sprawdź internet i spróbuj ponownie.'**
  String get scannerNetworkFailure;

  /// No description provided for @scannerServiceBusy.
  ///
  /// In pl, this message translates to:
  /// **'Usługa AI jest chwilowo zajęta. Spróbuj ponownie za chwilę.'**
  String get scannerServiceBusy;

  /// No description provided for @scannerInvalidResponse.
  ///
  /// In pl, this message translates to:
  /// **'Usługa AI zwróciła nieczytelny wynik. Spróbuj zrobić wyraźniejsze zdjęcie.'**
  String get scannerInvalidResponse;

  /// No description provided for @scannerRequestFailure.
  ///
  /// In pl, this message translates to:
  /// **'Żądanie do AI nie powiodło się. Spróbuj ponownie.'**
  String get scannerRequestFailure;

  /// No description provided for @scannerUnexpectedFailure.
  ///
  /// In pl, this message translates to:
  /// **'Wystąpił nieoczekiwany błąd podczas analizy zdjęcia.'**
  String get scannerUnexpectedFailure;

  /// No description provided for @scannerConfidence.
  ///
  /// In pl, this message translates to:
  /// **'Pewność: {percent}%'**
  String scannerConfidence(int percent);

  /// No description provided for @scannerCategoryFishDisease.
  ///
  /// In pl, this message translates to:
  /// **'Możliwy problem zdrowotny ryby'**
  String get scannerCategoryFishDisease;

  /// No description provided for @scannerCategoryPlantIssue.
  ///
  /// In pl, this message translates to:
  /// **'Problem rośliny'**
  String get scannerCategoryPlantIssue;

  /// No description provided for @scannerCategoryAlgae.
  ///
  /// In pl, this message translates to:
  /// **'Glony'**
  String get scannerCategoryAlgae;

  /// No description provided for @scannerCategoryOther.
  ///
  /// In pl, this message translates to:
  /// **'Ogólna obserwacja'**
  String get scannerCategoryOther;

  /// No description provided for @scannerCareNotice.
  ///
  /// In pl, this message translates to:
  /// **'Wskazówki AI to wstępna ocena, nie diagnoza weterynaryjna. Przed leczeniem potwierdź objawy i parametry wody.'**
  String get scannerCareNotice;

  /// No description provided for @purchaseNotConfigured.
  ///
  /// In pl, this message translates to:
  /// **'Plan niedostępny'**
  String get purchaseNotConfigured;

  /// No description provided for @loadingSubscriptionPrices.
  ///
  /// In pl, this message translates to:
  /// **'Pobieranie cen…'**
  String get loadingSubscriptionPrices;

  /// No description provided for @subscriptionStoreUnavailable.
  ///
  /// In pl, this message translates to:
  /// **'Sklep jest niedostępny. Spróbuj ponownie później.'**
  String get subscriptionStoreUnavailable;

  /// No description provided for @subscriptionPurchasePending.
  ///
  /// In pl, this message translates to:
  /// **'Oczekiwanie na potwierdzenie zakupu…'**
  String get subscriptionPurchasePending;

  /// No description provided for @subscriptionPurchaseCancelled.
  ///
  /// In pl, this message translates to:
  /// **'Zakup został anulowany.'**
  String get subscriptionPurchaseCancelled;

  /// No description provided for @subscriptionPurchaseFailed.
  ///
  /// In pl, this message translates to:
  /// **'Zakup nie powiódł się. Spróbuj ponownie.'**
  String get subscriptionPurchaseFailed;

  /// No description provided for @mockAiUnavailable.
  ///
  /// In pl, this message translates to:
  /// **'Wynik demonstracyjny. Endpoint AI nie jest dostępny.'**
  String get mockAiUnavailable;

  /// No description provided for @recognizedSpecies.
  ///
  /// In pl, this message translates to:
  /// **'Rozpoznano: {name}'**
  String recognizedSpecies(String name);

  /// No description provided for @livestockCompatibilityTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zgodność z obsadą'**
  String get livestockCompatibilityTitle;

  /// No description provided for @closeAction.
  ///
  /// In pl, this message translates to:
  /// **'Zamknij'**
  String get closeAction;

  /// No description provided for @compatibilityIncompatibleTemperatureRanges.
  ///
  /// In pl, this message translates to:
  /// **'{first} i {second} nie mają wspólnego zakresu temperatur.'**
  String compatibilityIncompatibleTemperatureRanges(
    String first,
    String second,
  );

  /// No description provided for @journalSearchHint.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj wpisów, tagów i obserwacji'**
  String get journalSearchHint;

  /// No description provided for @newJournalEntry.
  ///
  /// In pl, this message translates to:
  /// **'Nowy wpis dziennika'**
  String get newJournalEntry;

  /// No description provided for @galleryAction.
  ///
  /// In pl, this message translates to:
  /// **'Galeria'**
  String get galleryAction;

  /// No description provided for @cameraAction.
  ///
  /// In pl, this message translates to:
  /// **'Aparat'**
  String get cameraAction;

  /// No description provided for @photoAdded.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcie dodane'**
  String get photoAdded;

  /// No description provided for @selectAquariumFirst.
  ///
  /// In pl, this message translates to:
  /// **'Najpierw wybierz akwarium.'**
  String get selectAquariumFirst;

  /// No description provided for @healthy.
  ///
  /// In pl, this message translates to:
  /// **'Zdrowe'**
  String get healthy;

  /// No description provided for @reminderOptionsTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Opcje przypomnienia'**
  String get reminderOptionsTooltip;

  /// No description provided for @reminderTaskFilter.
  ///
  /// In pl, this message translates to:
  /// **'Czyszczenie filtra'**
  String get reminderTaskFilter;
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
