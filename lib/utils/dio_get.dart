/// Copyright (c) 2021 Davide Gironi
///
/// Please refer to LICENSE file for licensing information
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioGet {
  late Dio dio;
  late Dio dioCached;

  // define timeout
  static const Duration timetout = Duration(seconds: 10);

  // initialize
  Future init() async {
    // standard dio
    dio = Dio(BaseOptions(connectTimeout: timetout, receiveTimeout: timetout, sendTimeout: timetout));

    // cached dio
    dioCached = Dio(BaseOptions(connectTimeout: timetout, receiveTimeout: timetout, sendTimeout: timetout));
    dioCached.interceptors.add(await DioCacheInterceptor.create());
  }
}

// DioCache interceptor
class DioCacheInterceptor extends Interceptor {
  final SharedPreferences prefs;
  final String cachePrefix = 'diocache_';

  DioCacheInterceptor._(this.prefs);

  // create the interceptor with initialized SharedPreferences
  static Future<DioCacheInterceptor> create() async {
    final prefs = await SharedPreferences.getInstance();
    return DioCacheInterceptor._(prefs);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // build cache key
    String cacheKey = _buildCacheKey(response.requestOptions.uri.toString(), response.requestOptions.data);

    // save cached data
    _saveToCache(cacheKey, response.data);

    // pass the response to the handler
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // check for network-related errors
    if (err.type == DioExceptionType.connectionTimeout || err.type == DioExceptionType.unknown) {
      // build cache key
      String cacheKey = _buildCacheKey(err.requestOptions.uri.toString(), err.requestOptions.data);

      // get cached value
      final cachedData = _getFromCache(cacheKey);
      if (cachedData != null) {
        // return cached response
        handler.resolve(Response(data: cachedData, requestOptions: err.requestOptions, statusCode: 200));
        return;
      }
    }

    // pass the error to the next handler if no cache is found
    handler.next(err);
  }

  // build a cache key
  String _buildCacheKey(String url, dynamic data) {
    return cachePrefix + md5.convert(utf8.encode(url.toLowerCase() + jsonEncode(data ?? {}))).toString();
  }

  // save data to cache
  void _saveToCache(String key, dynamic data) {
    final String jsonData = jsonEncode(data);
    prefs.setString(key, jsonData);
  }

  // get data from cache
  dynamic _getFromCache(String key) {
    final String? jsonData = prefs.getString(key);
    if (jsonData == null) return null;

    try {
      return jsonDecode(jsonData);
    } catch (e) {
      return null;
    }
  }

  // clear cache
  Future<void> clearCache() async {
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(cachePrefix)) {
        await prefs.remove(key);
      }
    }
  }
}
