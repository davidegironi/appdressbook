/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'dart:convert';

import 'package:appdressbook/api/entities/appdressbookconfig.dart';
import 'package:appdressbook/config/config.dart';
import 'package:appdressbook/config/prefskeys.dart';
import 'package:appdressbook/api/entities/appdressbookcontacts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigRepository {
  // SharedPreferences instance
  final SharedPreferences prefs;

  Config config = Config();

  ConfigRepository(this.prefs) {
    // load config
    config.apiUrl = prefs.getString(PrefsKeys.apiUrl.toString()) ?? "";
    config.authToken = prefs.getString(PrefsKeys.authToken.toString()) ?? "";
    try {
      config.contacts = AppDressBookContacts.fromMap(jsonDecode(prefs.getString(PrefsKeys.contacts.toString())!));
    } catch (_) {}
    try {
      config.config = AppDressBookConfig.fromMap(jsonDecode(prefs.getString(PrefsKeys.config.toString())!));
    } catch (_) {}
  }
}
