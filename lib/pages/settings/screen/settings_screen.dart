/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:appdressbook/pages/about/screen/about_screen.dart';
import 'package:appdressbook/pages/userprofile/screen/userprofile_screen.dart';
import 'package:appdressbook/config/prefskeys.dart';
import 'package:appdressbook/main/app_localization.dart';
import 'package:appdressbook/config/config_repository.dart';
import 'package:appdressbook/main/app_themedata.dart';
import 'package:appdressbook/pages/privacypolicy/screen/privacypolicy_screen.dart';
import 'package:appdressbook/pages/termsandconditions/screen/termsandconditions_screen.dart';
import 'package:appdressbook/main/body_scaffold.dart';
import 'package:appdressbook/main/main_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SettingsScreen extends StatefulWidget {
  static const String routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ConfigRepository configRepository = GetIt.instance.get<ConfigRepository>();

  bool refreshContacts = false;
  bool showLatestContacts = false;

  @override
  void initState() {
    super.initState();

    loadPreferences();
  }

  // load main preferences
  Future<void> loadPreferences() async {
    setState(() {
      refreshContacts = configRepository.prefs.getBool(PrefsKeys.refreshContacts.toString()) ?? false;
      showLatestContacts = configRepository.prefs.getBool(PrefsKeys.showLatestContacts.toString()) ?? false;
    });
  }

  // section title
  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  // section tile
  Widget buildListTile(String title, VoidCallback onTap) {
    return ListTile(title: Text(title), trailing: const Icon(Icons.arrow_forward_ios, size: 16), onTap: onTap);
  }

  // section switch
  Widget buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return ListTile(title: Text(title), trailing: Switch(value: value, onChanged: onChanged));
  }

  @override
  Widget build(BuildContext context) {
    return MainWidget(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppThemeColor.primaryColor,
          title: Text(AppI18N.instance.translate("settings.appbartitle")),
        ),
        body: BodyScaffold(
          isPadded: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account section
              buildSectionTitle(AppI18N.instance.translate("settings.menuaccount")),
              buildListTile(AppI18N.instance.translate("settings.itemuserlogin"), () {
                // navigate to Userprofile
                Navigator.of(context).pushNamed(UserprofileScreen.routeName);
              }),
              // Config section
              buildSectionTitle(AppI18N.instance.translate("settings.menuconfig")),
              buildSwitchTile(AppI18N.instance.translate("settings.itemrefreshcontacts"), refreshContacts, (value) {
                setState(() => refreshContacts = value);
                configRepository.prefs.setBool(PrefsKeys.refreshContacts.toString(), value);
              }),
              buildSwitchTile(AppI18N.instance.translate("settings.showlatest"), showLatestContacts, (value) {
                setState(() => showLatestContacts = value);
                configRepository.prefs.setBool(PrefsKeys.showLatestContacts.toString(), value);
              }),
              // Info section
              buildSectionTitle(AppI18N.instance.translate("settings.menuinfo")),
              buildListTile(AppI18N.instance.translate("settings.itemabout"), () {
                Navigator.of(context).pushNamed(AboutScreen.routeName);
              }),
              buildListTile(AppI18N.instance.translate("settings.itemtermsandconditions"), () {
                Navigator.of(context).pushNamed(TermsAndConditionsScreen.routeName);
              }),
              buildListTile(AppI18N.instance.translate("settings.itemprivacypolicy"), () {
                Navigator.of(context).pushNamed(PrivacyPolicyScreen.routeName);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
