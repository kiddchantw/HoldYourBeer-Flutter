import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/themes/beer_colors.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/circular_language_selector.dart';
import '../../../shared/widgets/background/background.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 監聽認證狀態變化
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red,
          ),
        );
        // 清除錯誤狀態
        ref.read(authStateProvider.notifier).clearError();
      }
    });

    final authState = ref.watch(authStateProvider);

    return Scaffold(
      body: LoginBackground(
        enableBubbleAnimation: true,
        bubbleAnimationDuration: 4.0,
        child: SafeArea(
          child: Stack(
            children: [
              // 主要登入內容
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),

                      // Logo 區域
                      _buildLogoSection(),

                      SizedBox(height: 20.h), // 從 30.h 減少到 20.h (減少 10px)

                      // 登入表單
                      _buildLoginForm(),

                      const Spacer(),

                      // 底部裝飾文字
                      _buildFooterText(),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),

              // 語系切換按鈕 - 與下方email區塊左邊對齊
              Positioned(
                top: 8.h,
                left: 48.w, // 24.w (主要padding) + 24.w (表單padding) = 48.w
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12.r,
                        offset: Offset(0, 6.h),
                      ),
                    ],
                  ),
                  child: const CircularLanguageSelector(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildLogoSection() {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        // 啤酒圖示
        Container(
          width: 100.w,
          height: 100.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.9),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20.r,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: Icon(
            Icons.sports_bar,
            size: 50.sp,
            color: BeerColors.primaryAmber600,
          ),
        ),
        SizedBox(height: 20.h),

        // App 名稱
        Text(
          localizations.authAppTitle,
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: BeerColors.primaryAmber600,
            shadows: [
              Shadow(
                offset: Offset(0, 2.h),
                blurRadius: 4.r,
                color: Colors.black.withOpacity(0.1),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),

        // 副標題
        Text(
          localizations.authAppSubtitle,
          style: TextStyle(
            fontSize: 16.sp,
            color: BeerColors.primaryAmber600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // Email 輸入框
            _buildEmailField(),
            SizedBox(height: 16.h),

            // Password 輸入框
            _buildPasswordField(),
            SizedBox(height: 24.h),

            // 登入按鈕
            _buildLoginButton(),
            SizedBox(height: 16.h),

            // 忘記密碼連結
            _buildForgotPasswordLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.authEmail,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: BeerColors.textDark,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: localizations.authEmailHint,
            prefixIcon: Icon(
              Icons.email_outlined,
              color: BeerColors.primaryAmber500,
              size: 20.sp,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: BeerColors.gray400),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: BeerColors.gray400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: BeerColors.primaryAmber500, width: 2.w),
            ),
            fillColor: Colors.white,
            filled: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return localizations.authEmailRequired;
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return localizations.authEmailInvalid;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.authPassword,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: BeerColors.textDark,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: localizations.authPasswordHint,
            prefixIcon: Icon(
              Icons.lock_outline,
              color: BeerColors.primaryAmber500,
              size: 20.sp,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: BeerColors.gray500,
                size: 20.sp,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: BeerColors.gray400),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: BeerColors.gray400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: BeerColors.primaryAmber500, width: 2.w),
            ),
            fillColor: Colors.white,
            filled: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return localizations.authPasswordRequired;
            }
            if (value.length < 6) {
              return localizations.authPasswordMinLength;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState is Loading;
    final localizations = AppLocalizations.of(context)!;

    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: BeerColors.primaryAmber500,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: BeerColors.primaryAmber500.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                localizations.authLogin,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: TextButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${localizations.authForgotPassword} 功能開發中...')),
          );
        },
        child: Text(
          localizations.authForgotPassword,
          style: TextStyle(
            fontSize: 14.sp,
            color: BeerColors.primaryAmber600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterText() {
    final localizations = AppLocalizations.of(context)!;

    return Text(
      localizations.authCopyright,
      style: TextStyle(
        fontSize: 12.sp,
        color: BeerColors.primaryAmber600.withOpacity(0.7),
      ),
      textAlign: TextAlign.center,
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // 使用 AuthProvider 進行登入
      ref.read(authStateProvider.notifier).login(email, password);
    }
  }
}