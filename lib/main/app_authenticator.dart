/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'dart:convert';

import 'package:appdressbook/auth/bloc/auth_bloc.dart';
import 'package:appdressbook/auth/repositories/auth_repository.dart';
import 'package:appdressbook/auth/screen/login_screen.dart';
import 'package:appdressbook/config/prefskeys.dart';
import 'package:appdressbook/config/config_repository.dart';
import 'package:appdressbook/pages/addressbook/screen/contacts_screen.dart';
import 'package:appdressbook/api/appdressbook_repository.dart';
import 'package:appdressbook/api/entities/appdressbookconfig.dart';
import 'package:appdressbook/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'app_localization.dart';

class AppAuthenticator {
  // perform on autheticated state
  static void authenticated(BuildContext context, AuthRepository authRepository, NavigatorState? navigatorState) async {
    final AppDressBookRepository repository = AppDressBookRepository();
    final ConfigRepository configRepository = GetIt.instance.get<ConfigRepository>();

    bool authenticated = false;

    // check if is login
    authenticated = authRepository.isCurrentlogin();

    // try to refresh token
    authenticated = await authRepository.refreshtoken() != null;

    // load config
    if (authenticated) {
      // load authtoken
      configRepository.config.authToken = authRepository.getCurrentAuthtoken()!;

      // load config
      AppDressBookConfig? config = await repository.getConfig();
      if (config != null) {
        configRepository.config.config = config;
        // update prefs
        configRepository.prefs.setString(
          PrefsKeys.config.toString(),
          jsonEncode((configRepository.config.config as AppDressBookConfig).toMap()),
        );
      } else {
        // try to load from prefs
        try {
          configRepository.config.config = AppDressBookConfig.fromMap(
            jsonDecode(configRepository.prefs.getString(PrefsKeys.config.toString())!),
          );
        } catch (_) {}
        configRepository.config.config ??= AppDressBookConfig(
          companyname: "/",
          needslogin: false,
          terms: await rootBundle.loadString('assets/docs/Terms_and_Conditions.txt'),
          privacy: await rootBundle.loadString('assets/docs/Privacy_Policy.txt'),
        );
      }
    }

    if (authenticated) {
      // contacts screen
      navigatorState?.pushNamedAndRemoveUntil(ContactsScreen.routeName, (route) => false);
    } else {
      // show error messages
      if (context.mounted) {
        SnackBarUtils.errorSnackbar(context, AppI18N.instance.translate("app.cannotauthenticate"));
      }
      // logout
      if (context.mounted) {
        context.read<AuthBloc>().add(AuthLogoutRequested());
      }
    }
  }

  // perform on unauthenticated state
  static void unauthenticated(
    BuildContext context,
    AuthRepository authRepository,
    NavigatorState? navigatorState,
  ) async {
    // try to login
    final authtoken = await authRepository.getAuthtoken();
    if (authtoken != null) {
      await authRepository.setAuthenticated(authtoken);
    } else {
      // guest page
      navigatorState?.pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
    }
  }
}
