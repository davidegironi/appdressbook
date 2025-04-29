/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:appdressbook/main/app_authenticator.dart';
import 'package:appdressbook/main/app_localization.dart';
import 'package:appdressbook/main/app_route.dart';
import 'package:appdressbook/auth/bloc/auth_bloc.dart';
import 'package:appdressbook/auth/repositories/auth_repository.dart';
import 'package:appdressbook/pages/spash/screen/splash_screen.dart';
import 'package:appdressbook/main/app_themedata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final AuthRepository authRepository = GetIt.instance.get<AuthRepository>();
  final _navigatorKey = GlobalKey<NavigatorState>();

  // authentication listener
  void _listener(context, state) async {
    switch (state.status) {
      case AuthStatus.authenticated:
        try {
          AppAuthenticator.authenticated(context, authRepository, _navigatorKey.currentState);
        } catch (_) {
          AppAuthenticator.unauthenticated(context, authRepository, _navigatorKey.currentState);
        }
        break;
      case AuthStatus.guest:
        AppAuthenticator.unauthenticated(context, authRepository, _navigatorKey.currentState);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: authRepository,
      child: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(authRepository: authRepository),
        child: MaterialApp(
          navigatorKey: _navigatorKey,
          theme: AppThemeData().themeData,
          builder: (context, child) {
            return BlocListener<AuthBloc, AuthState>(listener: _listener, child: child);
          },
          supportedLocales: List<Locale>.from(
            // set supported locales
            dotenv.env["supported_locales"]!
                .split(',')
                .map((localeLine) => Locale(localeLine.toString().split("-")[0], localeLine.toString().split("-")[1])),
          ),
          localizationsDelegates: const [
            AppI18N.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          onGenerateRoute: AppRoute.generateRoute,
          initialRoute: SplashScreen.routeName,
        ),
      ),
    );
  }
}
