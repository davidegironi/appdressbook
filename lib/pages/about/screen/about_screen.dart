/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:appdressbook/auth/repositories/auth_repository.dart';
import 'package:appdressbook/config/config_repository.dart';
import 'package:appdressbook/main/app_localization.dart';
import 'package:appdressbook/main/app_themedata.dart';
import 'package:appdressbook/main/body_scaffold.dart';
import 'package:appdressbook/main/main_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  // route name
  static const String routeName = '/about';

  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final AuthRepository authRepository = GetIt.instance.get<AuthRepository>();
  final ConfigRepository configRepository = GetIt.instance.get<ConfigRepository>();

  String? version;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      // get package info
      PackageInfo.fromPlatform().then((packageInfo) => setState(() => version = packageInfo.version));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainWidget(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppThemeColor.primaryColor,
          title: Text(AppI18N.instance.translate("about.appbartitle")),
        ),
        body: BodyScaffold(
          isPadded: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 200.0, child: Image.asset("assets/img/logo.png", fit: BoxFit.contain)),
              Padding(padding: const EdgeInsets.all(12.0)),
              Text(
                AppI18N.instance.translate("about.title"),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 36),
              ),
              Padding(padding: const EdgeInsets.all(4.0)),
              Text(
                AppI18N.instance.translate("about.subtitle"),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22),
              ),
              Padding(padding: const EdgeInsets.all(4.0)),
              InkWell(
                child: Text(
                  AppI18N.instance.translate("about.link"),
                  style: TextStyle(color: AppThemeColor.linkUrl, fontSize: 15),
                ),
                onTap: () async {
                  final Uri url = Uri.parse(AppI18N.instance.translate("about.link"));
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
              ),
              Padding(padding: const EdgeInsets.all(8.0)),
              Text(
                AppI18N.instance.translate("about.text"),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
              Padding(padding: const EdgeInsets.all(6.0)),
              version != null
                  ? Text(
                    AppI18N.instance.translate("about.version") + version!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
                  )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
