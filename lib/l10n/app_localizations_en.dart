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
  String get addNewAquarium => 'Add new aquarium';

  @override
  String get freePlan => 'Free plan: 1 aquarium';

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

  @override
  String get yourDashboard => 'Your Dashboard';

  @override
  String get dashboardSubtitle => 'Everything important for your aquarium.';

  @override
  String get helloUser => 'Hello, Slawek! 👋';

  @override
  String get noNewNotifications => 'No new notifications';

  @override
  String get aquariumStatus => 'Aquarium status';

  @override
  String get lastTest => 'Latest test';

  @override
  String get noData => 'No data';

  @override
  String get addFirstTest => 'Add your first test';

  @override
  String get parametersCount => '7 parameters';

  @override
  String get waterChange => 'Water change';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get freshWater => 'Water is fresh';

  @override
  String get timeForWaterChange => 'Time for a water change';

  @override
  String get recentParameters => 'Recent parameters';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get enterWaterTest => 'Enter water test results';

  @override
  String get saveTankParameters => 'Save current tank parameters';

  @override
  String get addWaterChange => 'Add a water change';

  @override
  String get saveVolumeAndNote => 'Save volume and note';

  @override
  String get historyOfTank => 'TANK HISTORY';

  @override
  String get journalSubtitle => 'The complete history of aquarium care.';

  @override
  String get recentEntries => 'Recent entries';

  @override
  String get showOlderEntries => 'Show older entries';

  @override
  String get journalEmpty => 'The journal is still empty';

  @override
  String get addFirstWaterEntry => 'Add your first water test or water change.';

  @override
  String get toolsCenter => 'TOOLS CENTER';

  @override
  String get toolsSubtitle => 'Practical tools for every aquarist.';

  @override
  String get account => 'YOUR ACCOUNT';

  @override
  String get profileTitle => 'Profile and PRO';

  @override
  String get profileSubtitle => 'Manage your aquarium and account settings.';

  @override
  String get aquariumName => 'Name';

  @override
  String get tankDetails => '112 liters · Planted';

  @override
  String get notificationsSubtitle => 'Reminders for tests and water changes';

  @override
  String get syncData => 'Data synchronization';

  @override
  String get syncSubtitle => 'Prepared for Firebase or Supabase';

  @override
  String get syncComingSoon =>
      'Synchronization will be connected in a later stage';

  @override
  String get logOut => 'Log out';

  @override
  String get logOutSubtitle => 'End the current session on this device';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get netVolume => 'Net volume';

  @override
  String get grossVolume => 'Gross volume';

  @override
  String get tankType => 'Tank type';

  @override
  String get freshwater => 'Freshwater';

  @override
  String get saltwater => 'Saltwater';

  @override
  String get brackish => 'Brackish';

  @override
  String netVolumeShort(num volume) {
    return '$volume L net';
  }

  @override
  String litersCount(num volume) {
    return '$volume liters';
  }

  @override
  String inhabitantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count inhabitants',
      one: '1 inhabitant',
      zero: '0 inhabitants',
    );
    return '$_temp0';
  }

  @override
  String get save => 'Save';

  @override
  String get volume => 'Volume';

  @override
  String get note => 'Note';

  @override
  String get newActivity => 'New activity';

  @override
  String get title => 'Title';

  @override
  String get activityType => 'Activity type';

  @override
  String get waterReplaced => 'Water replaced';

  @override
  String get liters => 'liters';

  @override
  String get diagnosisSaved => 'Diagnosis saved to the journal';

  @override
  String get saveToJournal => 'Save to Journal';

  @override
  String get tanksAndStock => 'Aquariums and stock';

  @override
  String get tanksAndStockDescription =>
      'Switch tanks and manage fauna and flora.';

  @override
  String get openManagement => 'Open management';

  @override
  String get waterTests => 'Water tests';

  @override
  String get waterTestsDescription =>
      'Record pH, NO3, PO4, Fe, KH, GH and temperature.';

  @override
  String get openTests => 'Open tests';

  @override
  String get knowledgeBase => 'Knowledge base and Atlas';

  @override
  String get knowledgeBaseDescription =>
      'Learn about fish, plants and algae control.';

  @override
  String get openAtlas => 'Open Atlas';

  @override
  String get fertilizerCalculator => 'Fertilizer calculator';

  @override
  String get fertilizerDescription =>
      'Calculate daily and weekly doses for your tank.';

  @override
  String get openCalculator => 'Open calculator';

  @override
  String get calculatorsTitle => 'Aquarium calculators';

  @override
  String get volumeTab => 'Volume';

  @override
  String get co2Tab => 'CO2';

  @override
  String get fertilizersTab => 'Fertilizers';

  @override
  String get volumeCalculator => 'Tank volume';

  @override
  String get volumeCalculatorSubtitle =>
      'Compare gross capacity with the actual water volume.';

  @override
  String get length => 'Length';

  @override
  String get width => 'Width';

  @override
  String get height => 'Height';

  @override
  String get glassThickness => 'Glass thickness';

  @override
  String get substrateThickness => 'Substrate thickness';

  @override
  String get decorationsAndEquipment => 'Decorations and equipment';

  @override
  String get saveNetDefault => 'Save net volume as default';

  @override
  String get co2Calculator => 'CO2 calculator';

  @override
  String get co2CalculatorSubtitle =>
      'Choose pH and KH to check dissolved CO2 concentration.';

  @override
  String get fertilizerCalculatorTitle => 'Fertilizer dosing';

  @override
  String get fertilizerCalculatorSubtitle =>
      'Check how much nutrient each milliliter of solution adds.';

  @override
  String get netCapacity => 'Net capacity';

  @override
  String get solutionCapacity => 'Solution capacity';

  @override
  String get saltAmount => 'Added salt';

  @override
  String get baseSalt => 'Base salt';

  @override
  String get weeklyTarget => 'Weekly target';

  @override
  String freshWaterLastChange(int count) {
    return 'Water is fresh. The last change was $count days ago.';
  }

  @override
  String get scheduleNextChange => 'Time to schedule the next water change.';

  @override
  String get noSavedMeasurements => 'No saved measurements';

  @override
  String get addFirstTestTrack =>
      'Add your first test to track water condition.';

  @override
  String get addFirstMeasurement => 'Add first measurement';

  @override
  String get actualWaterVolume => 'Actual water volume';

  @override
  String get netWater => 'Net water';

  @override
  String get substrate => 'Substrate';

  @override
  String grossVolumeValue(String value) {
    return 'Gross: $value l';
  }

  @override
  String get rocksWood => 'Rocks / wood';

  @override
  String get glass => 'Glass';

  @override
  String estimatedTotalWeight(String value) {
    return 'Estimated total weight: $value kg';
  }

  @override
  String get co2Low => 'Low CO2 - weak plant growth';

  @override
  String get co2Optimal => 'Optimal level - safe for fish';

  @override
  String get co2High => 'High CO2 - risk of oxygen depletion';

  @override
  String get co2Deficit => 'deficit';

  @override
  String get co2Optimum => 'optimal';

  @override
  String get co2Risk => 'risk';

  @override
  String get proActive => 'Aquarist PRO (Active)';

  @override
  String get proName => 'Aquarist PRO';

  @override
  String get allPremiumUnlocked => 'All premium features are unlocked';

  @override
  String get unlockPremium => 'Unlock AI, charts and unlimited aquariums.';

  @override
  String get proPlanUnlimitedAquariums => 'PRO plan: unlimited aquariums';

  @override
  String get knowledgeBaseTitle => 'Knowledge base and Atlas';

  @override
  String get knowledgeBaseDesc => 'Learn about fish, plants and algae control.';

  @override
  String get fertilizerCalcTitle => 'Fertilizer calculator';

  @override
  String get fertilizerCalcDesc =>
      'Calculate daily and weekly doses for your tank.';

  @override
  String get aquaristProActive => 'Aquarist PRO (Active)';

  @override
  String get allFeaturesUnlocked => 'All premium features are unlocked';

  @override
  String get navTools => 'Tools';

  @override
  String get navJournal => 'Journal';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navProfile => 'Profile';

  @override
  String get tabTimeline => 'Timeline';

  @override
  String get tabCalendar => 'Calendar';

  @override
  String get forToday => 'For today';

  @override
  String get selectedDay => 'Selected day';

  @override
  String get aiScannerTitle => 'AI fish and plant scanner';

  @override
  String get aiScannerDesc =>
      'Identify a species from a photo and learn its needs.';

  @override
  String get tryPro => 'Try PRO';

  @override
  String get algaeAssistantTitle => 'Algae assistant';

  @override
  String get algaeAssistantDesc =>
      'Diagnose the problem and get an action plan.';

  @override
  String get startDiagnosis => 'Start diagnosis';

  @override
  String get timeline => 'Timeline';

  @override
  String get calendar => 'Calendar';

  @override
  String get allEntries => 'All';

  @override
  String get noEntriesForFilter => 'No entries for selected filter.';

  @override
  String get searchAtlas => 'Search the Atlas';

  @override
  String get knowledgeForStableTank => 'Knowledge for a stable tank';

  @override
  String get proPaywallTitle => 'Unlock Full Potential with Aquarist PRO';

  @override
  String get proPaywallSubtitle =>
      'Peace of mind in aquarium care with features for demanding tanks.';

  @override
  String get featureUnlimitedCharts => 'Unlimited charts and parameter history';

  @override
  String get featureFertilizerCalc => 'Fertilizer calculator and salt recipes';

  @override
  String get featureReminders => 'SMS and Push notifications';

  @override
  String get featureExportPdf => 'Export reports to PDF';

  @override
  String get trial7Days => 'Try PRO free for 7 days';

  @override
  String get maybeLater => 'Maybe later';

  @override
  String get algaeQuestion => 'What do you see in the aquarium?';

  @override
  String get algaeBba => 'BBA / Black Brush';

  @override
  String get algaeGreen => 'Green algae';

  @override
  String get algaeCyanobacteria => 'Blue-green algae / Cyanobacteria';

  @override
  String get algaeDiatoms => 'Diatoms';

  @override
  String get algaeDust => 'Dust on glass';

  @override
  String get algaeThread => 'Thread algae';

  @override
  String get addAlgaePhotoOptional => 'Add algae photo (optional)';

  @override
  String get recentWaterParams => 'Recent water parameters';

  @override
  String get paramsLoadedInfo =>
      'Values loaded from the latest test. You can correct them before analysis.';

  @override
  String get tankConditions => 'Tank conditions';

  @override
  String get lightHours => 'Light';

  @override
  String get substrateType => 'Substrate';

  @override
  String get gravelSand => 'Gravel / Sand';

  @override
  String get saveMeasurement => 'Save measurement';

  @override
  String get journalTitle => 'Aquarist Journal';

  @override
  String get filterWaterChange => 'Water change';

  @override
  String get filterFilter => 'Filter';

  @override
  String get filterTrimming => 'Trimming';

  @override
  String get filterMeds => 'Medication';

  @override
  String get filterCleaning => 'Cleaning';

  @override
  String get upcomingTasks => 'Upcoming tasks';

  @override
  String get noTasksForDay => 'No tasks for this day.';

  @override
  String get tanksAndStockTitle => 'Aquariums & Stock';

  @override
  String get addTank => 'Add aquarium';

  @override
  String get addNewTank => 'Add new aquarium';

  @override
  String get speciesCount => 'Species';

  @override
  String get itemCount => 'Pcs';

  @override
  String get searchSpeciesOrVar => 'Search species or variety';

  @override
  String get noEntriesInCategory => 'No entries in this category.';

  @override
  String get idealForYourTank => 'Ideal for your tank';

  @override
  String get co2Dosing => 'CO2 Dosing';

  @override
  String get includeCo2InDiagnosis => 'Include CO2 system in diagnosis';

  @override
  String get diagnoseProblem => 'Diagnose problem';

  @override
  String get waterTestTitle => 'Water Test';

  @override
  String get waterParameters => 'Water parameters';

  @override
  String get waterTestInfo =>
      'Measurement will be saved with current date and time.';

  @override
  String get dailyDose => 'Daily dose';

  @override
  String get weeklyDose => 'Weekly dose';

  @override
  String get addFishOrPlantPhoto => 'Add fish or plant photo';

  @override
  String get tapToSelectCameraOrGallery => 'Tap to select Camera or Gallery';

  @override
  String get runRecognition => 'Run recognition';

  @override
  String get smartDiagnosis => 'Smart Diagnosis';

  @override
  String get smartDiagnosisSubtitle =>
      'Enter current parameters to generate an action plan.';

  @override
  String get currentPh => 'Current pH';

  @override
  String get previousPh => 'pH from previous measurement';

  @override
  String get lightingTime => 'Lighting duration';

  @override
  String get runProDiagnosis => 'Run PRO Diagnosis';

  @override
  String get temperature => 'Temperature';

  @override
  String get changeAquariumTooltip => 'Change aquarium';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get taskReminders => 'Task reminders';

  @override
  String get taskRemindersSubtitle =>
      'Water changes, filter maintenance, and care';

  @override
  String get waterTestReminders => 'Water test reminders';

  @override
  String get waterTestRemindersSubtitle => 'Reminders for regular testing';

  @override
  String get weeklySummary => 'Weekly summary';

  @override
  String get weeklySummarySubtitle => 'Key changes and highlights in your tank';

  @override
  String get proNotificationsNote =>
      'PRO notifications are active for this device.';

  @override
  String get atlasSearchPlaceholder => 'e.g., neon, anubias, green algae';

  @override
  String get proNotificationsRequired =>
      'Push notifications and recurring schedules require an active PRO plan.';

  @override
  String get setProfileName => 'Set profile name';

  @override
  String get geminiApiKeyLabel => 'Gemini API Key';

  @override
  String get aiScannerConfig => 'AI Photo Scanner configuration';

  @override
  String get cloudBackupSyncTitle => 'Cloud backup & sync';

  @override
  String get cloudBackupSyncSubtitle => 'Automatic cloud save and backup';

  @override
  String get photoJournalTitle => 'Photo Journal';

  @override
  String get addFirstPhotoOfAquarium => 'Add the first photo of your aquarium.';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get aquariumLivestockTitle => 'Aquarium Livestock';

  @override
  String compatibilityPercent(int score) {
    return '$score% Compatibility';
  }

  @override
  String get livestockWithinRange => 'Livestock is within verified parameters.';

  @override
  String get noSpeciesAddedOpenAtlas =>
      'No species added. Open atlas to add livestock.';

  @override
  String get addSpecies => 'Add species';

  @override
  String get addSpeciesToStock => 'Add species to livestock';

  @override
  String get newReminder => 'New Reminder';

  @override
  String get taskName => 'Task name';

  @override
  String get dueDate => 'Due date';

  @override
  String get repeatCyclically => 'Repeat cyclically';

  @override
  String get autoScheduleNextDate => 'Automatically schedule next date';

  @override
  String get proBenefitUnlimitedAquariums => 'Unlimited aquariums';

  @override
  String get proBenefitAiScannerDiagnostics => 'AI scanner and diagnostics';

  @override
  String get proBenefitFullPhotoHistory => 'Full photo history';

  @override
  String get proBenefitNoAds => 'No ads';

  @override
  String get unlockProHeadline => 'Unlock Aquarist PRO';

  @override
  String get monthlyPlan => 'Monthly';

  @override
  String get yearlyPlan => 'Yearly';

  @override
  String get mostPopularBadge => 'Most popular';

  @override
  String get activatingEllipsis => 'Activating…';

  @override
  String get proActivatedMessage => 'Aquarist PRO status activated.';

  @override
  String proActivationFailed(String error) {
    return 'Failed to activate PRO: $error';
  }

  @override
  String get speciesAtlasTitle => 'Species Atlas';

  @override
  String get searchSpeciesLabel => 'Search species';

  @override
  String get filterAll => 'All';

  @override
  String get filterFish => 'Fish';

  @override
  String get filterPlants => 'Plants';

  @override
  String get filterInvertebrates => 'Invertebrates';

  @override
  String get noSpeciesFound => 'No species found.';

  @override
  String get careNotesLabel => 'Care notes';

  @override
  String minTankVolumeLabel(int value) {
    return 'Minimum tank: $value L';
  }

  @override
  String temperatureRangeLabel(num min, num max) {
    return 'Temperature: $min–$max°C';
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
    return 'Difficulty: $value';
  }

  @override
  String swimmingZoneLabel(String value) {
    return 'Swimming zone: $value';
  }

  @override
  String compatibleWithAquarium(String name) {
    return 'Compatible with aquarium \"$name\"';
  }

  @override
  String warningsForAquarium(String name) {
    return 'Warnings for aquarium \"$name\"';
  }

  @override
  String get addToMyAquarium => 'Add to my aquarium';

  @override
  String get loginToAddSpecies => 'Sign in to add a species to your aquarium.';

  @override
  String get chooseAquarium => 'Choose aquarium';

  @override
  String get noAquariumYet =>
      'You don\'t have an aquarium yet. Create one to add livestock to it';

  @override
  String get createAquariumAction => 'Create aquarium';

  @override
  String get createNewAquariumAction => 'Create new aquarium';

  @override
  String get openManagementToCreateAquarium =>
      'Open aquarium management to create an aquarium.';

  @override
  String addedSpeciesToAquarium(String species, String aquarium) {
    return 'Added $species to aquarium $aquarium';
  }

  @override
  String get viewLivestock => 'View livestock';

  @override
  String get difficultyVeryEasy => 'very easy';

  @override
  String get difficultyEasy => 'easy';

  @override
  String get difficultyMedium => 'medium';

  @override
  String get difficultyHard => 'hard';

  @override
  String get zoneBottom => 'bottom';

  @override
  String get zoneMiddle => 'middle';

  @override
  String get zoneTop => 'top';

  @override
  String get zoneAll => 'whole tank';

  @override
  String addSpeciesDialogTitle(String name) {
    return 'Add $name';
  }

  @override
  String get additionDateLabel => 'Date added';

  @override
  String get notesOptionalLabel => 'Notes (optional)';

  @override
  String get nameDisplayedOnDashboard => 'Name displayed on dashboard';

  @override
  String get apiKeyLabel => 'API Key';

  @override
  String get apiKeyHint => 'Leave empty to use the default key';

  @override
  String get testApiKey => 'Test API Key';

  @override
  String get useDefaultKey => 'Use default key';

  @override
  String get cloudSyncDescription =>
      'Your data is securely synced in the cloud';

  @override
  String get lastSyncLabel => 'Last sync:';

  @override
  String get lastSyncNone => 'no saved data';

  @override
  String get done => 'Done';

  @override
  String get editAction => 'Edit';

  @override
  String get deleteAction => 'Delete';

  @override
  String get referralTitle => 'Referral Program';

  @override
  String get referralHeroTitle => 'Recommend Aquarium PRO and get free access!';

  @override
  String get referralHeroDescription =>
      'Get 1 month of PRO for every 3 invited friends. Your friends get 50% off their first year.';

  @override
  String get referralCodeSection => 'Your code';

  @override
  String get copyCode => 'Copy';

  @override
  String get shareLink => 'Share';

  @override
  String get codeCopied => 'Code copied to clipboard!';

  @override
  String referralProgress(int count) {
    return '$count / 3 successful referrals';
  }

  @override
  String get invitedUsers => 'Invited users';

  @override
  String get noReferrals => 'You have no referrals yet.';

  @override
  String get referralAccepted => 'Registration accepted';

  @override
  String get activePro => 'Active PRO';

  @override
  String get referralCompleted => 'Referral completed';

  @override
  String get awaitingProActivation => 'Waiting for PRO activation';

  @override
  String get referralGoalReached =>
      'Goal reached! Your free month of PRO is ready.';

  @override
  String get referralProgressHint =>
      'Every active referral brings you closer to a free month of PRO.';

  @override
  String get referralLoadErrorTitle => 'Could not load the program';

  @override
  String get connectionRetry => 'Check your connection and try again.';

  @override
  String get retry => 'Try again';

  @override
  String get refreshReferrals => 'Refresh referrals';

  @override
  String referralShareText(String code) {
    return 'Join me in Aquarium PRO and get 50% off your first year! Use my code: $code';
  }

  @override
  String get referralCodeTooShort => 'The code is too short.';

  @override
  String get referralInvalidCode => 'No referral code was found.';

  @override
  String get referralSelfReferral => 'You cannot use your own referral code.';

  @override
  String get referralDeviceUsed =>
      'This code has already been used on this device.';

  @override
  String get referralAlreadyReferred =>
      'This account already has a referral code assigned.';

  @override
  String get referralEmailUnverified =>
      'Verify your email address to complete the referral.';

  @override
  String get referralOperationUnavailable =>
      'This operation is currently unavailable.';

  @override
  String get referralUnauthenticated => 'Your session expired. Sign in again.';

  @override
  String get referralUnavailable =>
      'The referral program is temporarily unavailable. Try again.';

  @override
  String get referralInternal => 'The code could not be prepared. Try again.';

  @override
  String get referralGenericError => 'The referral operation failed.';

  @override
  String get helpCenterTitle => 'Help Center';

  @override
  String get helpHeroTitle => 'We\'re here to help';

  @override
  String get helpHeroDescription =>
      'Describe your issue, and the Aquarium PRO team will get back to you.';

  @override
  String get createTicket => 'Create new ticket';

  @override
  String myTicketsCount(int count) {
    return 'My tickets ($count)';
  }

  @override
  String get quickAnswers => 'Quick answers';

  @override
  String get faqAiTitle =>
      'How do the AI scanner and parameter verification work?';

  @override
  String get faqAiAnswer =>
      'The AI scanner helps identify problems from a photo. Water test results are compared with temperature, pH, and hardness standards for the selected aquarium.';

  @override
  String get faqNo3Title => 'What should I do when nitrate (NO3) is too high?';

  @override
  String get faqNo3Answer =>
      'Perform a partial water change, reduce overfeeding, and check biological filtration. Repeat measurements after the water change instead of lowering NO3 abruptly.';

  @override
  String get faqRemindersTitle =>
      'How do I set reminders for water changes and filter cleaning?';

  @override
  String get faqRemindersAnswer =>
      'Open Journal and reminders, add a task, and set its due date and frequency. Notifications require system permission.';

  @override
  String get faqTransferTitle => 'How do I move my data to a new device?';

  @override
  String get faqTransferAnswer =>
      'Sign in on the new device with the same account. Data saved in the cloud will sync shortly.';

  @override
  String get faqSubscriptionTitle => 'How do I cancel or change my PRO plan?';

  @override
  String get faqSubscriptionAnswer =>
      'Manage your subscription in Google Play or App Store settings, depending on where you purchased it. Changing plans does not delete aquarium data.';

  @override
  String get faqMultipleAquariumsTitle => 'Can I manage multiple aquariums?';

  @override
  String get faqMultipleAquariumsAnswer =>
      'Yes. Switch the active aquarium from aquarium management. The PRO plan does not limit the number of saved aquariums.';

  @override
  String get newTicketTitle => 'New ticket';

  @override
  String get ticketCategory => 'Category';

  @override
  String get ticketBugCategory => '🐛 Report an app bug';

  @override
  String get ticketFeatureCategory => '💡 New feature / idea';

  @override
  String get ticketSubscriptionCategory =>
      '💳 Payment / PRO subscription issue';

  @override
  String get ticketBusinessCategory => '🤝 Partnership / business contact';

  @override
  String get ticketOtherCategory => '❓ Other question';

  @override
  String get ticketSubject => 'Subject';

  @override
  String get ticketSubjectHint => 'Briefly describe the issue';

  @override
  String get ticketDescription => 'Detailed description';

  @override
  String get ticketDescriptionHint =>
      'What happened? How can it be reproduced?';

  @override
  String get ticketDescriptionMin =>
      'The description must contain at least 15 characters.';

  @override
  String get ticketSubjectRequired => 'Enter a ticket subject.';

  @override
  String get ticketAuthRequired => 'Sign in to send a ticket.';

  @override
  String get ticketPermissionError =>
      'You do not have access to tickets. Sign in again.';

  @override
  String get ticketOfflineError =>
      'No internet connection. Check your network and try again.';

  @override
  String get ticketIndexError =>
      'Tickets could not be loaded. A Firestore index is required.';

  @override
  String get ticketGenericError => 'The operation failed. Please try again.';

  @override
  String get attachImage => 'Attach photo / screenshot';

  @override
  String changeAttachment(String name) {
    return 'Change attachment: $name';
  }

  @override
  String get removeAttachment => 'Remove attachment';

  @override
  String get sendingTicket => 'Sending...';

  @override
  String get sendTicket => 'Send ticket';

  @override
  String get ticketSent => 'Ticket sent successfully.';

  @override
  String ticketPhotoReadError(String error) {
    return 'Could not read the photo: $error';
  }

  @override
  String get myTicketsTitle => 'My tickets';

  @override
  String get noTickets => 'No tickets yet';

  @override
  String get ticketDetails => 'Ticket details';

  @override
  String get ticketSupportReply => 'Support reply';

  @override
  String ticketCreatedAt(String date) {
    return 'Created: $date';
  }

  @override
  String get ticketDescriptionSection => 'Ticket description';

  @override
  String get ticketTechnicalInfo => 'Technical information';

  @override
  String get ticketAttachmentError => 'Could not display the attachment.';

  @override
  String get ticketStatusOpen => 'Open';

  @override
  String get ticketStatusInProgress => 'In progress';

  @override
  String get ticketStatusResolved => 'Resolved';

  @override
  String get ticketStatusClosed => 'Closed';
}
