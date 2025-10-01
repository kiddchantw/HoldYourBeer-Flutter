// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get commonAdd => '新增';

  @override
  String get commonRetry => '重試';

  @override
  String get commonLoadFailed => '載入失敗';

  @override
  String get commonCancel => '取消';

  @override
  String get commonConfirm => '確認';

  @override
  String get commonSave => '儲存';

  @override
  String get commonDelete => '刪除';

  @override
  String get commonEdit => '編輯';

  @override
  String get beerMyBeers => '我的啤酒';

  @override
  String get beerNoneYet => '還沒有啤酒';

  @override
  String get beerTapToAdd => '點擊 + 新增你的第一瓶啤酒';

  @override
  String get beerAddBeer => '新增啤酒';

  @override
  String get beerAdded => '成功新增啤酒！';

  @override
  String beerAddFailed(String error) {
    return '新增啤酒失敗：$error';
  }

  @override
  String get beerBrandName => '品牌名稱';

  @override
  String get beerBrandNameHint => '例如：台灣啤酒';

  @override
  String get beerName => '啤酒名稱';

  @override
  String get beerNameHint => '例如：經典拉格';

  @override
  String get beerStyle => '啤酒風格';

  @override
  String get beerStyleHint => '例如：拉格';

  @override
  String get beerValidationBrandRequired => '品牌名稱為必填';

  @override
  String get beerValidationNameRequired => '啤酒名稱為必填';

  @override
  String get beerValidationStyleRequired => '啤酒風格為必填';

  @override
  String get authLogin => '登入';

  @override
  String get authRegister => '註冊';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authConfirmPassword => '確認密碼';

  @override
  String get authName => '姓名';

  @override
  String get authLoginFailed => '登入失敗';

  @override
  String get authRegisterFailed => '註冊失敗';

  @override
  String get authEmailHint => '請輸入您的 Email';

  @override
  String get authPasswordHint => '請輸入您的密碼';

  @override
  String get authNameHint => '請輸入您的姓名';

  @override
  String get authLoginLoading => '登入中...';

  @override
  String get authEmailRequired => '請輸入 Email';

  @override
  String get authEmailInvalid => '請輸入有效的 Email 格式';

  @override
  String get authPasswordRequired => '請輸入密碼';

  @override
  String get authPasswordMinLength => '密碼至少需要 6 個字符';

  @override
  String get authNameRequired => '請輸入姓名';

  @override
  String get authForgotPassword => '忘記密碼？';

  @override
  String get authRememberMe => '記住我';

  @override
  String get authOrSignInWith => '或使用以下方式登入';

  @override
  String get authDontHaveAccount => '還沒有帳戶？';

  @override
  String get authSignUpNow => '立即註冊';

  @override
  String get authAlreadyRegistered => '已經有帳戶了嗎？';

  @override
  String get authAppTitle => 'HoldYourBeer';

  @override
  String get authAppSubtitle => '追蹤啤酒時光';

  @override
  String get authCopyright => '2025 © HoldYourBeer. All rights reserved.';

  @override
  String get authLoginSuccess => '登入成功';

  @override
  String get authRegisterSuccess => '註冊成功';

  @override
  String get authLogout => '登出';

  @override
  String get authLogoutConfirm => '確定要登出嗎？';

  @override
  String get languageSelectTitle => '選擇語言';

  @override
  String get languageTraditionalChinese => '繁體中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get profileTitle => '會員資料';

  @override
  String get profileLanguageSettings => '語言設定';

  @override
  String get profileNotificationSettings => '通知設定';

  @override
  String get profilePrivacySettings => '隱私設定';

  @override
  String get profileAbout => '關於應用';

  @override
  String get profileLogout => '登出';

  @override
  String get profileConfirmLogout => '確認登出';

  @override
  String get profileLogoutMessage => '您確定要登出嗎？';

  @override
  String get chartTitle => '圖表統計';

  @override
  String get chartMonthlyStats => '本月統計';

  @override
  String get chartTotal => '總數量';

  @override
  String get chartThisMonth => '本月';

  @override
  String get chartBrands => '品牌數';

  @override
  String get chartFavoriteBrands => '最愛品牌';

  @override
  String chartTimes(int count) {
    return '$count 次';
  }

  @override
  String get navHome => '首頁';

  @override
  String get navAdd => '新增';

  @override
  String get navProfile => '會員';
}
