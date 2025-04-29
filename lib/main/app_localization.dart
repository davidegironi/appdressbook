/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppI18N {
  final Locale locale;

  AppI18N(this.locale);

  // access app localization
  static AppI18N of(BuildContext context) {
    return Localizations.of<AppI18N>(context, AppI18N) ?? _AppI18NDelegate.instance;
  }

  // intstantiate the deleagate
  static const LocalizationsDelegate<AppI18N> delegate = _AppI18NDelegate();

  // get the static instance
  static AppI18N get instance => _AppI18NDelegate.instance;

  // localized string
  Map<String, String> localizedStrings = <String, String>{};

  // try to load the localized strings
  Future<bool> load() async {
    Map<String, dynamic> jsonMap = <String, dynamic>{};

    // load the language file
    try {
      String jsonString = await rootBundle.loadString('assets/i18n/${locale.languageCode}.json');
      jsonMap = jsonDecode(jsonString);
    } catch (_) {}

    localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  // upsert to local map
  upsert(String key, String value) {
    localizedStrings[key] = value;
  }

  // upsert to local map
  String getLocale() {
    return locale.languageCode;
  }

  // translate the string
  String translate(String key) {
    if (key.isEmpty) return "";
    if (localizedStrings.containsKey(key)) {
      return localizedStrings[key] ?? "";
    } else {
      return key;
    }
  }
}

// app localization deletage
class _AppI18NDelegate extends LocalizationsDelegate<AppI18N> {
  const _AppI18NDelegate();

  static late AppI18N instance;

  // check language is supported
  @override
  bool isSupported(Locale locale) {
    final supportedLocalesLang = List<String>.from(
      dotenv.env["supported_locales"]!.split(',').map((localeLine) => localeLine.toString().split("-")[0]),
    );
    return supportedLocalesLang.contains(locale.languageCode);
  }

  // load the language file
  @override
  Future<AppI18N> load(Locale locale) async {
    AppI18N localizations = AppI18N(locale);
    await localizations.load();
    instance = localizations;
    return localizations;
  }

  // check if should reloade
  @override
  bool shouldReload(_AppI18NDelegate old) => false;
}
