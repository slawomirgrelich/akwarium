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
    return '$count days';
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
  String get aquariumName => 'Planted Aquarium';

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
  String get save => 'Save';

  @override
  String get volume => 'Volume';

  @override
  String get note => 'Note';

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
  String grossVolume(String value) {
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
}
