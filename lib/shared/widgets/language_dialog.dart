import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/locale_provider.dart';

void showLanguageDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Consumer(
      builder: (context, ref, _) {
        final currentLocale = ref.watch(localeProvider);

        return AlertDialog(
          title: const Text('選擇語言'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<Locale>(
                title: const Text('繁體中文'),
                value: const Locale('zh', 'TW'),
                groupValue: currentLocale,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(localeProvider.notifier).setLocale(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<Locale>(
                title: const Text('English'),
                value: const Locale('en', 'US'),
                groupValue: currentLocale,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(localeProvider.notifier).setLocale(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    ),
  );
}