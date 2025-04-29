/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'package:appdressbook/main/app_localization.dart';
import 'package:appdressbook/auth/repositories/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

class DioUtils {
  // show all error
  static const bool showAllErrors = true;

  // perform a request
  static Future<DioUtilsResponse> request<T>(
    Future<T> Function() f, {
    bool preventUnauthorization = false,
  }) async {
    DioUtilsResponse ret = DioUtilsResponse();
    try {
      ret.response = await f();
    } on DioException catch (ex) {
      ret.error = AppI18N.instance.translate("http.requesterror");
      if (ex.type == DioExceptionType.receiveTimeout ||
          ex.type == DioExceptionType.connectionTimeout) {
        ret.error = AppI18N.instance.translate("http.servernotreachable");
      } else if (ex.type == DioExceptionType.badResponse) {
        if (ex.response != null) {
          if (ex.response!.statusCode == 403 && !preventUnauthorization) {
            AuthRepository authRepository =
                GetIt.instance.get<AuthRepository>();
            authRepository.setGuest();
            ret.error = AppI18N.instance.translate("http.notloggedin");
          } else {
            if (ex.response!.data != null) {
              if (ex.response!.data is Map &&
                  ex.response!.data.containsKey("errors")) {
                ret.error =
                    showAllErrors
                        ? ex.response!.data["errors"][0]
                        : ex.response!.data["errors"].join("\n");
              } else {
                // Handle case when "errors" key is missing
                ret.error = AppI18N.instance.translate("http.requesterror");
              }
            } else {
              ret.error = AppI18N.instance.translate("http.requesterror");
            }
          }
        }
      } else if (ex.type == DioExceptionType.connectionError) {
        if (ex.message != null &&
            ex.message!.toLowerCase().contains('socketexception')) {
          ret.error = AppI18N.instance.translate("http.nointernet");
        }
      } else {
        ret.error = AppI18N.instance.translate("http.requesterror");
      }
    } on Exception catch (_) {
      ret.error = AppI18N.instance.translate("http.requestexception");
    }
    return ret;
  }
}

// dio Utils generic response
class DioUtilsResponse<T> {
  T? response;
  String? error;
}
