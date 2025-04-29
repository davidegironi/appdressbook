/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:appdressbook/main/app_themedata.dart';
import 'package:appdressbook/main/body_scaffold.dart';
import 'package:appdressbook/main/main_widget.dart';
import 'package:appdressbook/utils/loading_spinner.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  static const String routeName = '/splash';

  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainWidget(
      child: Scaffold(
        backgroundColor: AppThemeColor.primaryColor,
        body: const BodyScaffold(isPadded: false, child: Center(child: LoadingSpinner())),
      ),
    );
  }
}
