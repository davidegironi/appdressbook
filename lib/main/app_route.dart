/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:appdressbook/pages/about/screen/about_screen.dart';
import 'package:appdressbook/auth/screen/login_screen.dart';
import 'package:appdressbook/pages/userprofile/screen/userprofile_screen.dart';
import 'package:appdressbook/pages/addressbook/screen/contacts_screen.dart';
import 'package:appdressbook/pages/addressbook/screen/person_screen.dart';
import 'package:appdressbook/pages/spash/screen/splash_screen.dart';
import 'package:appdressbook/pages/privacypolicy/screen/privacypolicy_screen.dart';
import 'package:appdressbook/pages/settings/screen/settings_screen.dart';
import 'package:appdressbook/pages/termsandconditions/screen/termsandconditions_screen.dart';
import 'package:appdressbook/utils/routeerror_screen.dart';
import 'package:flutter/material.dart';

class AppRoute {
  // name route handler
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case SplashScreen.routeName:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AboutScreen.routeName:
        return MaterialPageRoute(builder: (_) => AboutScreen());
      case TermsAndConditionsScreen.routeName:
        return MaterialPageRoute(builder: (_) => TermsAndConditionsScreen());
      case PrivacyPolicyScreen.routeName:
        return MaterialPageRoute(builder: (_) => PrivacyPolicyScreen());
      case LoginScreen.routeName:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case UserprofileScreen.routeName:
        return MaterialPageRoute(builder: (_) => UserprofileScreen());
      case SettingsScreen.routeName:
        return MaterialPageRoute(builder: (_) => SettingsScreen());
      case ContactsScreen.routeName:
        return MaterialPageRoute(builder: (_) => ContactsScreen());
      case PersonScreen.routeName:
        return MaterialPageRoute(builder: (_) => PersonScreen(args: settings.arguments as PersonScreenArguments));
      default:
        return MaterialPageRoute(builder: (_) => RouteErrorScreen(route: settings.name));
    }
  }
}
