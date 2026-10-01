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
  String get parametersCount => '7 parametrów';

  @override
  String get waterChange => 'Podmiana';

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
  String get tryPro => 'Wypróbuj PRO';

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
      'Pomiar zostanie zapisany z aktualną datą i godziną.';

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
  String get monthlyPlan => 'Miesięczny';

  @override
  String get yearlyPlan => 'Roczny';

  @override
  String get mostPopularBadge => 'Najpopularniejszy';

  @override
  String get activatingEllipsis => 'Aktywowanie…';

  @override
  String get proActivatedMessage => 'Aktywowany status Akwarysta PRO.';

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
  String get addReminderDialogTitle => 'Dodaj przypomnienie';

  @override
  String get taskTypeLabel => 'Typ zadania';

  @override
  String get repeatLabel => 'Powtarzaj';

  @override
  String get oneTime => 'Jednorazowo';

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
  String speciesMinimumVolumeFrom(int liters) {
    return 'od $liters l';
  }

  @override
  String get proFeatureTrialHeadline =>
      'Funkcja PRO - aktywuj darmowy okres próbny';

  @override
  String get geminiConnectionSucceeded => 'Połączenie z Gemini działa.';

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
}
