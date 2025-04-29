/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:appdressbook/main/app_localization.dart';
import 'package:appdressbook/config/config_repository.dart';
import 'package:appdressbook/main/app_themedata.dart';
import 'package:appdressbook/main/body_scaffold.dart';
import 'package:appdressbook/main/main_widget.dart';
import 'package:appdressbook/utils/loading_spinner.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  static const String routeName = '/privacypolicy';

  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final ConfigRepository configRepository = GetIt.instance.get<ConfigRepository>();

  String? text;

  @override
  void initState() {
    super.initState();

    // load text
    setState(() {
      text = configRepository.config.config?.privacy;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainWidget(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppThemeColor.primaryColor,
          title: Text(AppI18N.instance.translate("privacypolicy.appbartitle")),
        ),
        body: BodyScaffold(
          isPadded: true,
          child:
              text == null
                  ? Align(alignment: Alignment.center, child: LoadingSpinner())
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [Text(text!, textAlign: TextAlign.left, style: TextStyle(fontSize: 16))],
                  ),
        ),
      ),
    );
  }
}
