/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:appdressbook/config/prefskeys.dart';
import 'package:appdressbook/main/app.dart';
import 'package:appdressbook/auth/repositories/auth_repository.dart';
import 'package:appdressbook/config/config_repository.dart';
import 'package:appdressbook/utils/sandbox_banner.dart';
import 'package:appdressbook/utils/dio_get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  final getIt = GetIt.instance;

  // ensure widget is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // initialize sharedpreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // load configuration
  String? sandbox = prefs.getString(PrefsKeys.sandBox.toString());
  if (sandbox == null || (sandbox != Sandbox.production.toString() && sandbox != Sandbox.development.toString())) {
    if (kReleaseMode) {
      sandbox = Sandbox.production.toString();
    } else {
      sandbox = Sandbox.development.toString();
    }
    prefs.setString(PrefsKeys.sandBox.toString(), sandbox);
  }
  if (sandbox == Sandbox.production.toString()) {
    await dotenv.load(fileName: "assets/.env_production");
  } else if (sandbox == Sandbox.development.toString()) {
    await dotenv.load(fileName: "assets/.env_development");
  }

  // initialize dioget
  final dioGet = DioGet();
  await dioGet.init();

  // register singletons, order matters
  getIt.registerSingleton<DioGet>(dioGet);
  getIt.registerSingleton<ConfigRepository>(ConfigRepository(prefs));
  getIt.registerSingleton<AuthRepository>(AuthRepository());

  runApp(const App());
}
