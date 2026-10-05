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
  String get signInWithGoogle => 'Zaloguj się przez Google';

  @override
  String get orContinueWith => 'lub kontynuuj przez';

  @override
  String get signedInAccount => 'Zalogowane konto';

  @override
  String get googleSignInConfigurationError =>
      'Logowanie Google nie jest skonfigurowane. Skonfiguruj klientów OAuth w Firebase i podaj identyfikator klienta web podczas budowania aplikacji.';

  @override
  String get googleSignInUnsupported =>
      'Logowanie Google nie jest dostępne na tej platformie.';

  @override
  String get googleSignInFailed =>
      'Logowanie przez Google nie powiodło się. Sprawdź połączenie i spróbuj ponownie.';

  @override
  String get googleConfigurationHint =>
      'Logowanie Google wymaga włączenia dostawcy Google w Firebase Authentication, odcisków SHA podpisu Androida i identyfikatora klienta OAuth web. Dla iOS skonfiguruj klienta OAuth i schemat URL.';

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
  String get freePlan => 'Plan Free: 1 akwarium';

  @override
  String get proPlan => 'Plan PRO: nielimitowana liczba akwariów';

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

  @override
  String get yourDashboard => 'Twój pulpit';

  @override
  String get dashboardSubtitle => 'Wszystko, co ważne dla Twojego akwarium.';

  @override
  String get helloUser => 'Cześć, Sławek! 👋';

  @override
  String get noNewNotifications => 'Brak nowych powiadomień';

  @override
  String get aquariumStatus => 'Status akwarium';

  @override
  String get lastTest => 'Ostatni test';

  @override
  String get noData => 'Brak danych';

  @override
  String get addFirstTest => 'Dodaj pierwszy test';

  @override
  String parametersCount(int count) {
    return 'Liczba zmierzonych parametrów: $count';
  }

  @override
  String get waterChange => 'Podmiana';

  @override
  String get waterChangeLiters => 'Litry';

  @override
  String get waterChangePercent => 'Procentowo';

  @override
  String waterChangeEquivalent(String liters) {
    return '≈ $liters l';
  }

  @override
  String get invalidWaterChangeAmount =>
      'Wpisz dodatnią wartość. Procent nie może przekraczać 100%, a litry nie mogą przekraczać pojemności netto akwarium.';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dni',
      one: '1 dzień',
    );
    return '$_temp0';
  }

  @override
  String get freshWater => 'Woda świeża';

  @override
  String get timeForWaterChange => 'Czas na podmianę';

  @override
  String get recentParameters => 'Ostatnie parametry';

  @override
  String get quickActions => 'Szybkie akcje';

  @override
  String get enterWaterTest => 'Wpisz wyniki testu wody';

  @override
  String get saveTankParameters => 'Zapisz aktualne parametry zbiornika';

  @override
  String get addWaterChange => 'Dodaj podmianę wody';

  @override
  String get saveVolumeAndNote => 'Zapisz litraż i notatkę';

  @override
  String get historyOfTank => 'HISTORIA ZBIORNIKA';

  @override
  String get journalSubtitle => 'Pełna historia opieki nad akwarium.';

  @override
  String get recentEntries => 'Ostatnie wpisy';

  @override
  String get showOlderEntries => 'Pokaż starsze wpisy';

  @override
  String get archivedTank => 'Archiwalne';

  @override
  String get endDateLabel => 'Data likwidacji';

  @override
  String get archivedHistoryNotice =>
      'To akwarium jest archiwalne. Przeglądasz jego historię; dodawanie pomiarów i podmian jest wyłączone.';

  @override
  String archivedEndDate(String date) {
    return 'Archiwalne · $date';
  }

  @override
  String get journalEmpty => 'Dziennik jest jeszcze pusty';

  @override
  String get addFirstWaterEntry => 'Dodaj pierwszy test wody lub podmianę.';

  @override
  String get toolsCenter => 'CENTRUM NARZĘDZI';

  @override
  String get toolsSubtitle => 'Praktyczne funkcje dla każdego akwarysty.';

  @override
  String get account => 'TWOJE KONTO';

  @override
  String get profileTitle => 'Profil i PRO';

  @override
  String get profileSubtitle => 'Zarządzaj akwarium oraz ustawieniami konta.';

  @override
  String get aquariumName => 'Nazwa';

  @override
  String get tankDetails => '112 litrów · Roślinne';

  @override
  String get notificationsSubtitle => 'Przypomnienia o testach i podmianach';

  @override
  String get syncData => 'Synchronizacja danych';

  @override
  String get syncSubtitle => 'Przygotowane pod Firebase lub Supabase';

  @override
  String get syncComingSoon =>
      'Synchronizacja zostanie podłączona w kolejnym etapie';

  @override
  String get logOut => 'Wyloguj się';

  @override
  String get logOutSubtitle => 'Zakończ bieżącą sesję na tym urządzeniu';

  @override
  String get cancel => 'Anuluj';

  @override
  String get add => 'Dodaj';

  @override
  String get netVolume => 'Pojemność netto';

  @override
  String get grossVolume => 'Pojemność brutto';

  @override
  String get setupDateLabel => 'Data założenia';

  @override
  String get tankType => 'Typ zbiornika';

  @override
  String get freshwater => 'Słodkowodne';

  @override
  String get saltwater => 'Morskie';

  @override
  String get brackish => 'Brackawe';

  @override
  String netVolumeShort(num volume) {
    return '$volume l netto';
  }

  @override
  String litersCount(num volume) {
    return '$volume litrów';
  }

  @override
  String inhabitantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mieszkańców',
      many: '$count mieszkańców',
      few: '$count mieszkańców',
      one: '1 mieszkańiec',
      zero: '0 mieszkańców',
    );
    return '$_temp0';
  }

  @override
  String get save => 'Zapisz';

  @override
  String get volume => 'Objętość';

  @override
  String get note => 'Notatka';

  @override
  String get newActivity => 'Nowa czynność';

  @override
  String get title => 'Tytuł';

  @override
  String get activityType => 'Typ czynności';

  @override
  String get waterReplaced => 'Podmieniona woda';

  @override
  String get liters => 'litrów';

  @override
  String get diagnosisSaved => 'Diagnoza została zapisana w dzienniku';

  @override
  String get saveToJournal => 'Zapisz do Dziennika';

  @override
  String get tanksAndStock => 'Akwaria i obsada';

  @override
  String get tanksAndStockDescription =>
      'Przełącz zbiornik i zarządzaj fauną oraz florą.';

  @override
  String get openManagement => 'Otwórz zarządzanie';

  @override
  String get waterTests => 'Testy wody';

  @override
  String get waterTestsDescription =>
      'Zapisuj pH, NO3, PO4, Fe, KH, GH i temperaturę.';

  @override
  String get openTests => 'Otwórz testy';

  @override
  String get knowledgeBase => 'Baza wiedzy i Atlas';

  @override
  String get knowledgeBaseDescription =>
      'Poznaj ryby, rośliny i sposoby walki z glonami.';

  @override
  String get openAtlas => 'Otwórz Atlas';

  @override
  String get fertilizerCalculator => 'Kalkulator nawożenia';

  @override
  String get fertilizerDescription =>
      'Oblicz dawki dzienne i tygodniowe dla zbiornika.';

  @override
  String get openCalculator => 'Otwórz kalkulator';

  @override
  String get calculatorsTitle => 'Kalkulatory akwarystyczne';

  @override
  String get volumeTab => 'Objętość';

  @override
  String get co2Tab => 'CO2';

  @override
  String get fertilizersTab => 'Nawozy';

  @override
  String get volumeCalculator => 'Objętość zbiornika';

  @override
  String get volumeCalculatorSubtitle =>
      'Porównaj pojemność brutto z realną ilością wody.';

  @override
  String get length => 'Długość';

  @override
  String get width => 'Szerokość';

  @override
  String get height => 'Wysokość';

  @override
  String get glassThickness => 'Grubość szkła';

  @override
  String get substrateThickness => 'Grubość podłoża';

  @override
  String get decorationsAndEquipment => 'Dekoracje i sprzęt';

  @override
  String get saveNetDefault => 'Zapisz netto jako domyślne';

  @override
  String get co2Calculator => 'Kalkulator CO2';

  @override
  String get co2CalculatorSubtitle =>
      'Wybierz pH i KH, aby sprawdzić stężenie rozpuszczonego CO2.';

  @override
  String get fertilizerCalculatorTitle => 'Dawkowanie nawozów';

  @override
  String get fertilizerCalculatorSubtitle =>
      'Sprawdź, ile pierwiastka wnosi każdy mililitr roztworu.';

  @override
  String get netCapacity => 'Pojemność netto';

  @override
  String get solutionCapacity => 'Pojemność roztworu';

  @override
  String get saltAmount => 'Wsypana sól';

  @override
  String get baseSalt => 'Sól bazowa';

  @override
  String get weeklyTarget => 'Cel tygodniowy';

  @override
  String freshWaterLastChange(int count) {
    return 'Woda jest świeża. Ostatnia podmiana była $count dni temu.';
  }

  @override
  String get scheduleNextChange => 'Czas zaplanować kolejną podmianę wody.';

  @override
  String get noSavedMeasurements => 'Brak zapisanych pomiarów';

  @override
  String get addFirstTestTrack =>
      'Dodaj pierwszy test, aby śledzić kondycję wody.';

  @override
  String get addFirstMeasurement => 'Dodaj pierwszy pomiar';

  @override
  String get actualWaterVolume => 'Rzeczywista objętość wody';

  @override
  String get netWater => 'Woda netto';

  @override
  String get substrate => 'Podłoże';

  @override
  String grossVolumeValue(String value) {
    return 'Brutto: $value l';
  }

  @override
  String get rocksWood => 'Skały / drewno';

  @override
  String get glass => 'Szkło';

  @override
  String estimatedTotalWeight(String value) {
    return 'Szacowany ciężar całkowity: $value kg';
  }

  @override
  String get co2Low => 'Niedobór CO2 - słaby wzrost roślin';

  @override
  String get co2Optimal => 'Poziom optymalny - bezpieczny dla ryb';

  @override
  String get co2High => 'Nadmiar CO2 - ryzyko przyduchy dla ryb';

  @override
  String get co2Deficit => 'niedobór';

  @override
  String get co2Optimum => 'optimum';

  @override
  String get co2Risk => 'ryzyko';

  @override
  String get proActive => 'Akwarysta PRO (aktywny)';

  @override
  String get proName => 'Akwarysta PRO';

  @override
  String get allPremiumUnlocked => 'Wszystkie funkcje premium są odblokowane';

  @override
  String get unlockPremium => 'Odblokuj AI, wykresy i nielimitowane akwaria.';

  @override
  String get proPlanUnlimitedAquariums =>
      'Plan PRO: nielimitowana liczba akwariów';

  @override
  String get knowledgeBaseTitle => 'Baza wiedzy i Atlas';

  @override
  String get knowledgeBaseDesc =>
      'Poznaj ryby, rośliny i metody zwalczania glonów.';

  @override
  String get fertilizerCalcTitle => 'Kalkulator nawozów';

  @override
  String get fertilizerCalcDesc =>
      'Oblicz dzienne i tygodniowe dawki dla swojego akwarium.';

  @override
  String get aquaristProActive => 'Akwarysta PRO (aktywny)';

  @override
  String get allFeaturesUnlocked => 'Wszystkie funkcje premium są odblokowane';

  @override
  String get navTools => 'Narzędzia';

  @override
  String get navJournal => 'Dziennik';

  @override
  String get navDashboard => 'Pulpit';

  @override
  String get navProfile => 'Profil';

  @override
  String get tabTimeline => 'Oś czasu';

  @override
  String get tabCalendar => 'Kalendarz';

  @override
  String get forToday => 'Na dziś';

  @override
  String get selectedDay => 'Wybrany dzień';

  @override
  String get aiScannerTitle => 'Skaner AI ryb i roślin';

  @override
  String get aiScannerDesc =>
      'Rozpoznaj gatunek ze zdjęcia i poznaj jego wymagania.';

  @override
  String get tryPro => 'Subskrybuj';

  @override
  String get algaeAssistantTitle => 'Asystent glonów';

  @override
  String get algaeAssistantDesc =>
      'Zdiagnozuj problem i otrzymaj plan działania.';

  @override
  String get startDiagnosis => 'Rozpocznij diagnozę';

  @override
  String get timeline => 'Oś czasu';

  @override
  String get calendar => 'Kalendarz';

  @override
  String get allEntries => 'Wszystkie';

  @override
  String get noEntriesForFilter => 'Brak wpisów dla wybranego filtra.';

  @override
  String get searchAtlas => 'Szukaj w Atlasie';

  @override
  String get knowledgeForStableTank => 'Wiedza dla stabilnego zbiornika';

  @override
  String get proPaywallTitle => 'Odblokuj Pełny Potencjał Akwarysta PRO';

  @override
  String get proPaywallSubtitle =>
      'Spokojniejsza opieka nad akwarium dzięki funkcjom dla wymagających zbiorników.';

  @override
  String get featureUnlimitedCharts =>
      'Nielimitowane wykresy i historia parametrów';

  @override
  String get featureFertilizerCalc => 'Kalkulator nawożenia i receptury soli';

  @override
  String get featureReminders => 'Przypomnienia SMS i Push';

  @override
  String get featureExportPdf => 'Eksport raportów do PDF';

  @override
  String get trial7Days => 'Wypróbuj PRO przez 7 dni za darmo';

  @override
  String get maybeLater => 'Później';

  @override
  String get algaeQuestion => 'Co widzisz w akwarium?';

  @override
  String get algaeBba => 'Krasnorosty / BBA';

  @override
  String get algaeGreen => 'Zielenice';

  @override
  String get algaeCyanobacteria => 'Sinice / cyjanobakterie';

  @override
  String get algaeDiatoms => 'Okrzemki';

  @override
  String get algaeDust => 'Pył na szybie';

  @override
  String get algaeThread => 'Nitkowate';

  @override
  String get addAlgaePhotoOptional => 'Dodaj zdjęcie glonu (opcjonalnie)';

  @override
  String get recentWaterParams => 'Ostatnie parametry wody';

  @override
  String get paramsLoadedInfo =>
      'Wartości zostały wczytane z najnowszego testu. Możesz je poprawić przed analizą.';

  @override
  String get tankConditions => 'Warunki w akwarium';

  @override
  String get lightHours => 'Światło';

  @override
  String get substrateType => 'Podłoże';

  @override
  String get gravelSand => 'Żwirek / piasek';

  @override
  String get saveMeasurement => 'Zapisz pomiar';

  @override
  String get journalTitle => 'Dziennik akwarysty';

  @override
  String get filterWaterChange => 'Podmiana wody';

  @override
  String get filterFilter => 'Filtr';

  @override
  String get filterTrimming => 'Przycinanie';

  @override
  String get filterMeds => 'Leki';

  @override
  String get filterCleaning => 'Czyszczenie';

  @override
  String get upcomingTasks => 'Nadchodzące zadania';

  @override
  String get noTasksForDay => 'Brak zadań na ten dzień.';

  @override
  String get tanksAndStockTitle => 'Akwaria i obsada';

  @override
  String get addTank => 'Dodaj akwarium';

  @override
  String get addNewTank => 'Dodaj nowe akwarium';

  @override
  String get speciesCount => 'Gatunki';

  @override
  String get itemCount => 'Sztuki';

  @override
  String get searchSpeciesOrVar => 'Szukaj gatunku lub odmiany';

  @override
  String get noEntriesInCategory => 'Brak wpisów w tej kategorii.';

  @override
  String get idealForYourTank => 'Idealne do Twojego akwarium';

  @override
  String get co2Dosing => 'Podawanie CO2';

  @override
  String get includeCo2InDiagnosis => 'Uwzględnij instalację CO2 w diagnozie';

  @override
  String get diagnoseProblem => 'Zdiagnozuj problem';

  @override
  String get waterTestTitle => 'Test wody';

  @override
  String get waterParameters => 'Parametry wody';

  @override
  String get waterTestInfo =>
      'Pomiń niewykonane testy, pozostawiając pola puste. Wpisz co najmniej jeden parametr; pomiar zapisze się z aktualną datą i godziną.';

  @override
  String get waterAtLeastOneParameter =>
      'Wpisz co najmniej jeden parametr wody.';

  @override
  String get waterTestDeleteTitle => 'Usunąć test wody?';

  @override
  String get waterTestDeletePrompt =>
      'Ten test wody i jego wpis w historii zostaną trwale usunięte.';

  @override
  String get waterTestDeletedMessage => 'Test wody został usunięty.';

  @override
  String get waterTestDeleteFailed =>
      'Nie udało się usunąć testu wody. Spróbuj ponownie.';

  @override
  String get dailyDose => 'Dawka dzienna';

  @override
  String get weeklyDose => 'Dawka tygodniowa';

  @override
  String get addFishOrPlantPhoto => 'Dodaj zdjęcie ryby lub rośliny';

  @override
  String get tapToSelectCameraOrGallery =>
      'Dotknij, aby wybrać Aparat lub Galerię';

  @override
  String get runRecognition => 'Uruchom rozpoznawanie';

  @override
  String get smartDiagnosis => 'Inteligentna diagnoza';

  @override
  String get smartDiagnosisSubtitle =>
      'Wprowadź aktualne dane, aby otrzymać plan działania.';

  @override
  String get currentPh => 'Aktualne pH';

  @override
  String get previousPh => 'pH z poprzedniego pomiaru';

  @override
  String get lightingTime => 'Czas świecenia';

  @override
  String get runProDiagnosis => 'Uruchom diagnozę PRO';

  @override
  String get temperature => 'Temperatura';

  @override
  String get changeAquariumTooltip => 'Zmień akwarium';

  @override
  String get notificationSettings => 'Ustawienia powiadomień';

  @override
  String get taskReminders => 'Przypomnienia o zadaniach';

  @override
  String get taskRemindersSubtitle => 'Podmiany, filtr i pielęgnacja';

  @override
  String get waterTestReminders => 'Pomiary wody';

  @override
  String get waterTestRemindersSubtitle => 'Przypomnienie o regularnym teście';

  @override
  String get weeklySummary => 'Tygodniowe podsumowanie';

  @override
  String get weeklySummarySubtitle => 'Najważniejsze zmiany w akwarium';

  @override
  String get proNotificationsNote =>
      'Powiadomienia PRO są aktywne dla tego urządzenia.';

  @override
  String get atlasSearchPlaceholder => 'np. neon, anubias, zielenice';

  @override
  String get proNotificationsRequired =>
      'Powiadomienia push i cykliczne harmonogramy wymagają aktywnego planu PRO.';

  @override
  String get setProfileName => 'Ustaw imię profilu';

  @override
  String get geminiApiKeyLabel => 'Klucz API Gemini';

  @override
  String get aiScannerConfig => 'Konfiguracja skanera zdjęć AI';

  @override
  String get cloudBackupSyncTitle => 'Kopia w chmurze i synchronizacja';

  @override
  String get cloudBackupSyncSubtitle =>
      'Automatyczny zapis i tworzenie kopii zapasowej w chmurze';

  @override
  String get photoJournalTitle => 'Dziennik zdjęć';

  @override
  String get addFirstPhotoOfAquarium => 'Dodaj pierwsze zdjęcie akwarium.';

  @override
  String get addPhoto => 'Dodaj zdjęcie';

  @override
  String get aquariumLivestockTitle => 'Obsada akwarium';

  @override
  String compatibilityPercent(int score) {
    return '$score% kompatybilności';
  }

  @override
  String get livestockWithinRange =>
      'Obsada mieści się w sprawdzonych zakresach.';

  @override
  String get noSpeciesAddedOpenAtlas =>
      'Brak dodanych gatunków. Otwórz atlas, aby dodać obsadę.';

  @override
  String get addSpecies => 'Dodaj gatunek';

  @override
  String get addSpeciesToStock => 'Dodaj gatunek do obsady';

  @override
  String get newReminder => 'Nowe przypomnienie';

  @override
  String get taskName => 'Nazwa zadania';

  @override
  String get reminderTaskPreset => 'Rodzaj zadania';

  @override
  String get reminderCustomNameRequired => 'Wpisz nazwę własnego zadania.';

  @override
  String get reminderInvalidInterval =>
      'Podaj interwał powtarzania wynoszący co najmniej jeden dzień.';

  @override
  String get dueDate => 'Termin';

  @override
  String get repeatCyclically => 'Powtarzaj cyklicznie';

  @override
  String get autoScheduleNextDate => 'Automatycznie planuj kolejny termin';

  @override
  String get proBenefitUnlimitedAquariums => 'Nielimitowane akwaria';

  @override
  String get proBenefitAiScannerDiagnostics => 'Skaner AI i diagnostyka';

  @override
  String get proBenefitFullPhotoHistory => 'Pełna historia zdjęć';

  @override
  String get proBenefitNoAds => 'Brak reklam';

  @override
  String get unlockProHeadline => 'Odblokuj Akwarysta PRO';

  @override
  String get experienceMode => 'Tryb korzystania z aplikacji';

  @override
  String get experienceModeSubtitle =>
      'Dopasuj pulpit i wskazówki do swojego doświadczenia.';

  @override
  String get beginnerMode => 'Początkujący';

  @override
  String get advancedMode => 'Zaawansowany';

  @override
  String get beginnerModeDescription =>
      'Prostszy pulpit i prowadzenie krok po kroku.';

  @override
  String get advancedModeDescription => 'Pełne parametry, wykresy i narzędzia.';

  @override
  String get beginnerGuideTitle => 'Zacznij krok po kroku';

  @override
  String get beginnerGuideIntro =>
      'Nie musisz znać wszystkich parametrów. Zacznij od tych czterech podstaw.';

  @override
  String get beginnerStepDimensions => 'Wymiary i pojemność';

  @override
  String get beginnerStepDimensionsDescription =>
      'Zmierz długość, szerokość i wysokość akwarium. Zanotuj, ile wody rzeczywiście wlewasz.';

  @override
  String get beginnerStepWater => 'Woda kranowa';

  @override
  String get beginnerStepWaterDescription =>
      'Przed wpuszczeniem zwierząt zbadaj wodę i uzdatnij ją zgodnie z instrukcją preparatu.';

  @override
  String get beginnerStepLighting => 'Oświetlenie';

  @override
  String get beginnerStepLightingDescription =>
      'Zacznij od umiarkowanego czasu świecenia i zmieniaj go stopniowo, obserwując rośliny i glony.';

  @override
  String get beginnerStepPlants => 'Łatwe rośliny';

  @override
  String get beginnerStepPlantsDescription =>
      'Wybierz niewymagające rośliny, na przykład anubiasy, kryptokoryny lub rogatek.';

  @override
  String maintenanceTaskDeleteConfirm(String title) {
    return 'Czy na pewno chcesz usunąć zadanie „$title”?';
  }

  @override
  String get beginnerNextStep => 'Następny krok';

  @override
  String get beginnerPreviousStep => 'Poprzedni krok';

  @override
  String get beginnerFinishGuide => 'Zakończ samouczek';

  @override
  String get beginnerGuideSaveFailed =>
      'Nie udało się zapisać ukończenia samouczka. Spróbuj ponownie.';

  @override
  String get beginnerDimensionsAction => 'Otwórz akwarium';

  @override
  String get beginnerLightingAction => 'Zobacz wskazówki';

  @override
  String get editAquariumTitle => 'Edytuj akwarium';

  @override
  String get hoursPerDayShort => 'godz./dzień';

  @override
  String get beginnerWaterStatusNoData =>
      'Dodaj pierwszy pomiar, aby sprawdzić kondycję wody.';

  @override
  String get beginnerWaterStatusGood =>
      'Ostatni pomiar nie wskazuje pilnego problemu.';

  @override
  String get beginnerWaterStatusNeedsAttention =>
      'Warto sprawdzić ostatni pomiar i wprowadzić zalecane zmiany stopniowo.';

  @override
  String get beginnerTestSaved => 'Pomiar zapisany.';

  @override
  String get beginnerWaterMeasurementsHint =>
      'Wpisuj tylko wyniki, które udało Ci się zmierzyć. Pozostałe pola możesz pominąć.';

  @override
  String get beginnerDimensionHint =>
      'Podaj wewnętrzne wymiary akwarium w centymetrach. Przybliżoną pojemność obliczymy za Ciebie.';

  @override
  String get tankLength => 'Długość';

  @override
  String get tankWidth => 'Szerokość';

  @override
  String get tankHeight => 'Wysokość';

  @override
  String beginnerCalculatedCapacity(String liters) {
    return 'Przybliżona pojemność brutto: $liters l';
  }

  @override
  String get invalidTankDimensions => 'Wymiary muszą być dodatnimi liczbami.';

  @override
  String get invalidNetVolume =>
      'Podaj prawidłową, dodatnią ilość wody w zbiorniku.';

  @override
  String get beginnerNetVolumeHint =>
      'Wpisz przybliżoną ilość wody w zbiorniku. Nie musisz obliczać pojemności brutto.';

  @override
  String get monthlyPlan => 'Miesięczny';

  @override
  String get yearlyPlan => 'Roczny';

  @override
  String get mostPopularBadge => 'Najpopularniejszy';

  @override
  String get activatingEllipsis => 'Przetwarzanie…';

  @override
  String get proActivatedMessage =>
      'Subskrypcja Akwarysta PRO została aktywowana.';

  @override
  String proActivationFailed(String error) {
    return 'Nie udało się aktywować PRO: $error';
  }

  @override
  String get speciesAtlasTitle => 'Atlas gatunków';

  @override
  String get searchSpeciesLabel => 'Szukaj gatunku';

  @override
  String get filterAll => 'Wszystkie';

  @override
  String get filterFish => 'Ryby';

  @override
  String get filterPlants => 'Rośliny';

  @override
  String get filterInvertebrates => 'Bezkręgowce';

  @override
  String get noSpeciesFound => 'Nie znaleziono gatunków.';

  @override
  String get careNotesLabel => 'Wskazówki pielęgnacyjne';

  @override
  String minTankVolumeLabel(int value) {
    return 'Minimum akwarium: $value l';
  }

  @override
  String temperatureRangeLabel(num min, num max) {
    return 'Temperatura: $min–$max°C';
  }

  @override
  String phRangeLabel(num min, num max) {
    return 'pH: $min–$max';
  }

  @override
  String ghRangeLabel(num min, num max) {
    return 'GH: $min–$max';
  }

  @override
  String difficultyLabel(String value) {
    return 'Trudność: $value';
  }

  @override
  String swimmingZoneLabel(String value) {
    return 'Strefa pływania: $value';
  }

  @override
  String get plantsTabTitle => 'Rośliny';

  @override
  String get animalsTabTitle => 'Ryby i bezkręgowce';

  @override
  String plantTargetHeightLabel(num min, num max) {
    return 'Docelowa wysokość: $min–$max cm';
  }

  @override
  String plantPositionDetailsLabel(String value) {
    return 'Pozycja w akwarium: $value';
  }

  @override
  String plantKhRangeLabel(num min, num max) {
    return 'Zakres KH: $min–$max dKH';
  }

  @override
  String plantCo2Label(String value) {
    return 'Wymagania CO2: $value';
  }

  @override
  String plantLightingPowerLabel(String value) {
    return 'Minimalna moc oświetlenia: $value W/L';
  }

  @override
  String plantVarietiesLabel(String value) {
    return 'Odmiany: $value';
  }

  @override
  String get plantLightingPowerNote =>
      'Orientacyjna moc dla oświetlenia LED; rzeczywista intensywność zależy od lampy i głębokości zbiornika.';

  @override
  String get co2Required => 'Wymagane';

  @override
  String get plantCareDataUnavailable =>
      'Brak danych pielęgnacyjnych dla tej rośliny.';

  @override
  String compatibleWithAquarium(String name) {
    return 'Dopasowany do akwarium \"$name\"';
  }

  @override
  String warningsForAquarium(String name) {
    return 'Ostrzeżenia dla akwarium \"$name\"';
  }

  @override
  String get addToMyAquarium => 'Dodaj do mojego akwarium';

  @override
  String get loginToAddSpecies => 'Zaloguj się, aby dodać gatunek do akwarium.';

  @override
  String get chooseAquarium => 'Wybierz akwarium';

  @override
  String get noAquariumYet =>
      'Nie masz jeszcze żadnego akwarium. Utwórz akwarium, aby dodać do niego gatunek';

  @override
  String get createAquariumAction => 'Utwórz akwarium';

  @override
  String get createNewAquariumAction => 'Utwórz nowe akwarium';

  @override
  String get openManagementToCreateAquarium =>
      'Otwórz zarządzanie akwariami, aby utworzyć akwarium.';

  @override
  String addedSpeciesToAquarium(String species, String aquarium) {
    return 'Dodano $species do akwarium $aquarium';
  }

  @override
  String get viewLivestock => 'Zobacz obsadę';

  @override
  String get difficultyVeryEasy => 'bardzo łatwa';

  @override
  String get difficultyEasy => 'łatwa';

  @override
  String get difficultyMedium => 'średnia';

  @override
  String get difficultyHard => 'trudna';

  @override
  String get zoneBottom => 'dno';

  @override
  String get zoneMiddle => 'środek';

  @override
  String get zoneTop => 'powierzchnia';

  @override
  String get zoneAll => 'cały zbiornik';

  @override
  String addSpeciesDialogTitle(String name) {
    return 'Dodaj $name';
  }

  @override
  String get additionDateLabel => 'Data dodania';

  @override
  String get notesOptionalLabel => 'Notatki (opcjonalnie)';

  @override
  String get nameDisplayedOnDashboard => 'Imię wyświetlane na pulpicie';

  @override
  String get apiKeyLabel => 'Klucz API';

  @override
  String get apiKeyHint => 'Pozostaw puste, aby użyć klucza domyślnego';

  @override
  String get geminiApiKeyManualHint =>
      'Wprowadź klucz API Gemini, aby włączyć skaner AI.';

  @override
  String get testApiKey => 'Testuj klucz API';

  @override
  String get useDefaultKey => 'Użyj domyślnego klucza';

  @override
  String get cloudSyncDescription =>
      'Twoje dane są bezpiecznie synchronizowane w chmurze';

  @override
  String get editProfileName => 'Imię profilu';

  @override
  String get profileNameLabel => 'Imię';

  @override
  String profileNameSaved(String name) {
    return 'Zapisano imię profilu: $name';
  }

  @override
  String profileNameSaveFailed(String error) {
    return 'Nie udało się zapisać imienia: $error';
  }

  @override
  String get signInToChangeProfileName =>
      'Zaloguj się, aby zmienić imię profilu.';

  @override
  String get referralSubtitle =>
      'Poleć znajomych i odbierz darmowy miesiąc PRO';

  @override
  String get helpCenterSubtitle => 'FAQ, nowe zgłoszenia i historia kontaktu';

  @override
  String get activeAquariumSection => 'Aktywne akwarium';

  @override
  String get noActiveAquarium => 'Brak aktywnego akwarium';

  @override
  String get addAquariumToStart => 'Dodaj akwarium, aby rozpocząć';

  @override
  String get freshwaterType => 'Słodkowodne';

  @override
  String get saltwaterType => 'Morskie';

  @override
  String get plantedTankType => 'Roślinne / holenderskie';

  @override
  String get biotopeTankType => 'Biotopowe';

  @override
  String get shrimpTankType => 'Krewetkarium';

  @override
  String get dashboardNoAquarium =>
      'Nie masz jeszcze akwarium. Dodaj akwarium, aby zobaczyć jego pulpit.';

  @override
  String get noScheduledTasks => 'Brak zaplanowanych zadań.';

  @override
  String get unnamedReminder => 'Przypomnienie';

  @override
  String get manageTaskReminders => 'Zarządzaj przypomnieniami zadań';

  @override
  String get remindersScreenTitle => 'Przypomnienia zadań';

  @override
  String get activateProForReminders =>
      'Aktywuj PRO, aby zarządzać przypomnieniami';

  @override
  String get addReminder => 'Dodaj przypomnienie';

  @override
  String get remindersLoadError => 'Nie udało się wczytać przypomnień.';

  @override
  String get overdueTasks => 'Zaległe';

  @override
  String get todayAndUpcomingTasks => 'Dzisiaj i nadchodzące';

  @override
  String get completedTasks => 'Wykonane';

  @override
  String get snoozeOneDay => 'Odłóż o 1 dzień';

  @override
  String get markReminderIncomplete => 'Oznacz jako niewykonane';

  @override
  String get markReminderComplete => 'Oznacz jako wykonane';

  @override
  String get editReminder => 'Edytuj zadanie';

  @override
  String get editReminderDialogTitle => 'Edytuj zadanie';

  @override
  String get showMoreTasks => 'Pokaż więcej zadań';

  @override
  String get showFewerTasks => 'Pokaż mniej zadań';

  @override
  String get ammoniaParameterLabel => 'Amoniak (NH3/NH4)';

  @override
  String get waterChangesSyncFailed =>
      'Nie udało się zsynchronizować historii podmian. Wpis zapisano lokalnie i ponowi się po przywróceniu połączenia.';

  @override
  String get addReminderDialogTitle => 'Dodaj przypomnienie';

  @override
  String get taskTypeLabel => 'Typ zadania';

  @override
  String get repeatLabel => 'Powtarzaj';

  @override
  String get oneTime => 'Jednorazowo';

  @override
  String get dailyRecurrence => 'Codziennie';

  @override
  String get everyXDays => 'Co X dni';

  @override
  String get weeklyRecurrence => 'Co tydzień';

  @override
  String get monthlyRecurrence => 'Co miesiąc';

  @override
  String get aquariumTaskSaveFailed =>
      'Nie udało się zapisać zadania. Spróbuj ponownie.';

  @override
  String get aquariumTaskUpdateFailed =>
      'Nie udało się zaktualizować zadania. Spróbuj ponownie.';

  @override
  String get repeatEveryDays => 'Powtarzaj co ile dni';

  @override
  String get daysProFeature => 'dni · funkcja PRO';

  @override
  String get daysUnit => 'dni';

  @override
  String get enterPositiveDays => 'Wpisz liczbę dni większą od zera.';

  @override
  String everyDays(int days) {
    return 'Co $days dni';
  }

  @override
  String get reminderTaskWaterChange => 'Podmiana wody';

  @override
  String get reminderTaskFilterClean => 'Czyszczenie filtra';

  @override
  String get reminderTaskWaterTest => 'Test parametrów';

  @override
  String get reminderTaskFertilizer => 'Nawożenie';

  @override
  String get reminderTaskCustom => 'Własne zadanie';

  @override
  String get scheduledAquariumTaskNotification =>
      'Zaplanowane zadanie akwarystyczne';

  @override
  String get localNotificationScheduleFailed =>
      'Nie udało się zaplanować powiadomienia.';

  @override
  String get chartHistoryTitle => 'Historia parametrów wody';

  @override
  String get chartTrendsTitle => 'Trendy parametrów wody';

  @override
  String get chartAddMeasurement => 'Dodaj pomiar';

  @override
  String get chartLoadError =>
      'Nie udało się wczytać pomiarów. Spróbuj ponownie.';

  @override
  String chartSaveError(String error) {
    return 'Nie udało się zapisać pomiaru: $error';
  }

  @override
  String chartNoParameterData(String parameter) {
    return 'Brak zapisanych pomiarów parametru $parameter.';
  }

  @override
  String chartNoParameterDataInRange(String parameter) {
    return 'Brak pomiarów parametru $parameter w wybranym zakresie.';
  }

  @override
  String get chartChooseParameter => 'Wybierz parametr';

  @override
  String chartChangeOverTime(String parameter) {
    return 'Zmiana w czasie · $parameter';
  }

  @override
  String chartOptimalRange(String min, String max, String unit) {
    return 'Optimum $min–$max $unit';
  }

  @override
  String get chartAddAnotherMeasurement => 'Dodaj kolejny pomiar';

  @override
  String chartLastMeasurement(String parameter) {
    return 'Ostatni pomiar · $parameter';
  }

  @override
  String get chartNoPreviousMeasurement => 'Brak wcześniejszego pomiaru';

  @override
  String get chartStableTrend => 'Stabilnie względem poprzedniego';

  @override
  String get chartRisingTrend => 'Wzrost względem poprzedniego';

  @override
  String get chartFallingTrend => 'Spadek względem poprzedniego';

  @override
  String get chartBelowRange => 'Poniżej zakresu';

  @override
  String get chartAboveRange => 'Powyżej zakresu';

  @override
  String get chartWithinRange => 'W zakresie';

  @override
  String chartStatus(String status) {
    return 'Status: $status';
  }

  @override
  String get chartEmptyTitle => 'Brak pomiarów wody';

  @override
  String get chartEmptyDescription =>
      'Dodaj pierwszy pomiar, aby zobaczyć trendy parametrów.';

  @override
  String get chartAddFirstMeasurement => 'Dodaj pierwszy pomiar';

  @override
  String get chartRange7Days => '7 dni';

  @override
  String get chartRange30Days => '30 dni';

  @override
  String get chartRange90Days => '90 dni';

  @override
  String get chartRangeAll => 'Wszystko';

  @override
  String get chartNewMeasurement => 'Nowy pomiar wody';

  @override
  String get chartOptionalNote => 'Notatka (opcjonalnie)';

  @override
  String get chartEnterValue => 'Wpisz wartość.';

  @override
  String get chartInvalidNumber => 'Wpisz poprawną liczbę.';

  @override
  String get chartSaving => 'Zapisywanie...';

  @override
  String get chartTwoMeasurementsRequired =>
      'Dodaj co najmniej dwa pomiary, aby zobaczyć wykres.';

  @override
  String get repeatEveryLabel => 'Powtarzaj co';

  @override
  String lastPerformedOn(String date) {
    return 'Ostatnio: $date';
  }

  @override
  String get optionalLabel => 'opcjonalnie';

  @override
  String speciesMinimumVolumeFrom(int liters) {
    return 'od $liters l';
  }

  @override
  String deleteLivestockConfirmation(String speciesName) {
    return 'Czy na pewno usunąć $speciesName z obsady akwarium?';
  }

  @override
  String get proFeatureTrialHeadline =>
      'Funkcja PRO - aktywuj darmowy okres próbny';

  @override
  String get geminiConnectionSucceeded => 'Połączenie z Gemini działa.';

  @override
  String get plantQuantityUnit => 'Jednostka ilości roślin';

  @override
  String get quantityPieces => 'szt.';

  @override
  String get quantityPortions => 'porcje';

  @override
  String get quantityBaskets => 'koszyki';

  @override
  String get equipmentTitle => 'Sprzęt i pielęgnacja';

  @override
  String get equipmentLighting => 'Oświetlenie';

  @override
  String get equipmentLightingPower => 'Moc oświetlenia';

  @override
  String get equipmentPhotoperiod => 'Czas świecenia dziennie';

  @override
  String get equipmentCo2System => 'System CO2';

  @override
  String get equipmentCo2Bubbles => 'Bąbelki CO2 na sekundę';

  @override
  String get equipmentFeeding => 'Informacje o karmieniu';

  @override
  String get equipmentNotConfigured =>
      'Nie dodano jeszcze informacji o sprzęcie ani pielęgnacji.';

  @override
  String get equipmentSaved => 'Zapisano informacje o sprzęcie i pielęgnacji.';

  @override
  String get equipmentInvalidNumber => 'Wpisz poprawną liczbę.';

  @override
  String compatibilityVolumeWarning(int actual, int minimum) {
    return 'Pojemność akwarium jest za mała: $actual l; wymagane minimum to $minimum l.';
  }

  @override
  String compatibilityPhWarning(num value, num min, num max) {
    return 'pH akwarium ($value) jest poza zalecanym zakresem $min-$max.';
  }

  @override
  String compatibilityTemperatureWarning(num value, num min, num max) {
    return 'Temperatura akwarium ($value°C) jest poza zalecanym zakresem $min-$max°C.';
  }

  @override
  String get waterAssessmentCritical => 'Krytyczny';

  @override
  String get waterAssessmentWarning => 'Uwaga';

  @override
  String get waterAssessmentOutsideOptimum => 'Poza optimum';

  @override
  String get waterAssessmentNormal => 'W normie';

  @override
  String get waterTestsSyncFailed =>
      'Nie udało się zsynchronizować historii pomiarów wody. Sprawdź połączenie i logowanie.';

  @override
  String get waterAssessmentCriticalNo3 =>
      'Krytyczny poziom NO3. Zalecana podmiana 30% wody.';

  @override
  String get waterAssessmentPhOutsideSafeRange =>
      'pH poza bezpiecznym zakresem 6,0-8,0.';

  @override
  String get waterAssessmentHighNo3 =>
      'Wysoki poziom NO3. Zalecana podmiana 30% wody.';

  @override
  String get waterAssessmentLowPo4 => 'Niski PO4 zwiększa ryzyko zielenic.';

  @override
  String get waterAssessmentHighPo4 =>
      'Wysoki PO4 zwiększa ryzyko krasnorostów.';

  @override
  String waterAssessmentOutsideMeasurementRange(String parameter) {
    return '$parameter poza zakresem pomiarowym.';
  }

  @override
  String waterAssessmentOutsideOptimalRange(
    String parameter,
    num min,
    num max,
    String unit,
  ) {
    return '$parameter poza optimum $min-$max$unit.';
  }

  @override
  String get waterAssessmentWithinOptimalRange =>
      'Parametr znajduje się w optymalnym zakresie.';

  @override
  String get waterAssessmentRedfieldRatio =>
      'Stosunek NO3:PO4 poza sugerowanym zakresem 10:1-16:1.';

  @override
  String get diagnosticCyanobacteriaRiskTitle => 'Ryzyko sinic';

  @override
  String get diagnosticCyanobacteriaRiskMessage =>
      'Bardzo niski NO3 przy obecnym PO4 może sprzyjać sinicom.';

  @override
  String get diagnosticGreenAlgaeRiskTitle => 'Ryzyko zielenic';

  @override
  String get diagnosticGreenAlgaeRiskMessage =>
      'Niski PO4 przy wyższym NO3 może sprzyjać zielenicom.';

  @override
  String get diagnosticDangerousCo2Title => 'Niebezpieczny poziom CO2';

  @override
  String get diagnosticDangerousCo2Message =>
      'CO2 powyżej 30 ppm może powodować przyduchę ryb.';

  @override
  String get diagnosticLowCo2Title => 'Niestabilne lub niskie CO2';

  @override
  String get diagnosticLowCo2Message =>
      'Niski poziom CO2 może osłabiać rośliny i sprzyjać krasnorostom.';

  @override
  String get diagnosticRedAlgaeRiskTitle => 'Ryzyko krasnorostów';

  @override
  String get diagnosticRedAlgaeRiskMessage =>
      'Wahania pH/CO2 osłabiają rośliny i sprzyjają krasnorostom.';

  @override
  String get diagnosticExcessiveLightingTitle => 'Długi czas świecenia';

  @override
  String get diagnosticExcessiveLightingMessage =>
      'Ponad 9 godzin światła może wzmacniać presję glonów.';

  @override
  String get diagnosticStableParametersTitle => 'Parametry wyglądają stabilnie';

  @override
  String get diagnosticStableParametersMessage =>
      'Nie znaleziono typowych sygnałów nierównowagi.';

  @override
  String get diagnosticActionStabilizeNo3 =>
      'Przywróć mierzalny, stabilny poziom NO3 bez gwałtownego nawożenia.';

  @override
  String get diagnosticActionSupplementPo4 =>
      'Sprawdź i uzupełniaj PO4 stopniowo, kontrolując NO3.';

  @override
  String get diagnosticActionReduceCo2AndIncreaseSurfaceMovement =>
      'Natychmiast ogranicz CO2 i zwiększ ruch tafli wody.';

  @override
  String get diagnosticActionStabilizeCo2 =>
      'Ustabilizuj podawanie CO2 i obserwuj reakcję roślin przez kilka dni.';

  @override
  String get diagnosticActionStabilizeCo2AndCirculation =>
      'Utrzymuj stałe CO2 oraz popraw cyrkulację w całym zbiorniku.';

  @override
  String get diagnosticActionReduceLighting =>
      'Na czas stabilizacji skróć świecenie do 6-8 godzin.';

  @override
  String get diagnosticActionContinueRegularTesting =>
      'Kontynuuj regularne pomiary i utrzymuj stały harmonogram podmian.';

  @override
  String get diagnosticActionMaintainRedfieldRatio =>
      'Utrzymuj NO3:PO4 w stabilnym zakresie około 10-20:1.';

  @override
  String get diagnosticRedfieldRatioNoData => 'Stosunek NO3:PO4: brak danych';

  @override
  String diagnosticRedfieldRatio(String ratio) {
    return 'Stosunek NO3:PO4: $ratio:1';
  }

  @override
  String get diagnosticActionPlanTitle => 'Plan działania';

  @override
  String get lastSyncLabel => 'Ostatnia synchronizacja:';

  @override
  String get lastSyncNone => 'brak zapisanych danych';

  @override
  String get done => 'Gotowe';

  @override
  String get editAction => 'Edytuj';

  @override
  String get deleteAction => 'Usuń';

  @override
  String get referralTitle => 'Program poleceń';

  @override
  String get referralHeroTitle =>
      'Polecaj Akwarysta PRO i zyskaj darmowy dostęp!';

  @override
  String get referralHeroDescription =>
      'Zyskaj 1 miesiąc PRO za każde 3 zaproszone osoby. Twoi znajomi otrzymają 50% zniżki na pierwszy rok.';

  @override
  String get referralCodeSection => 'Twój kod';

  @override
  String get copyCode => 'Kopiuj';

  @override
  String get shareLink => 'Udostępnij';

  @override
  String get codeCopied => 'Kod został skopiowany do schowka!';

  @override
  String referralProgress(int count) {
    return '$count / 3 zaliczonych poleceń';
  }

  @override
  String get invitedUsers => 'Zaproszone osoby';

  @override
  String get noReferrals => 'Nie masz jeszcze żadnych poleceń.';

  @override
  String get referralAccepted => 'Rejestracja zaakceptowana';

  @override
  String get activePro => 'Aktywne PRO';

  @override
  String get referralCompleted => 'Polecenie zaliczone';

  @override
  String get awaitingProActivation => 'Oczekuje na aktywację PRO';

  @override
  String get referralGoalReached =>
      'Cel osiągnięty! Twój darmowy miesiąc PRO jest gotowy.';

  @override
  String get referralProgressHint =>
      'Każde aktywne polecenie przybliża Cię do darmowego miesiąca PRO.';

  @override
  String get referralLoadErrorTitle => 'Nie udało się załadować programu';

  @override
  String get connectionRetry => 'Sprawdź połączenie i spróbuj ponownie.';

  @override
  String get retry => 'Spróbuj ponownie';

  @override
  String get refreshReferrals => 'Odśwież polecenia';

  @override
  String referralShareText(String code) {
    return 'Dołącz do mnie w Akwarysta PRO i zgarnij 50% zniżki na pierwszy rok! Użyj mojego kodu: $code';
  }

  @override
  String get referralCodeTooShort => 'Kod jest za krótki.';

  @override
  String get referralInvalidCode => 'Nie znaleziono takiego kodu polecającego.';

  @override
  String get referralSelfReferral =>
      'Nie możesz użyć własnego kodu polecającego.';

  @override
  String get referralDeviceUsed =>
      'Ten kod został już wykorzystany na tym urządzeniu.';

  @override
  String get referralAlreadyReferred =>
      'To konto ma już przypisany kod polecający.';

  @override
  String get referralEmailUnverified =>
      'Potwierdź adres e-mail, aby zaliczyć polecenie.';

  @override
  String get referralOperationUnavailable =>
      'Nie można teraz wykonać tej operacji.';

  @override
  String get referralUnauthenticated => 'Sesja wygasła. Zaloguj się ponownie.';

  @override
  String get referralUnavailable =>
      'Program poleceń jest chwilowo niedostępny. Spróbuj ponownie.';

  @override
  String get referralInternal =>
      'Nie udało się przygotować kodu. Spróbuj ponownie.';

  @override
  String get referralGenericError =>
      'Nie udało się wykonać operacji programu poleceń.';

  @override
  String get helpCenterTitle => 'Centrum pomocy';

  @override
  String get helpHeroTitle => 'Jesteśmy tu, żeby pomóc';

  @override
  String get helpHeroDescription =>
      'Opisz problem, a zespół Akwarysta PRO wróci do Ciebie z odpowiedzią.';

  @override
  String get createTicket => 'Utwórz nowe zgłoszenie';

  @override
  String myTicketsCount(int count) {
    return 'Moje zgłoszenia ($count)';
  }

  @override
  String get quickAnswers => 'Szybkie odpowiedzi';

  @override
  String get faqAiTitle => 'Jak działa skaner AI i weryfikacja parametrów?';

  @override
  String get faqAiAnswer =>
      'Skaner AI pomaga rozpoznać problem na zdjęciu. Wyniki testów wody aplikacja porównuje z normami temperatury, pH i twardości dla wybranego akwarium.';

  @override
  String get faqNo3Title => 'Co zrobić, gdy azotany (NO3) są za wysokie?';

  @override
  String get faqNo3Answer =>
      'Wykonaj częściową podmianę wody, ogranicz przekarmianie i sprawdź filtrację biologiczną. Powtarzaj pomiary po podmianie, zamiast obniżać NO3 gwałtownie.';

  @override
  String get faqRemindersTitle =>
      'Jak ustawić przypomnienia o podmianie i filtrze?';

  @override
  String get faqRemindersAnswer =>
      'Otwórz Dziennik i przypomnienia, wybierz dodanie zadania, ustaw termin oraz częstotliwość. Powiadomienia wymagają zgody systemu.';

  @override
  String get faqTransferTitle => 'Jak przenieść dane na nowe urządzenie?';

  @override
  String get faqTransferAnswer =>
      'Zaloguj się na nowym urządzeniu tym samym kontem. Dane zapisane w chmurze zostaną zsynchronizowane po chwili.';

  @override
  String get faqSubscriptionTitle => 'Jak anulować lub zmienić plan PRO?';

  @override
  String get faqSubscriptionAnswer =>
      'Subskrypcją zarządza się w ustawieniach Google Play lub App Store, zależnie od miejsca zakupu. Zmiany planu nie usuwają danych akwarium.';

  @override
  String get faqMultipleAquariumsTitle =>
      'Czy mogę zarządzać kilkoma akwariami?';

  @override
  String get faqMultipleAquariumsAnswer =>
      'Tak. Przełączaj aktywne akwarium z poziomu zarządzania akwariami. Plan PRO nie ogranicza liczby zapisanych zbiorników.';

  @override
  String get newTicketTitle => 'Nowe zgłoszenie';

  @override
  String get ticketCategory => 'Kategoria';

  @override
  String get adminDashboardTitle => 'Panel administratora';

  @override
  String get adminDashboardSubtitle =>
      'Zarządzaj użytkownikami, zgłoszeniami i subskrypcjami';

  @override
  String get adminStatsTab => 'Statystyki';

  @override
  String get adminTicketsTab => 'Zgłoszenia';

  @override
  String get adminUsersTab => 'Użytkownicy';

  @override
  String get adminAccessDenied => 'Wymagany dostęp administratora.';

  @override
  String get adminLoading => 'Wczytywanie danych administratora...';

  @override
  String adminLoadError(String error) {
    return 'Nie udało się wczytać danych administratora: $error';
  }

  @override
  String get adminRetry => 'Spróbuj ponownie';

  @override
  String get adminTotalUsers => 'Zarejestrowani użytkownicy';

  @override
  String get adminActivePro => 'Aktywne PRO';

  @override
  String get adminMonthlyPlans => 'Plany miesięczne';

  @override
  String get adminYearlyPlans => 'Plany roczne';

  @override
  String get adminManualGrants => 'Ręczne nadania';

  @override
  String get adminTotalTickets => 'Wszystkie zgłoszenia';

  @override
  String get adminOpenTickets => 'Otwarte zgłoszenia';

  @override
  String get adminSuccessfulReferrals => 'Pomyślne polecenia';

  @override
  String get adminFilterAll => 'Wszystkie';

  @override
  String get adminFilterOpen => 'Otwarte';

  @override
  String get adminFilterInProgress => 'W trakcie';

  @override
  String get adminFilterClosed => 'Zamknięte';

  @override
  String get adminNoTickets => 'Brak zgłoszeń do wyświetlenia.';

  @override
  String get adminStatusOpen => 'Otwarte';

  @override
  String get adminStatusInProgress => 'W trakcie';

  @override
  String get adminStatusResolved => 'Rozwiązane';

  @override
  String get adminStatusClosed => 'Zamknięte';

  @override
  String get adminTicketDetails => 'Szczegóły zgłoszenia';

  @override
  String get adminTicketDescription => 'Treść zgłoszenia';

  @override
  String get adminTicketEmail => 'E-mail zgłaszającego';

  @override
  String get adminTicketCategory => 'Kategoria';

  @override
  String adminTicketCreated(String date) {
    return 'Utworzono: $date';
  }

  @override
  String get adminTicketAttachment => 'Załącznik';

  @override
  String get adminSupportReply => 'Odpowiedź wsparcia';

  @override
  String get adminSaveTicket => 'Zapisz zgłoszenie';

  @override
  String get adminTicketSaved => 'Zgłoszenie zostało zaktualizowane.';

  @override
  String get adminSearchUsers => 'Szukaj po imieniu lub e-mailu';

  @override
  String get adminNoUsers => 'Nie znaleziono użytkowników.';

  @override
  String get adminFreePlan => 'Darmowe';

  @override
  String get adminProPlan => 'PRO';

  @override
  String adminReferralsCount(int count) {
    return '$count pomyślnych poleceń';
  }

  @override
  String get adminUserDetails => 'Szczegóły użytkownika';

  @override
  String get adminUserEmail => 'E-mail';

  @override
  String get adminSubscriptionPlan => 'Plan subskrypcji';

  @override
  String adminExpiryDate(String date) {
    return 'Wygasa: $date';
  }

  @override
  String get adminNoExpiry => 'Bezterminowo';

  @override
  String get adminGrantPro => 'Nadaj PRO';

  @override
  String get adminRevokePro => 'Odbierz PRO';

  @override
  String get adminGrantProTitle => 'Przyznaj dostęp PRO';

  @override
  String get adminGrantDuration => 'Wybierz czas dostępu';

  @override
  String get adminDuration7Days => '7 dni';

  @override
  String get adminDuration14Days => '14 dni';

  @override
  String get adminDuration1Month => '1 miesiąc';

  @override
  String get adminDuration1Year => '1 rok';

  @override
  String get adminDurationIndefinite => 'Bezterminowo';

  @override
  String get adminGrantSuccess => 'Dostęp PRO został przyznany.';

  @override
  String get adminRevokeSuccess => 'Dostęp PRO został odebrany.';

  @override
  String get adminInvitedUsers => 'Zaproszone osoby';

  @override
  String get adminNoInvitedUsers => 'Brak zaproszonych osób.';

  @override
  String get adminReferralPending => 'Oczekujące';

  @override
  String get adminReferralCompleted => 'Zakończone';

  @override
  String get adminNameUnavailable => 'Brak nazwy';

  @override
  String get adminConfirmRevokeTitle => 'Odebrać dostęp PRO?';

  @override
  String get adminConfirmRevokeBody =>
      'Użytkownik natychmiast utraci dostęp PRO.';

  @override
  String get adminConfirm => 'Potwierdź';

  @override
  String get adminCancel => 'Anuluj';

  @override
  String get ticketBugCategory => '🐛 Zgłoś błąd w aplikacji';

  @override
  String get ticketFeatureCategory => '💡 Propozycja funkcji / pomysł';

  @override
  String get ticketSubscriptionCategory =>
      '💳 Problem z płatnością / subskrypcją PRO';

  @override
  String get ticketBusinessCategory => '🤝 Współpraca / kontakt biznesowy';

  @override
  String get ticketOtherCategory => '❓ Inne zapytanie';

  @override
  String get ticketSubject => 'Tytuł';

  @override
  String get ticketSubjectHint => 'Krótko opisz problem';

  @override
  String get ticketDescription => 'Szczegółowy opis';

  @override
  String get ticketDescriptionHint =>
      'Co się wydarzyło? Jak można odtworzyć problem?';

  @override
  String get ticketDescriptionMin => 'Opis musi mieć co najmniej 15 znaków.';

  @override
  String get ticketSubjectRequired => 'Wpisz tytuł zgłoszenia.';

  @override
  String get ticketAuthRequired => 'Zaloguj się, aby wysłać zgłoszenie.';

  @override
  String get ticketPermissionError =>
      'Brak uprawnień do zgłoszeń. Zaloguj się ponownie.';

  @override
  String get ticketOfflineError =>
      'Brak połączenia z internetem. Sprawdź sieć i spróbuj ponownie.';

  @override
  String get ticketIndexError =>
      'Nie można pobrać zgłoszeń. Baza danych wymaga indeksu Firestore.';

  @override
  String get ticketGenericError =>
      'Nie udało się wykonać operacji. Spróbuj ponownie.';

  @override
  String get attachImage => 'Załącz zdjęcie / zrzut ekranu';

  @override
  String changeAttachment(String name) {
    return 'Zmień załącznik: $name';
  }

  @override
  String get removeAttachment => 'Usuń załącznik';

  @override
  String get sendingTicket => 'Wysyłanie...';

  @override
  String get sendTicket => 'Wyślij zgłoszenie';

  @override
  String get ticketSent => 'Zgłoszenie zostało wysłane.';

  @override
  String ticketPhotoReadError(String error) {
    return 'Nie udało się odczytać zdjęcia: $error';
  }

  @override
  String get myTicketsTitle => 'Moje zgłoszenia';

  @override
  String get noTickets => 'Nie masz jeszcze żadnych zgłoszeń.';

  @override
  String get ticketDetails => 'Szczegóły zgłoszenia';

  @override
  String get ticketSupportReply => 'Odpowiedź od wsparcia';

  @override
  String ticketCreatedAt(String date) {
    return 'Utworzono: $date';
  }

  @override
  String get ticketDescriptionSection => 'Opis zgłoszenia';

  @override
  String get ticketTechnicalInfo => 'Informacje techniczne';

  @override
  String get ticketAttachmentError => 'Nie udało się wyświetlić załącznika.';

  @override
  String get ticketStatusOpen => 'Otwarte';

  @override
  String get ticketStatusInProgress => 'W trakcie';

  @override
  String get ticketStatusResolved => 'Rozwiązane';

  @override
  String get ticketStatusClosed => 'Zamknięte';

  @override
  String get categoryShrimp => 'Krewetki';

  @override
  String get categorySnails => 'Ślimaki';

  @override
  String get categoryCrabs => 'Kraby';

  @override
  String get categoryCorals => 'Korale';

  @override
  String get feedingNotes => 'Karmienie';

  @override
  String get behaviorNotes => 'Zachowanie';

  @override
  String get careNotes => 'Wymagania pielęgnacyjne';

  @override
  String get compatibilityNotChecked => 'Niepełna ocena';

  @override
  String livestockUnverifiedSpecies(int count) {
    return 'Nie oceniono $count pozycji spoza katalogu. Sprawdź ich wymagania ręcznie.';
  }

  @override
  String get categoryOther => 'Inne';

  @override
  String get categoryFauna => 'Fauna';

  @override
  String get categoryFlora => 'Flora';

  @override
  String get speciesCategoryLabel => 'Gatunki';

  @override
  String get category => 'Kategoria';

  @override
  String livestockCount(int count) {
    return 'Liczba: $count';
  }

  @override
  String get plantPositionForeground => 'I plan';

  @override
  String get plantPositionMidground => 'II plan';

  @override
  String get plantPositionBackground => 'III plan';

  @override
  String get plantPositionEpiphyte => 'Epifit';

  @override
  String get plantPositionFloating => 'Pływająca';

  @override
  String get plantPositionFieldLabel => 'Pozycja rośliny';

  @override
  String get journalCategoryObservation => 'Obserwacja';

  @override
  String get journalCategoryFishHealth => 'Zdrowie ryb';

  @override
  String get journalCategoryPlantGrowth => 'Wzrost roślin';

  @override
  String get journalCategoryAlgae => 'Glony';

  @override
  String get journalCategoryEquipment => 'Sprzęt / inwestycje';

  @override
  String get aquariumsSectionTitle => 'Moje akwaria';

  @override
  String get cloudSyncSubtitle => 'Dane synchronizowane w chmurze';

  @override
  String get addAquariumTooltip => 'Dodaj akwarium';

  @override
  String get aquariumAddedMessage => 'Akwarium zostało dodane.';

  @override
  String get aquariumUpdatedMessage => 'Akwarium zostało zapisane.';

  @override
  String get deleteAquariumTitle => 'Usunąć akwarium?';

  @override
  String deleteAquariumPrompt(String name) {
    return 'Akwarium „$name” i wszystkie jego pomiary zostaną usunięte.';
  }

  @override
  String get aquariumDeletedMessage => 'Akwarium zostało usunięte.';

  @override
  String get aquariumLoadError =>
      'Nie udało się wczytać akwariów. Spróbuj ponownie.';

  @override
  String aquariumPickerLoadError(String error) {
    return 'Nie udało się wczytać akwariów: $error';
  }

  @override
  String aquariumEstablishedOn(String date) {
    return 'Założone $date';
  }

  @override
  String get addAquariumTitle => 'Dodaj akwarium';

  @override
  String get aquariumNameLabel => 'Nazwa akwarium';

  @override
  String get aquariumNameRequired => 'Podaj nazwę akwarium.';

  @override
  String get aquariumCapacityLabel => 'Pojemność';

  @override
  String get aquariumCapacityInvalid => 'Podaj pojemność większą od zera.';

  @override
  String get aquariumTypeLabel => 'Typ akwarium';

  @override
  String get aquariumSetupDateLabel => 'Data założenia';

  @override
  String get aquariumOptionsTooltip => 'Opcje akwarium';

  @override
  String get noAquariumsAdded => 'Brak dodanych akwariów';

  @override
  String get addFirstAquariumAction => 'Dodaj pierwsze akwarium';

  @override
  String get aquariumDetailsTitle => 'Szczegóły akwarium';

  @override
  String get aquariumDetailsLoadError =>
      'Nie udało się wczytać szczegółów akwarium.';

  @override
  String get noWaterMeasurements => 'Brak pomiarów parametrów wody.';

  @override
  String get reportPdfAction => 'Generuj raport PDF';

  @override
  String get reportProHeadline =>
      'Generuj profesjonalne raporty PDF swoich akwariów z Akwarysta PRO.';

  @override
  String reportGenerationError(String error) {
    return 'Nie udało się wygenerować raportu: $error';
  }

  @override
  String get estimatedWeightLabel => 'Szacowana waga';

  @override
  String get browseSpeciesAtlas => 'Przeglądaj atlas gatunków';

  @override
  String get addCustomSpecies => 'Dodaj własny gatunek';

  @override
  String get speciesNameLabel => 'Nazwa gatunkowa';

  @override
  String get speciesNameRequired => 'Wpisz nazwę gatunku.';

  @override
  String get latinNameOptionalLabel => 'Nazwa łacińska (opcjonalnie)';

  @override
  String get speciesCountLabel => 'Liczba sztuk';

  @override
  String get positiveCountRequired => 'Wpisz liczbę większą od zera.';

  @override
  String get addFirstSpecies => 'Dodaj pierwszy gatunek';

  @override
  String get livestockLoadError => 'Nie udało się wczytać obsady akwarium.';

  @override
  String livestockSyncError(String error) {
    return 'Nie udało się zsynchronizować obsady: $error';
  }

  @override
  String get signInToViewLivestock => 'Zaloguj się, aby zobaczyć obsadę.';

  @override
  String get unknownSpecies => 'Nieznany gatunek';

  @override
  String addedOnDate(String date) {
    return 'Dodano: $date';
  }

  @override
  String get decreaseQuantityTooltip => 'Zmniejsz ilość';

  @override
  String get increaseQuantityTooltip => 'Zwiększ ilość';

  @override
  String get stockHealthTitle => 'Zdrowie i zgodność obsady';

  @override
  String get livestockWarnings => 'Ostrzeżenia';

  @override
  String get livestockCompatible => 'Zgodna';

  @override
  String minimumVolumeForStock(int required, String capacity) {
    return 'Minimalna objętość dla obsady: $required l / $capacity l';
  }

  @override
  String stockCapacityExceeded(int liters) {
    return 'Wymagania obsady przekraczają pojemność akwarium o $liters l.';
  }

  @override
  String noSharedRangeFor(String conflicts) {
    return 'Brak wspólnego zakresu dla: $conflicts';
  }

  @override
  String get calendarTasksTitle => 'Kalendarz zadań';

  @override
  String get addTask => 'Dodaj zadanie';

  @override
  String get newTask => 'Nowe zadanie';

  @override
  String get taskTitleLabel => 'Tytuł';

  @override
  String get descriptionLabel => 'Opis';

  @override
  String get reminderTimeLabel => 'Godzina przypomnienia';

  @override
  String get noteLabel => 'Notatka';

  @override
  String get tagsCommaSeparated => 'Tagi, oddziel przecinkami';

  @override
  String get attachLatestWaterMeasurement => 'Podepnij ostatni pomiar wody';

  @override
  String photosReadyToSave(int count) {
    return '$count zdjęć gotowych do zapisu';
  }

  @override
  String get entryAddedMessage => 'Wpis został dodany.';

  @override
  String get reminderAddedMessage => 'Przypomnienie zostało dodane.';

  @override
  String get addEntryTooltip => 'Dodaj wpis';

  @override
  String get addReminderTooltip => 'Dodaj przypomnienie';

  @override
  String get calendarLoadError =>
      'Nie udało się wczytać kalendarza. Spróbuj ponownie później.';

  @override
  String get journalLoadError => 'Nie udało się wczytać dziennika.';

  @override
  String get noJournalEntries => 'Brak wpisów. Dodaj pierwszą obserwację.';

  @override
  String get compareBeforeAfterTitle => 'Porównywarka przed / po';

  @override
  String get photoCompareMinimumCount =>
      'Dodaj co najmniej dwa zdjęcia do dziennika.';

  @override
  String get photoThen => 'Wtedy';

  @override
  String get photoNow => 'Teraz';

  @override
  String get showPassword => 'Pokaż hasło';

  @override
  String get hidePassword => 'Ukryj hasło';

  @override
  String get back => 'Wróć';

  @override
  String get referralCodeOptional => 'Masz kod polecający? (opcjonalnie)';

  @override
  String get firebaseGenericError => 'Nie udało się połączyć z Firebase.';

  @override
  String get resetPasswordTitle => 'Resetowanie hasła';

  @override
  String get emailAddressLabel => 'Adres e-mail';

  @override
  String get sendResetLinkAction => 'Wyślij link';

  @override
  String get passwordResetSuccess => 'Link do resetu hasła został wysłany.';

  @override
  String get signInToViewPhotos => 'Zaloguj się, aby zobaczyć zdjęcia.';

  @override
  String get photoLoadError => 'Nie udało się wczytać zdjęć.';

  @override
  String get compareFirstLatestPhotos =>
      'Porównaj pierwsze i najnowsze zdjęcie';

  @override
  String get unlimitedPhotoJournal => 'Nielimitowany dziennik zdjęć';

  @override
  String get photoSavedMessage => 'Zdjęcie zostało zapisane.';

  @override
  String get photoCaptionTitle => 'Opis zdjęcia';

  @override
  String get optionalPhotoDescription => 'Opcjonalny opis';

  @override
  String get mainPhoto => 'Zdjęcie główne';

  @override
  String get setAsAquariumCover => 'Ustaw jako okładkę akwarium';

  @override
  String get twoPhotosRequired => 'Potrzebujesz co najmniej dwóch zdjęć.';

  @override
  String get compareProgressTitle => 'Porównaj postęp';

  @override
  String get maintenanceScheduleTitle => 'Harmonogram pielęgnacji';

  @override
  String get maintenanceLoadError => 'Nie udało się wczytać harmonogramu.';

  @override
  String get maintenanceEmpty => 'Nie dodano jeszcze zadań pielęgnacyjnych.';

  @override
  String maintenanceTaskAddedError(String error) {
    return 'Nie udało się dodać zadania: $error';
  }

  @override
  String maintenanceTaskUpdateError(String error) {
    return 'Nie udało się zaktualizować zadania: $error';
  }

  @override
  String maintenanceTaskCompleted(String title) {
    return 'Wykonano: $title';
  }

  @override
  String get editTaskTooltip => 'Edytuj zadanie';

  @override
  String get performTask => 'Wykonaj';

  @override
  String get taskOverdue => 'Po terminie!';

  @override
  String taskDueInDays(int days) {
    return 'Za $days dni';
  }

  @override
  String get maintenanceTaskTypeLabel => 'Rodzaj zadania';

  @override
  String get maintenanceLastPerformed => 'Ostatnio wykonano';

  @override
  String get maintenanceTaskFeeding => 'Karmienie';

  @override
  String get maintenanceTaskWaterChange => 'Podmiana wody';

  @override
  String get maintenanceTaskFilterCleaning => 'Czyszczenie filtra';

  @override
  String get maintenanceTaskPlantTrimming => 'Przycinanie roślin';

  @override
  String get maintenanceTaskFertilizing => 'Nawożenie';

  @override
  String get maintenanceTaskQuickCheck => 'Szybka kontrola';

  @override
  String get maintenanceTaskCustom => 'Inne zadanie';

  @override
  String get editMaintenanceTask => 'Edytuj zadanie';

  @override
  String get addMaintenanceTask => 'Dodaj zadanie pielęgnacyjne';

  @override
  String get fertilizerDoseInstructions =>
      'Podaj pojemność akwarium i wybierz rodzaj nawozu.';

  @override
  String get fertilizerVolumeExample => 'np. 100';

  @override
  String get litersUnit => 'litrów';

  @override
  String get fertilizerTypeLabel => 'Rodzaj nawozu';

  @override
  String get fertilizerMicro => 'Nawóz Mikro';

  @override
  String get fertilizerMacroNpk => 'Nawóz Makro (NPK)';

  @override
  String get fertilizerPotassium => 'Potas (K)';

  @override
  String get calculateDoseAction => 'Oblicz dawkę';

  @override
  String get enterAquariumVolume => 'Wpisz pojemność akwarium.';

  @override
  String get enterPositiveNumber => 'Wpisz liczbę większą od zera.';

  @override
  String get calculatorInvalidValues =>
      'Sprawdź wpisane wartości. Wymiary i objętość akwarium muszą być prawidłowe.';

  @override
  String netCapacitySaved(String liters) {
    return 'Zapisano pojemność netto: $liters l';
  }

  @override
  String get ammoniaNonDetectableTarget => 'Cel: poziom niewykrywalny (0 mg/L)';

  @override
  String get nitriteNonDetectableTarget => 'Cel: poziom niewykrywalny (0 mg/L)';

  @override
  String get waterAssessmentNitriteDetected =>
      'Wykryto NO2. Azotyny są szkodliwe dla ryb; sprawdź pomiar i zareaguj szybko.';

  @override
  String get waterAssessmentAmmoniaDetected =>
      'Wykryto NH3/NH4. Nawet niskie stężenie może szkodzić; ryzyko zależy od pH i temperatury.';

  @override
  String get waterAssessmentReferenceOnly => 'Informacja orientacyjna';

  @override
  String get tdsNoUniversalTarget =>
      'TDS nie ma uniwersalnego zakresu — porównuj z potrzebami obsady i wodą źródłową.';

  @override
  String get knowledgeBaseAddAquariumPrompt =>
      'Dodaj akwarium, aby sprawdzić zgodność gatunków.';

  @override
  String get diagnoseWithProTooltip => 'Diagnostyka PRO';

  @override
  String get knowledgeCategoryAlgae => 'Glony';

  @override
  String temperamentLabel(String value) {
    return 'Usposobienie: $value';
  }

  @override
  String get plantRequirementsTitle => 'Wymagania rośliny';

  @override
  String get lightLabel => 'Światło';

  @override
  String get co2Label => 'CO2';

  @override
  String get growthRateLabel => 'Tempo wzrostu';

  @override
  String get positionLabel => 'Pozycja';

  @override
  String get algaeSymptomsTitle => 'Objawy i zwalczanie';

  @override
  String get causesLabel => 'Przyczyny';

  @override
  String get symptomsLabel => 'Objawy';

  @override
  String get controlPlanLabel => 'Plan';

  @override
  String get difficultyAdvanced => 'zaawansowana';

  @override
  String get temperamentShoalingPeaceful => 'łagodny, stadny';

  @override
  String get temperamentShoalingPeacefulFeminine => 'łagodna, stadna';

  @override
  String get temperamentActivePeaceful => 'łagodny, aktywny';

  @override
  String get temperamentTerritorialPeaceful => 'spokojna, terytorialna';

  @override
  String get temperamentTerritorialMale => 'samiec terytorialny';

  @override
  String get lightLow => 'Niskie';

  @override
  String get lightLowMedium => 'Niskie do średniego';

  @override
  String get lightMedium => 'Średnie';

  @override
  String get lightMediumHigh => 'Średnie do wysokiego';

  @override
  String get co2NotRequired => 'Niewymagane';

  @override
  String get co2Optional => 'Opcjonalne';

  @override
  String get co2Recommended => 'Zalecane';

  @override
  String get growthSlow => 'Wolne';

  @override
  String get growthMedium => 'Średnie';

  @override
  String get growthFast => 'Szybkie';

  @override
  String get plantPositionMiddleRoot => 'Środek / korzeń';

  @override
  String get plantPositionMiddleBackground => 'Środek / tył';

  @override
  String get plantPositionMiddle => 'Środek';

  @override
  String get plantPositionBack => 'Tył';

  @override
  String get plantPositionFront => 'Przód';

  @override
  String get plantPositionCarpet => 'Trawnik';

  @override
  String get algaeNameBlackBeard => 'Krasnorosty';

  @override
  String get algaeNameGreen => 'Zielenice';

  @override
  String get algaeNameCyanobacteria => 'Sinice';

  @override
  String get algaeNameDiatoms => 'Okrzemki';

  @override
  String get algaeCauseCo2Fluctuations => 'Wahania CO2';

  @override
  String get algaeCausePoorCirculation => 'Słaba cyrkulacja';

  @override
  String get algaeCauseUnstableFertilization => 'Niestabilne nawożenie';

  @override
  String get algaeCauseExcessLight => 'Nadmiar światła';

  @override
  String get algaeCausePo4Deficiency => 'Niedobór PO4';

  @override
  String get algaeCauseUnstableCo2 => 'Niestabilne CO2';

  @override
  String get algaeCauseNo3Deficiency => 'Brak NO3';

  @override
  String get algaeCauseStagnantWater => 'Zastoiny wody';

  @override
  String get algaeCauseOrganicMatter => 'Nadmiar materii organicznej';

  @override
  String get algaeCauseNewTank => 'Nowy zbiornik';

  @override
  String get algaeCauseSilicates => 'Krzemiany w wodzie';

  @override
  String get algaeCauseImmatureFilter => 'Niedojrzały filtr';

  @override
  String get algaeSymptomBlackTufts =>
      'Czarne lub czerwone kępki na liściach i dekoracjach';

  @override
  String get algaeSymptomGreenFilm =>
      'Zielony nalot na szybach lub punktowe plamy na liściach';

  @override
  String get algaeSymptomCyanobacteriaMat =>
      'Śluzowata niebieskozielona warstwa o charakterystycznym zapachu';

  @override
  String get algaeSymptomBrownDust =>
      'Brązowy pył na szybach, podłożu i dekoracjach';

  @override
  String get algaeActionStabilizeCo2 =>
      'Ustabilizuj podawanie CO2 i popraw cyrkulację.';

  @override
  String get algaeActionRemoveAffected =>
      'Usuń mechanicznie porażone liście i dekoracje.';

  @override
  String get algaeActionReduceLight =>
      'Ogranicz światło do 6–8 godzin i obserwuj zbiornik przez tydzień.';

  @override
  String get algaeActionCleanGlass =>
      'Skróć świecenie i regularnie czyść szyby.';

  @override
  String get algaeActionSupplementPo4 =>
      'Sprawdź PO4 i uzupełniaj je stopniowo.';

  @override
  String get algaeActionAddFastPlants =>
      'Zwiększ masę szybko rosnących roślin.';

  @override
  String get algaeActionRemoveMat =>
      'Usuń matę mechanicznie i wykonaj większą podmianę wody.';

  @override
  String get algaeActionRestoreNo3 =>
      'Przywróć mierzalny poziom NO3 i popraw przepływ.';

  @override
  String get algaeActionReduceFeeding =>
      'Ogranicz światło oraz karmienie do czasu ustabilizowania zbiornika.';

  @override
  String get algaeActionCleanDiatoms =>
      'Usuwaj nalot przy podmianach i utrzymuj regularność prac.';

  @override
  String get algaeActionMatureFilter =>
      'Daj biologii czas na dojrzewanie i nie myj całego wkładu naraz.';

  @override
  String get algaeActionCheckSilicates =>
      'Sprawdź krzemiany w wodzie kranowej, jeśli problem trwa długo.';

  @override
  String get substrateActiveSoil => 'Soil aktywny';

  @override
  String get substrateMineral => 'Podłoże mineralne';

  @override
  String get substrateOther => 'Inne';

  @override
  String get changeAlgaePhoto => 'Zmień zdjęcie glonu';

  @override
  String get analyzingConditions => 'Analizuję warunki...';

  @override
  String get analyzingAlgaeAndParameters =>
      'Analizuję glony i parametry akwarium...';

  @override
  String algaeDiagnosisTitle(String name) {
    return 'Diagnoza glonów: $name';
  }

  @override
  String get actionPlanTitle => 'Plan działania';

  @override
  String get scannerAnalyzingPhoto => 'Analizuję zdjęcie...';

  @override
  String get scannerAnalyzingSpecies => 'Analizuję zdjęcie ryby/rośliny...';

  @override
  String scannerPhotoOpenError(String error) {
    return 'Nie udało się otworzyć zdjęcia: $error';
  }

  @override
  String get scannerAnalysisTimeout =>
      'Analiza trwała zbyt długo. Sprawdź połączenie i spróbuj ponownie.';

  @override
  String get scannerLockedTitle => 'Odblokuj inteligentny skaner AI';

  @override
  String get scannerLockedDescription =>
      'PRO analizuje zdrowie ryb, problemy roślin i glony na zdjęciach akwarium oraz proponuje konkretne dalsze kroki.';

  @override
  String get scannerUnlockPro => 'Odblokuj skaner PRO';

  @override
  String get scannerIntro =>
      'Zrób zdjęcie ryby, rośliny lub glonów, aby uzyskać ostrożną ocenę AI i zalecane działania.';

  @override
  String get scannerTakePhoto => 'Zrób zdjęcie';

  @override
  String get scannerChoosePhoto => 'Wybierz z galerii';

  @override
  String get scannerNoPhotoSelected =>
      'Wybierz lub zrób zdjęcie akwarium, aby rozpocząć.';

  @override
  String get scannerSelectingPhoto => 'Wczytuję wybrane zdjęcie...';

  @override
  String get scannerAnalyzeAction => 'Analizuj zdjęcie';

  @override
  String get scannerNewAnalysis => 'Rozpocznij nową analizę';

  @override
  String get scannerLoadingTitle => 'Analizuję obraz i objawy w akwarium...';

  @override
  String get scannerLoadingDescription =>
      'AI sprawdza widoczne oznaki. To może chwilę potrwać.';

  @override
  String get scannerErrorTitle => 'Nie udało się zakończyć analizy';

  @override
  String get scannerTryAgain => 'Spróbuj ponownie';

  @override
  String get scannerCameraPermissionDenied =>
      'Brak dostępu do aparatu. Zezwól na dostęp w ustawieniach urządzenia lub wybierz zdjęcie z galerii.';

  @override
  String get scannerCameraUnavailable =>
      'Aparat jest niedostępny na tym urządzeniu. Wybierz zdjęcie z galerii.';

  @override
  String get scannerPhotoPickerFailure =>
      'Nie udało się wybrać zdjęcia. Sprawdź uprawnienia i spróbuj ponownie.';

  @override
  String get scannerInvalidImage =>
      'Wybrane zdjęcie jest puste lub nie można go odczytać.';

  @override
  String get scannerApiKeyMissing =>
      'Skaner AI nie jest skonfigurowany. Dodaj klucz API Gemini w ustawieniach profilu.';

  @override
  String get scannerApiKeyInvalid =>
      'Usługa AI odrzuciła klucz API. Sprawdź klucz w ustawieniach profilu.';

  @override
  String get scannerNetworkFailure =>
      'Nie udało się połączyć z usługą AI. Sprawdź internet i spróbuj ponownie.';

  @override
  String get scannerServiceBusy =>
      'Usługa AI jest chwilowo zajęta. Spróbuj ponownie za chwilę.';

  @override
  String get scannerInvalidResponse =>
      'Usługa AI zwróciła nieczytelny wynik. Spróbuj zrobić wyraźniejsze zdjęcie.';

  @override
  String get scannerRequestFailure =>
      'Żądanie do AI nie powiodło się. Spróbuj ponownie.';

  @override
  String get scannerUnexpectedFailure =>
      'Wystąpił nieoczekiwany błąd podczas analizy zdjęcia.';

  @override
  String scannerConfidence(int percent) {
    return 'Pewność: $percent%';
  }

  @override
  String get scannerCategoryFishDisease => 'Możliwy problem zdrowotny ryby';

  @override
  String get scannerCategoryPlantIssue => 'Problem rośliny';

  @override
  String get scannerCategoryAlgae => 'Glony';

  @override
  String get scannerCategoryOther => 'Ogólna obserwacja';

  @override
  String get scannerCareNotice =>
      'Wskazówki AI to wstępna ocena, nie diagnoza weterynaryjna. Przed leczeniem potwierdź objawy i parametry wody.';

  @override
  String get purchaseNotConfigured => 'Plan niedostępny';

  @override
  String get loadingSubscriptionPrices => 'Pobieranie cen…';

  @override
  String get subscriptionStoreUnavailable =>
      'Sklep jest niedostępny. Spróbuj ponownie później.';

  @override
  String get subscriptionPurchasePending =>
      'Oczekiwanie na potwierdzenie zakupu…';

  @override
  String get subscriptionPurchaseCancelled => 'Zakup został anulowany.';

  @override
  String get subscriptionPurchaseFailed =>
      'Zakup nie powiódł się. Spróbuj ponownie.';

  @override
  String get mockAiUnavailable =>
      'Wynik demonstracyjny. Endpoint AI nie jest dostępny.';

  @override
  String recognizedSpecies(String name) {
    return 'Rozpoznano: $name';
  }

  @override
  String get livestockCompatibilityTitle => 'Zgodność z obsadą';

  @override
  String get closeAction => 'Zamknij';

  @override
  String compatibilityIncompatibleTemperatureRanges(
    String first,
    String second,
  ) {
    return '$first i $second nie mają wspólnego zakresu temperatur.';
  }

  @override
  String get journalSearchHint => 'Szukaj wpisów, tagów i obserwacji';

  @override
  String get newJournalEntry => 'Nowy wpis dziennika';

  @override
  String get galleryAction => 'Galeria';

  @override
  String get cameraAction => 'Aparat';

  @override
  String get photoAdded => 'Zdjęcie dodane';

  @override
  String get selectAquariumFirst => 'Najpierw wybierz akwarium.';

  @override
  String get healthy => 'Zdrowe';

  @override
  String get reminderOptionsTooltip => 'Opcje przypomnienia';

  @override
  String get reminderTaskFilter => 'Czyszczenie filtra';
}
