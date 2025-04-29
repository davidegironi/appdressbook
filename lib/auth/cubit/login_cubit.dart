/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:appdressbook/config/prefskeys.dart';
import 'package:appdressbook/config/config_repository.dart';
import 'package:appdressbook/main/app_localization.dart';
import 'package:appdressbook/auth/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository authRepository;
  final ConfigRepository configRepository;

  LoginCubit(this.authRepository, this.configRepository) : super(LoginInitial()) {
    emit(LoginInitial());
  }

  // login
  Future<void> login({required String url, required String email, required String password}) async {
    // emit loading
    emit(LoginLoading());

    // perform the request
    final authtoken = await authRepository.login(url: url, email: email, password: password);

    // check response
    if (authtoken != null) {
      // set authenticated
      await authRepository.setAuthenticated(authtoken);

      // save the apiurl, cause it is valid
      configRepository.prefs.setString(PrefsKeys.apiUrl.toString(), url);
      configRepository.config.apiUrl = url;

      // emit success
      emit(LoginSuccess(authtoken));
    } else {
      // emit error
      emit(LoginFailure(AppI18N.instance.translate("auth.loginerror")));
    }
  }

  // try to login
  Future<void> loginvalidate({required String email, required String password}) async {
    emit(LoginLoading());
    emit(LoginFailure(AppI18N.instance.translate("auth.loginvalidate")));
  }
}
