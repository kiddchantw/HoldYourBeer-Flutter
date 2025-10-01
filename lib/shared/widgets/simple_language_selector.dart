import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/i18n/locale_provider.dart';
import '../../core/constants/app_constants.dart';
import '../themes/beer_colors.dart';

class SimpleLanguageSelector extends ConsumerWidget {
  const SimpleLanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print('🔥 語系按鈕被點擊了！');

          // 簡單的語系切換：在繁體中文和英文之間切換
          final newLocale = currentLocale.languageCode == 'zh'
              ? const Locale('en', 'US')
              : const Locale('zh', 'TW');

          print('切換語系: ${currentLocale.languageCode} -> ${newLocale.languageCode}');
          ref.read(localeProvider.notifier).setLocale(newLocale);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('語系已切換為: ${newLocale.languageCode == 'zh' ? '繁體中文' : 'English'}'),
              duration: const Duration(seconds: 2),
              backgroundColor: BeerColors.primaryAmber500,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          // 增加更大的觸摸區域
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: BeerColors.primaryAmber200,
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language,
                size: 22.sp,
                color: BeerColors.primaryAmber600,
              ),
              SizedBox(width: 6.w),
              Text(
                currentLocale.languageCode == 'zh' ? '中' : 'EN',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: BeerColors.primaryAmber600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}