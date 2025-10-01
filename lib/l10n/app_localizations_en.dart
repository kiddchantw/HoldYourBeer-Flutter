// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonAdd => 'Add';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonLoadFailed => 'Failed to load';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get beerMyBeers => 'My Beers';

  @override
  String get beerNoneYet => 'No beers yet';

  @override
  String get beerTapToAdd => 'Tap + to add your first beer';

  @override
  String get beerAddBeer => 'Add Beer';

  @override
  String get beerAdded => 'Beer added successfully!';

  @override
  String beerAddFailed(String error) {
    return 'Failed to add beer: $error';
  }

  @override
  String get beerBrandName => 'Brand Name';

  @override
  String get beerBrandNameHint => 'e.g. Taiwan Beer';

  @override
  String get beerName => 'Beer Name';

  @override
  String get beerNameHint => 'e.g. Classic Lager';

  @override
  String get beerStyle => 'Style';

  @override
  String get beerStyleHint => 'e.g. Lager';

  @override
  String get beerValidationBrandRequired => 'Brand name is required';

  @override
  String get beerValidationNameRequired => 'Beer name is required';

  @override
  String get beerValidationStyleRequired => 'Style is required';

  @override
  String get authLogin => 'Log in';

  @override
  String get authRegister => 'Register';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authConfirmPassword => 'Confirm Password';

  @override
  String get authName => 'Name';

  @override
  String get authLoginFailed => 'Login failed';

  @override
  String get authRegisterFailed => 'Registration failed';

  @override
  String get authEmailHint => 'Please enter your email';

  @override
  String get authPasswordHint => 'Please enter your password';

  @override
  String get authNameHint => 'Please enter your name';

  @override
  String get authLoginLoading => 'Logging in...';

  @override
  String get authEmailRequired => 'Please enter email';

  @override
  String get authEmailInvalid => 'Please enter a valid email format';

  @override
  String get authPasswordRequired => 'Please enter password';

  @override
  String get authPasswordMinLength => 'Password must be at least 6 characters';

  @override
  String get authNameRequired => 'Please enter name';

  @override
  String get authForgotPassword => 'Forgot your password?';

  @override
  String get authRememberMe => 'Remember me';

  @override
  String get authOrSignInWith => 'Or sign in with';

  @override
  String get authDontHaveAccount => 'Don\'t have an account?';

  @override
  String get authSignUpNow => 'Sign up now';

  @override
  String get authAlreadyRegistered => 'Already registered?';

  @override
  String get authAppTitle => 'HoldYourBeer';

  @override
  String get authAppSubtitle => 'Track your beer moments';

  @override
  String get authCopyright => '2025 © HoldYourBeer. All rights reserved.';

  @override
  String get authLoginSuccess => 'Login successful';

  @override
  String get authRegisterSuccess => 'Registration successful';

  @override
  String get authLogout => 'Log out';

  @override
  String get authLogoutConfirm => 'Are you sure you want to log out?';

  @override
  String get languageSelectTitle => 'Select Language';

  @override
  String get languageTraditionalChinese => '繁體中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileLanguageSettings => 'Language Settings';

  @override
  String get profileNotificationSettings => 'Notification Settings';

  @override
  String get profilePrivacySettings => 'Privacy Settings';

  @override
  String get profileAbout => 'About App';

  @override
  String get profileLogout => 'Logout';

  @override
  String get profileConfirmLogout => 'Confirm Logout';

  @override
  String get profileLogoutMessage => 'Are you sure you want to logout?';

  @override
  String get chartTitle => 'Statistics';

  @override
  String get chartMonthlyStats => 'Monthly Statistics';

  @override
  String get chartTotal => 'Total';

  @override
  String get chartThisMonth => 'This Month';

  @override
  String get chartBrands => 'Brands';

  @override
  String get chartFavoriteBrands => 'Favorite Brands';

  @override
  String chartTimes(int count) {
    return '$count times';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navAdd => 'Add';

  @override
  String get navProfile => 'Profile';
}
