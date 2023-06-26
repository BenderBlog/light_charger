/*
Cookie Jar Database.

Copyright (C) 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO watermeter_postgraduate SOURCE CODE
if you want to use.
*/

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';

late Directory supportPath;

class NetworkSession {
  final PersistCookieJar _idsCookieJar = PersistCookieJar(
      ignoreExpires: true, storage: FileStorage("${supportPath.path}/ids"));

  void clearCookieJar() => _idsCookieJar.deleteAll();

  @protected
  Dio get dio => Dio(BaseOptions(
        contentType: Headers.formUrlEncodedContentType,
        headers: {
          HttpHeaders.userAgentHeader:
              "Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36 Edg/109.0.1474.0"
        },
      ))
        ..interceptors.add(CookieManager(_idsCookieJar))
        ..interceptors.add(
          TalkerDioLogger(
            settings: const TalkerDioLoggerSettings(
              printRequestHeaders: true,
              printResponseHeaders: true,
              printResponseMessage: true,
            ),
          ),
        );
}
