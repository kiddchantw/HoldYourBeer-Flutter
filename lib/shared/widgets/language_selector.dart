import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/i18n/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import '../themes/beer_colors.dart';

class LanguageSelector extends ConsumerWidget {
  final bool showText;
  final double? iconSize;

  const LanguageSelector({
    super.key,
    this.showText = false,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final localizations = AppLocalizations.of(context)!;

    return PopupMenuButton<Locale>(
      icon: Container(
        padding: EdgeInsets.all(showText ? 8.w : 6.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language,
              size: iconSize ?? 20.sp,
              color: BeerColors.primaryAmber600,
            ),
            if (showText) ...[
              SizedBox(width: 6.w),
              Text(
                _getLanguageDisplayName(currentLocale, localizations),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: BeerColors.primaryAmber600,
                ),
              ),
            ],
          ],
        ),
      ),
      offset: Offset(0, 40.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      elevation: 8,
      color: Colors.white,
      itemBuilder: (context) => [
        PopupMenuItem<Locale>(
          value: const Locale('zh', 'TW'),
          child: _buildLanguageItem(
            locale: const Locale('zh', 'TW'),
            displayName: localizations.languageTraditionalChinese,
            flag: '🇹🇼',
            isSelected: currentLocale.languageCode == 'zh',
          ),
        ),
        PopupMenuItem<Locale>(
          value: const Locale('en', 'US'),
          child: _buildLanguageItem(
            locale: const Locale('en', 'US'),
            displayName: localizations.languageEnglish,
            flag: '🇺🇸',
            isSelected: currentLocale.languageCode == 'en',
          ),
        ),
      ],
      onSelected: (locale) {
        ref.read(localeProvider.notifier).setLocale(locale);

        // 顯示語系切換成功提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${localizations.languageSelectTitle}: ${_getLanguageDisplayName(locale, localizations)}',
            ),
            backgroundColor: BeerColors.primaryAmber500,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageItem({
    required Locale locale,
    required String displayName,
    required String flag,
    required bool isSelected,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: isSelected ? BeerColors.primaryAmber50 : Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),
        border: isSelected
            ? Border.all(color: BeerColors.primaryAmber200, width: 1.w)
            : null,
      ),
      child: Row(
        children: [
          Text(
            flag,
            style: TextStyle(fontSize: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              displayName,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? BeerColors.primaryAmber600
                    : BeerColors.textDark,
              ),
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check,
              size: 16.sp,
              color: BeerColors.primaryAmber600,
            ),
        ],
      ),
    );
  }

  String _getLanguageDisplayName(Locale locale, AppLocalizations localizations) {
    switch (locale.languageCode) {
      case 'zh':
        return localizations.languageTraditionalChinese;
      case 'en':
        return localizations.languageEnglish;
      default:
        return localizations.languageEnglish;
    }
  }
}