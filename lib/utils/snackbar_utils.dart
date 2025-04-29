/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:appdressbook/main/app_themedata.dart';
import 'package:flutter/material.dart';

class SnackBarUtils {
  // show a error bar
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
  errorSnackbar(BuildContext context, String message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: AppThemeColor.errorSnackbar,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // show a info bar
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> infoSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: AppThemeColor.infoSnackbar,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
