/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:appdressbook/pages/about/screen/about_screen.dart';
import 'package:appdressbook/config/config_repository.dart';
import 'package:appdressbook/main/app_localization.dart';
import 'package:appdressbook/auth/cubit/login_cubit.dart';
import 'package:appdressbook/auth/repositories/auth_repository.dart';
import 'package:appdressbook/main/app_themedata.dart';
import 'package:appdressbook/utils/snackbar_utils.dart';
import 'package:appdressbook/utils/loading_spinner.dart';
import 'package:appdressbook/main/body_scaffold.dart';
import 'package:appdressbook/main/main_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ConfigRepository configRepository = GetIt.instance.get<ConfigRepository>();

  String url = "";
  String username = "";
  String password = "";

  // listener
  void _listener(context, state) {
    if (state is LoginSuccess) {
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          // if we are still here, reload the first page
          if (ModalRoute.of(context) != null && ModalRoute.of(context)!.isCurrent) {
            Navigator.pop(context, true);
          }
        }
      });
    } else if (state is LoginFailure) {
      SnackBarUtils.errorSnackbar(context, state.error ?? AppI18N.instance.translate("auth.errorgeneric"));
    }
  }

  // login
  void login(BuildContext context) {
    // validate fields
    if (!Uri.parse(url).isAbsolute) {
      SnackBarUtils.errorSnackbar(context, AppI18N.instance.translate("auth.errorurlinvalid"));
      return;
    }
    String urlsanitized = url.trim();
    if (url.endsWith('/')) {
      urlsanitized = url.substring(0, url.length - 1);
    }
    context.read<LoginCubit>().login(url: urlsanitized, username: username, password: password);
  }

  @override
  void initState() {
    super.initState();

    // load data
    loadPreferences();
  }

  // load preferences
  Future<void> loadPreferences() async {
    setState(() => url = configRepository.config.apiUrl);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => LoginCubit(RepositoryProvider.of<AuthRepository>(context), configRepository),
      child: BlocConsumer<LoginCubit, LoginState>(
        listener: _listener,
        builder: (context, state) {
          return MainWidget(
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: AppThemeColor.primaryColor,
                title: Text(AppI18N.instance.translate("auth.appbarlogin")),
                actions: [
                  IconButton(
                    icon: Icon(Icons.info),
                    onPressed: () => Navigator.of(context).pushNamed(AboutScreen.routeName),
                  ),
                ],
              ),
              body: BodyScaffold(
                isPadded: true,
                child:
                    state is LoginLoading || state is LoginSuccess
                        ? Align(alignment: Alignment.center, child: LoadingSpinner())
                        : Align(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 200.0, child: Image.asset("assets/img/logo.png", fit: BoxFit.contain)),
                              Padding(padding: const EdgeInsets.all(12.0)),
                              TextFormField(
                                key: Key(url.toString()),
                                initialValue: url,
                                onChanged: (value) => url = value,
                                decoration: InputDecoration(labelText: AppI18N.instance.translate("auth.url")),
                              ),
                              TextFormField(
                                initialValue: username,
                                onChanged: (value) => username = value,
                                decoration: InputDecoration(labelText: AppI18N.instance.translate("auth.username")),
                              ),
                              TextFormField(
                                onChanged: (value) => password = value,
                                obscureText: true,
                                decoration: InputDecoration(labelText: AppI18N.instance.translate("auth.password")),
                              ),
                              Padding(padding: const EdgeInsets.all(12.0)),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  child: Text(AppI18N.instance.translate("auth.buttonlogin")),
                                  onPressed: () => login(context),
                                ),
                              ),
                            ],
                          ),
                        ),
              ),
            ),
          );
        },
      ),
    );
  }
}
