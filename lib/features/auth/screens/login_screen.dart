import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/themes/beer_colors.dart';
import '../../../core/auth/auth_provider.dart';

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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // 啤酒主題漸層背景
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              BeerColors.primaryAmber200,
              BeerColors.primaryAmber100,
              Color(0xFFFFF8E1), // 淺啤酒色
            ],
          ),
        ),
        child: Stack(
          children: [
            // 背景裝飾元素
            _buildBackgroundDecorations(),

            // 主要內容
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),

                      // Logo 區域
                      _buildLogoSection(),

                      SizedBox(height: 30.h),

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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        // 右上角大泡泡群
        Positioned(
          top: 30.h,
          right: -40.w,
          child: Container(
            width: 150.w,
            height: 150.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.05),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 70.h,
          right: 20.w,
          child: Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  BeerColors.yellow300.withOpacity(0.4),
                  BeerColors.yellow300.withOpacity(0.08),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 120.h,
          right: 60.w,
          child: Container(
            width: 45.w,
            height: 45.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.25),
            ),
          ),
        ),

        // 中間區域的泡泡
        Positioned(
          top: 200.h,
          left: 20.w,
          child: Container(
            width: 35.w,
            height: 35.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  BeerColors.primaryAmber200.withOpacity(0.5),
                  BeerColors.primaryAmber200.withOpacity(0.1),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 300.h,
          right: 15.w,
          child: Container(
            width: 25.w,
            height: 25.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ),

        // 左下角大泡泡群
        Positioned(
          bottom: 80.h,
          left: -50.w,
          child: Container(
            width: 140.w,
            height: 140.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  BeerColors.orange300.withOpacity(0.3),
                  BeerColors.orange300.withOpacity(0.05),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 120.h,
          left: 30.w,
          child: Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.35),
                  Colors.white.withOpacity(0.08),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 180.h,
          left: 70.w,
          child: Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: BeerColors.yellow200.withOpacity(0.4),
            ),
          ),
        ),

        // 額外的小泡泡增加層次感
        Positioned(
          top: 250.h,
          left: 80.w,
          child: Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.35),
            ),
          ),
        ),
        Positioned(
          bottom: 250.h,
          right: 40.w,
          child: Container(
            width: 35.w,
            height: 35.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  BeerColors.primaryAmber300.withOpacity(0.4),
                  BeerColors.primaryAmber300.withOpacity(0.1),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 320.h,
          left: 15.w,
          child: Container(
            width: 25.w,
            height: 25.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoSection() {
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
          'HoldYourBeer',
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
          '追蹤啤酒時光',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
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
            hintText: '請輸入您的 Email',
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
              return '請輸入 Email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return '請輸入有效的 Email 格式';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
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
            hintText: '請輸入您的密碼',
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
              return '請輸入密碼';
            }
            if (value.length < 6) {
              return '密碼至少需要 6 個字符';
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
                '登入',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Center(
      child: TextButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('忘記密碼功能開發中...')),
          );
        },
        child: Text(
          '忘記密碼？',
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
    return Text(
      '2025 © HoldYourBeer. All rights reserved.',
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