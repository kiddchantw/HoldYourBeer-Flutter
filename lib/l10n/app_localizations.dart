import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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
    Locale('zh')
  ];

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get commonLoadFailed;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @beerMyBeers.
  ///
  /// In en, this message translates to:
  /// **'My Beers'**
  String get beerMyBeers;

  /// No description provided for @beerNoneYet.
  ///
  /// In en, this message translates to:
  /// **'No beers yet'**
  String get beerNoneYet;

  /// No description provided for @beerTapToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first beer'**
  String get beerTapToAdd;

  /// No description provided for @beerAddBeer.
  ///
  /// In en, this message translates to:
  /// **'Add Beer'**
  String get beerAddBeer;

  /// No description provided for @beerAdded.
  ///
  /// In en, this message translates to:
  /// **'Beer added successfully!'**
  String get beerAdded;

  /// No description provided for @beerAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add beer: {error}'**
  String beerAddFailed(String error);

  /// No description provided for @beerBrandName.
  ///
  /// In en, this message translates to:
  /// **'Brand Name'**
  String get beerBrandName;

  /// No description provided for @beerBrandNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Taiwan Beer'**
  String get beerBrandNameHint;

  /// No description provided for @beerName.
  ///
  /// In en, this message translates to:
  /// **'Beer Name'**
  String get beerName;

  /// No description provided for @beerNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Classic Lager'**
  String get beerNameHint;

  /// No description provided for @beerStyle.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get beerStyle;

  /// No description provided for @beerStyleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Lager'**
  String get beerStyleHint;

  /// No description provided for @beerValidationBrandRequired.
  ///
  /// In en, this message translates to:
  /// **'Brand name is required'**
  String get beerValidationBrandRequired;

  /// No description provided for @beerValidationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Beer name is required'**
  String get beerValidationNameRequired;

  /// No description provided for @beerValidationStyleRequired.
  ///
  /// In en, this message translates to:
  /// **'Style is required'**
  String get beerValidationStyleRequired;

  /// No description provided for @authLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLogin;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegister;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authConfirmPassword;

  /// No description provided for @authName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get authName;

  /// No description provided for @authLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get authLoginFailed;

  /// No description provided for @authRegisterFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get authRegisterFailed;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileLanguageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get profileLanguageSettings;

  /// No description provided for @profileNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get profileNotificationSettings;

  /// No description provided for @profilePrivacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy Settings'**
  String get profilePrivacySettings;

  /// No description provided for @profileAbout.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get profileAbout;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogout;

  /// No description provided for @profileConfirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get profileConfirmLogout;

  /// No description provided for @profileLogoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get profileLogoutMessage;

  /// No description provided for @chartTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get chartTitle;

  /// No description provided for @chartMonthlyStats.
  ///
  /// In en, this message translates to:
  /// **'Monthly Statistics'**
  String get chartMonthlyStats;

  /// No description provided for @chartTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get chartTotal;

  /// No description provided for @chartThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get chartThisMonth;

  /// No description provided for @chartBrands.
  ///
  /// In en, this message translates to:
  /// **'Brands'**
  String get chartBrands;

  /// No description provided for @chartFavoriteBrands.
  ///
  /// In en, this message translates to:
  /// **'Favorite Brands'**
  String get chartFavoriteBrands;

  /// No description provided for @chartTimes.
  ///
  /// In en, this message translates to:
  /// **'{count} times'**
  String chartTimes(int count);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get navAdd;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
