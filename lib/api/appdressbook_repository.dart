/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'dart:async';

import 'package:appdressbook/auth/repositories/auth_repository.dart';
import 'package:appdressbook/config/config_repository.dart';
import 'package:appdressbook/api/entities/appdressbookconfig.dart';
import 'package:appdressbook/api/entities/appdressbookcontacts.dart';
import 'package:appdressbook/utils/dio_get.dart';
import 'package:appdressbook/utils/dio_utils.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class AppDressBookRepository {
  final AuthRepository authRepository = GetIt.instance.get<AuthRepository>();
  final DioGet dioGet = GetIt.instance.get<DioGet>();
  final ConfigRepository configRepository = GetIt.instance.get<ConfigRepository>();

  AppDressBookRepository();

  // Check if contact list request
  Future<bool> isContactsListUpdated(String hash) async {
    final authToken = authRepository.getCurrentAuthtoken()!;

    // perform the request
    DioUtilsResponse res = await DioUtils.request<bool>(() async {
      Response response = await dioGet.dioCached.get(
        "${configRepository.config.apiUrl}/api/appdressbookcontacts?mode=h",
        options: Options(headers: {"authtoken": authToken}),
      );

      try {
        AppDressBookContacts res = AppDressBookContacts.fromMap(response.data);
        return res.hash == hash ? false : true;
      } catch (e) {
        return true;
      }
    });

    return res.response == true;
  }

  // Contact list request
  Future<AppDressBookContacts?> getContactsList() async {
    final authToken = authRepository.getCurrentAuthtoken()!;

    // perform the request
    DioUtilsResponse res = await DioUtils.request<AppDressBookContacts?>(() async {
      // perform the request
      Response response = await dioGet.dioCached.get(
        "${configRepository.config.apiUrl}/api/appdressbookcontacts?mode=l",
        options: Options(headers: {"authtoken": authToken}),
      );

      // check response
      try {
        return AppDressBookContacts.fromMap(response.data);
      } catch (e) {
        return null;
      }
    });

    if (res.response != null && res.response is AppDressBookContacts) return res.response;
    return null;
  }

  // Config request
  Future<AppDressBookConfig?> getConfig() async {
    // perform the request
    DioUtilsResponse res = await DioUtils.request<AppDressBookConfig?>(() async {
      // perform the request
      Response response = await dioGet.dioCached.get("${configRepository.config.apiUrl}/api/appdressbookconfig");

      // check response
      try {
        return AppDressBookConfig.fromMap(response.data);
      } catch (e) {
        return null;
      }
    });

    if (res.response != null && res.response is AppDressBookConfig) return res.response;
    return null;
  }
}
