/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:appdressbook/main/app_themedata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingSpinner extends StatefulWidget {
  const LoadingSpinner({super.key});

  @override
  State<LoadingSpinner> createState() => _LoadingSpinnerState();
}

class _LoadingSpinnerState extends State<LoadingSpinner> {
  bool displaySpinner = false;

  @override
  void initState() {
    super.initState();

    // wait a little amount of time before showing the loading spinner
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => displaySpinner = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return displaySpinner
        ? SpinKitPulse(color: AppThemeColor.loadingSpinner, size: 50.0)
        : const Padding(padding: EdgeInsets.zero);
  }
}
