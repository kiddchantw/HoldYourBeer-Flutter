import 'package:flutter/material.dart';

/// HoldYourBeer App Colors - 與 Laravel 版本保持一致的色彩主題
class BeerColors {
  BeerColors._();

  // 主色調 - 暖橘色系 (與 Laravel Tailwind 配置一致)
  static const Color primaryAmber50 = Color(0xFFFEF7ED);
  static const Color primaryAmber100 = Color(0xFFFEECDD);
  static const Color primaryAmber200 = Color(0xFFFDD5AA);
  static const Color primaryAmber300 = Color(0xFFFDBB77);
  static const Color primaryAmber400 = Color(0xFFFB9F44);
  static const Color primaryAmber500 = Color(0xFFF59E0B); // 主要按鈕色
  static const Color primaryAmber600 = Color(0xFFD97706); // 按鈕 hover 色

  // 橘色系
  static const Color orange50 = Color(0xFFFFF7ED);
  static const Color orange100 = Color(0xFFFFEDD5);
  static const Color orange200 = Color(0xFFFED7AA);
  static const Color orange300 = Color(0xFFFDBA74);
  static const Color orange400 = Color(0xFFFB923C);
  static const Color orange500 = Color(0xFFF97316);
  static const Color orange600 = Color(0xFFEA580C);

  // 黃色系 - 泡泡效果用
  static const Color yellow50 = Color(0xFFFEFCE8);
  static const Color yellow100 = Color(0xFFFEF9C3);
  static const Color yellow200 = Color(0xFFFEF08A);
  static const Color yellow300 = Color(0xFFFDE047);
  static const Color yellow400 = Color(0xFFFACC15);

  // 功能性色彩
  static const Color success50 = Color(0xFFF0FDF4);
  static const Color success100 = Color(0xFFDCFCE7);
  static const Color success200 = Color(0xFFBBF7D0);
  static const Color success700 = Color(0xFF15803D); // 加號按鈕

  static const Color error50 = Color(0xFFFEF2F2);
  static const Color error100 = Color(0xFFFEE2E2);
  static const Color error200 = Color(0xFFFECACA);
  static const Color error700 = Color(0xFFB91C1C); // 減號按鈕

  static const Color info50 = Color(0xFFEFF6FF);
  static const Color info100 = Color(0xFFDBEAFE);
  static const Color info800 = Color(0xFF1E40AF); // 計數顯示

  // 中性色
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray900 = Color(0xFF111827);

  // 特殊背景色 (對應 Laravel 的漸層)
  static const Color backgroundLight = Color(0xFFFFFBF5); // from-orange-50
  static const Color backgroundMid = Color(0xFFFEF3C7);   // via-amber-100
  static const Color backgroundDark = Color(0xFFFED7AA);  // to-orange-200

  // 半透明色 (用於泡泡效果)
  static const Color bubbleAmber = Color(0x66FDE047);   // amber-300/40
  static const Color bubbleOrange = Color(0x73FB923C);  // orange-300/45
  static const Color bubbleYellow = Color(0x66FDE047); // yellow-300/40

  // 磨砂玻璃效果
  static const Color glassWhite = Color(0x99FFFFFF);    // white/60
  static const Color glassBlur = Color(0x33FFFFFF);     // backdrop-blur

  // 文字色彩
  static const Color textDark = Color(0xFF1F2937);      // gray-800
  static const Color textMuted = Color(0xFF6B7280);     // gray-500
  static const Color textLight = Color(0xFF9CA3AF);     // gray-400

  /// 主要漸層 - Primary Gradient (按鈕用)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryAmber500, primaryAmber600],
  );

  /// 按鈕 Hover 漸層
  static const LinearGradient primaryHoverGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryAmber600, Color(0xFFB45309)], // amber-700
  );

  /// 背景漸層 - Background Gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundLight, backgroundMid, backgroundDark],
  );

  /// 二級背景漸層 (疊加用)
  static const LinearGradient backgroundOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x33FED7AA), // orange-100/20
      Color(0x4DFEF3C7), // amber-200/30
      Color(0x66FB923C), // orange-300/40
    ],
  );
}