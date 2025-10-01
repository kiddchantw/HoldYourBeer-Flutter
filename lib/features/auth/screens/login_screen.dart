import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/themes/beer_colors.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: BeerColors.backgroundLight,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo or Icon
              Icon(
                Icons.local_bar,
                size: 80.sp,
                color: BeerColors.primaryAmber500,
              ),
              SizedBox(height: 24.h),
              Text(
                'HoldYourBeer',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: BeerColors.textDark,
                ),
              ),
              SizedBox(height: 48.h),
              // Login Button (simplified)
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    // 簡化登入邏輯 - 直接導航到主頁面
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('登入功能開發中...')),
                    );
                  },
                  child: Text(
                    '登入',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}