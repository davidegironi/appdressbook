/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:flutter/material.dart';

class AppThemeData {
  // application theme
  final ThemeData theme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppThemeColor.primaryColor,
    hintColor: AppThemeColor.hintColor,
    colorScheme: ColorScheme.light(primary: AppThemeColor.primaryColor, secondary: AppThemeColor.secondaryColor),
    dividerTheme: DividerThemeData(color: AppThemeColor.greyStrongColor),
  );

  ThemeData get themeData {
    return theme;
  }
}

// theme colors
class AppThemeColor {
  static Color get primaryColor => Colors.orange.shade400;
  static Color get secondaryColor => Colors.orange.shade600;
  static Color get loadingSpinner => Colors.orange.shade600;
  static Color get greyLightColor => Colors.grey.shade200;
  static Color get greyStrongColor => Colors.grey.shade600;
  static Color get whiteColor => Colors.white;
  static Color get mainText => Colors.black;
  static Color get reducedText => Colors.grey.shade500;
  static Color get reducedFill => Colors.grey.shade200;
  static Color get hintColor => Colors.grey;
  static Color get errorSnackbar => Colors.red.shade700;
  static Color get infoSnackbar => Colors.lightGreen.shade700;
  static Color get linkUrl => Colors.blue.shade800;
  static Color get offlineForeground => Colors.red.shade700;
  static Color get offlineText => Colors.white;
  static Color get transparentColor => Colors.transparent;
}
