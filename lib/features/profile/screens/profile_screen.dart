import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/themes/beer_colors.dart';
import '../../../shared/widgets/background/background.dart';
import '../../../shared/widgets/language_dialog.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/i18n/locale_provider.dart';
import '../../../l10n/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;
    final languageLabel = currentLocale.languageCode == 'zh'
        ? l10n.languageTraditionalChinese
        : l10n.languageEnglish;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.profileTitle,
          style: TextStyle(
            color: BeerColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: BeerColors.primaryAmber600,
            ),
            onPressed: () => _showLogoutDialog(context, ref),
            tooltip: l10n.profileLogout,
          ),
        ],
      ),
      body: BeerGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
          children: [
            // 用戶資訊卡片
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15.r,
                    offset: Offset(0, 8.h),
                  ),
                  BoxShadow(
                    color: BeerColors.primaryAmber300.withOpacity(0.1),
                    blurRadius: 20.r,
                    offset: Offset(0, 4.h),
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
              title: l10n.profileLanguageSettings,
              onTap: () => showLanguageDialog(context),
              trailingLabel: languageLabel,
            ),

            // 通知設定已移除

            _buildSettingItem(
              icon: Icons.security,
              title: l10n.profilePrivacySettings,
              onTap: () {
                context.push('/privacy');
              },
            ),

            _buildSettingItem(
              icon: Icons.info,
              title: l10n.profileAbout,
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

            SizedBox(height: 20.h),
            ],
          ),
        ),
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
    String? trailingLabel,
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingLabel != null)
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Text(
                  trailingLabel,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: BeerColors.textMuted,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: BeerColors.gray400,
            ),
          ],
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        tileColor: Colors.white.withOpacity(0.9),
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