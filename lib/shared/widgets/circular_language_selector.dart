import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/i18n/locale_provider.dart';
import '../themes/beer_colors.dart';

class CircularLanguageSelector extends ConsumerWidget {
  const CircularLanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return GestureDetector(
      onTap: () {
        // 簡單的語系切換：在繁體中文和英文之間切換
        final newLocale = currentLocale.languageCode == 'zh'
            ? const Locale('en', 'US')
            : const Locale('zh', 'TW');

        ref.read(localeProvider.notifier).setLocale(newLocale);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '語系已切換為: ${newLocale.languageCode == 'zh' ? '繁體中文' : 'English'}',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: BeerColors.primaryAmber500,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Center(
          child: Text(
            currentLocale.languageCode == 'zh' ? '中' : 'EN',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: BeerColors.primaryAmber600,
            ),
          ),
        ),
      ),
    );
  }
}