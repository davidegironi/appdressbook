/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'dart:async';
import 'package:appdressbook/auth/bloc/auth_bloc.dart';
import 'package:appdressbook/config/prefskeys.dart';
import 'package:appdressbook/config/config_repository.dart';
import 'package:appdressbook/utils/dio_get.dart';
import 'package:appdressbook/utils/dio_utils.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class AuthRepository {
  final DioGet dioGet = GetIt.instance.get<DioGet>();
  final ConfigRepository configRepository = GetIt.instance.get<ConfigRepository>();
  final authstatusController = StreamController<AuthStatus>();

  AuthRepository() {
    authstatusController.add(AuthStatus.guest);
  }

  // main authtoken
  String? authtoken;

  // set the stream
  Stream<AuthStatus> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield AuthStatus.guest;
    yield* authstatusController.stream;
  }

  // get the current authentication token
  String? getCurrentAuthtoken() {
    return authtoken;
  }

  // check is current profile is login
  bool isCurrentlogin() {
    return authtoken != null;
  }

  // refresh a login token
  Future<String?> refreshtoken() async {
    // if not expiring do not refresh
    final jwt = JWT.decode(authtoken!);
    final exp = jwt.payload['exp'];
    int hoursToExpire =
        exp != null
            ? DateTime.fromMillisecondsSinceEpoch(exp * 1000).toUtc().difference(DateTime.now().toUtc()).inHours
            : 0;
    if (hoursToExpire > 24) return authtoken;

    DioUtilsResponse res = await DioUtils.request<String?>(() async {
      // perform the request
      Response response = await dioGet.dio.put(
        "${configRepository.config.apiUrl}/api/appdressbookauth",
        options: Options(headers: {"authtoken": authtoken}),
        data: {"expiresdays": 8},
      );

      // check response
      return response.data["token"];
    });

    if (res.response != null && res.response is String) return res.response;
    return null;
  }

  // get the authentication token
  Future<String?> getAuthtoken() async {
    authtoken ??= configRepository.prefs.getString(PrefsKeys.authToken.toString());
    return authtoken;
  }

  // set authorization token
  Future<void> setAuthtoken(String authtoken) async {
    // set token
    this.authtoken = authtoken;
    await configRepository.prefs.setString(PrefsKeys.authToken.toString(), authtoken);
  }

  // unset authorization token
  Future<void> unsetAuthtoken() async {
    // unset token
    authtoken = null;
    await configRepository.prefs.remove(PrefsKeys.authToken.toString());
    // record sandbox status

    String? sandbox = configRepository.prefs.getString(PrefsKeys.sandBox.toString());
    // fully erase storage
    await configRepository.prefs.clear();
    // save the apiurl, cause it was valid
    configRepository.prefs.setString(PrefsKeys.apiUrl.toString(), configRepository.config.apiUrl);
    // restore sandbox status
    configRepository.prefs.setString(PrefsKeys.sandBox.toString(), sandbox!);
  }

  // set authenticated
  Future<void> setAuthenticated(String authtoken) async {
    // set token
    await setAuthtoken(authtoken);

    // emit status
    authstatusController.add(AuthStatus.authenticated);
  }

  // set un authenticated
  Future<void> setGuest() async {
    // unset token
    await unsetAuthtoken();

    // emit status
    authstatusController.add(AuthStatus.guest);
  }

  // perform a login request
  Future<String?> login({required String url, required String email, required String password}) async {
    // perform the request
    DioUtilsResponse res = await DioUtils.request<String>(() async {
      // perform the request
      Response response = await dioGet.dio.post(
        "$url/api/appdressbookauth",
        data: {"email": email, "password": password},
      );

      // check response
      return response.data["token"];
    }, preventUnauthorization: true);

    if (res.response != null && res.response is String) return res.response;
    return null;
  }

  // disposition
  void dispose() => authstatusController.close();
}
