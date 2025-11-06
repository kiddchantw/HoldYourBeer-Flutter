import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Google 登入按鈕元件
///
/// 提供一致的 Google 登入 UI 介面
class GoogleSignInButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? text;

  const GoogleSignInButton({
    Key? key,
    this.onPressed,
    this.isLoading = false,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
        child: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google Logo
                  _buildGoogleLogo(),
                  SizedBox(width: 12.w),

                  // 按鈕文字
                  Flexible(
                    child: Text(
                      text ?? '使用 Google 帳號登入',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// 建立 Google Logo
  ///
  /// 優先使用 assets/images/google_logo.png
  /// 如果沒有圖片，則使用 G 文字作為替代
  Widget _buildGoogleLogo() {
    return Container(
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2.r),
      ),
      child: Center(
        child: Image.asset(
          'assets/images/google_logo.png',
          width: 20.w,
          height: 20.w,
          errorBuilder: (context, error, stackTrace) {
            // 如果圖片載入失敗，顯示替代圖示
            return Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4285F4), // Google Blue
                    Color(0xFFEA4335), // Google Red
                  ],
                ),
                borderRadius: BorderRadius.circular(2.r),
              ),
              child: Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
