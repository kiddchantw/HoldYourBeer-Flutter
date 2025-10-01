import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/i18n/locale_provider.dart';
import '../themes/beer_colors.dart';

class DebugLanguageSelector extends ConsumerWidget {
  const DebugLanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return FloatingActionButton.small(
      heroTag: "language_selector", // 避免 hero 標籤衝突
      onPressed: () {
        print('🔥🔥🔥 Debug 語系按鈕被點擊了！🔥🔥🔥');

        // 簡單的語系切換：在繁體中文和英文之間切換
        final newLocale = currentLocale.languageCode == 'zh'
            ? const Locale('en', 'US')
            : const Locale('zh', 'TW');

        print('切換語系: ${currentLocale.languageCode} -> ${newLocale.languageCode}');
        ref.read(localeProvider.notifier).setLocale(newLocale);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🎉 語系已切換為: ${newLocale.languageCode == 'zh' ? '繁體中文' : 'English'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      backgroundColor: Colors.red.withOpacity(0.9), // 使用紅色讓它非常明顯
      child: Text(
        currentLocale.languageCode == 'zh' ? '中' : 'EN',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}