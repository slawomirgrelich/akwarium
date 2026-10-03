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
  /// **'Wypróbuj PRO'**
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

  /// No description provided for @reminderTaskWaterChange.
  ///
  /// In pl, this message translates to:
  /// **'Podmiana wody'**
  String get reminderTaskWaterChange;

  /// No description provided for @reminderTaskFilter.
  ///
  /// In pl, this message translates to:
  /// **'Czyszczenie filtra'**
  String get reminderTaskFilter;

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
  /// **'Aktywowanie…'**
  String get activatingEllipsis;

  /// No description provided for @proActivatedMessage.
  ///
  /// In pl, this message translates to:
  /// **'Aktywowany status Akwarysta PRO.'**
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

  /// No description provided for @reminderTaskFilterClean.
  ///
  /// In pl, this message translates to:
  /// **'Czyszczenie filtra'**
  String get reminderTaskFilterClean;

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
