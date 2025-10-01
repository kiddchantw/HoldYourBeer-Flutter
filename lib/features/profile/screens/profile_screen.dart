import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/themes/beer_colors.dart';
import '../../../shared/widgets/language_dialog.dart';
import '../../../core/auth/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('會員資料'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // 用戶資訊卡片
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10.r,
                    offset: Offset(0, 5.h),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40.r,
                    backgroundColor: BeerColors.primaryAmber500,
                    child: Icon(
                      Icons.person,
                      size: 40.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    _getUserName(authState),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: BeerColors.textDark,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _getUserEmail(authState),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: BeerColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // 設定選項
            _buildSettingItem(
              icon: Icons.language,
              title: '語言設定',
              onTap: () => showLanguageDialog(context),
            ),

            _buildSettingItem(
              icon: Icons.notifications,
              title: '通知設定',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('通知設定功能開發中...')),
                );
              },
            ),

            _buildSettingItem(
              icon: Icons.security,
              title: '隱私設定',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('隱私設定功能開發中...')),
                );
              },
            ),

            _buildSettingItem(
              icon: Icons.info,
              title: '關於應用',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'HoldYourBeer',
                  applicationVersion: '1.0.0',
                  children: [
                    const Text('啤酒追蹤應用程式'),
                  ],
                );
              },
            ),

            SizedBox(height: 40.h),

            // 登出按鈕
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 20.h),
              child: ElevatedButton(
                onPressed: () {
                  _showLogoutDialog(context, ref);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: BeerColors.error700,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                child: Text(
                  '登出',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getUserName(AuthState authState) {
    if (authState is Authenticated) {
      return authState.user.name;
    }
    return '訪客用戶';
  }

  String _getUserEmail(AuthState authState) {
    if (authState is Authenticated) {
      return authState.user.email;
    }
    return 'guest@example.com';
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        leading: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: BeerColors.primaryAmber500.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            color: BeerColors.primaryAmber500,
            size: 20.sp,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            color: BeerColors.textDark,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: BeerColors.gray400,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        tileColor: Colors.white,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認登出'),
        content: const Text('您確定要登出嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authStateProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BeerColors.error700,
            ),
            child: const Text('登出'),
          ),
        ],
      ),
    );
  }
}