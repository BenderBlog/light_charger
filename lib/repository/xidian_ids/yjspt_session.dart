/// Copyright 2024 BenderBlog Rodriguez and Contributors
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
///     http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.

import 'dart:convert';

import 'dart:developer' as developer;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:watermeter_postgraduate/repository/xidian_ids/ids_session.dart';
import 'package:watermeter_postgraduate/repository/preference.dart';

const base = "https://yjspt.xidian.edu.cn";

class YjsptSession extends IDSSession {
  /// This header shall only be used in the yjspt related stuff...
  Dio get dioYjspt => super.dio
    ..options = BaseOptions(
      contentType: Headers.formUrlEncodedContentType,
      headers: {
        HttpHeaders.userAgentHeader:
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0",
        HttpHeaders.refererHeader: "https://ids.xidian.edu.cn/",
        HttpHeaders.hostHeader: "yjspt.xidian.edu.cn",
        HttpHeaders.connectionHeader: 'Keep-Alive',
      },
      validateStatus: (status) =>
          status != null && status >= 200 && status < 400,
    )
    ..options.followRedirects = false;

  Future<bool> isLoggedIn() async {
    return user["roleId"] != null;
    /*
    var response = await dio.get(
      "https://Yjspt.xidian.edu.cn/jsonp/userFavoriteApps.json",
    );
    developer.log("Yjspt isLoggedin: ${response.data["hasLogin"]}",
        name: "Yjspt isLoggedIn");
    return response.data["hasLogin"];
    */
  }

  Future<void> loginYjspt({
    required String username,
    required String password,
    bool forceReLogin = false,
    void Function(int, String)? onResponse,
    Future<void> Function(String)? sliderCaptcha,
  }) async {
    if (forceReLogin == true || user["roleId"] == null) {
      var response = await dioYjspt.get(base);
      developer.log(
        "Return code: ${response.statusCode}.",
        name: "Yjspt login",
      );
      if (response.headers[HttpHeaders.locationHeader] != null) {
        await dioYjspt.get(response.headers[HttpHeaders.locationHeader]![0]);
      }
      developer.log(
        "Ready to login. Is force relogin: $forceReLogin.",
        name: "Yjspt login",
      );
      String location = await super.login(
        username: username,
        password: password,
        target: "$base/gsapp/sys/yjsemaphome/portal/index.do",
        sliderCaptcha: sliderCaptcha,
      );
      developer.log(
        "Received location: $location",
        name: "Yjspt login",
      );
      response = await dioYjspt.get(location);
      while (response.headers[HttpHeaders.locationHeader] != null) {
        location = response.headers[HttpHeaders.locationHeader]![0];
        developer.log(
          "Received location: $location",
          name: "Yjspt login",
        );
        response = await dioYjspt.get(location);
      }
      //await dioYjspt.get("$base/gsapp/sys/yjsemaphome/portal/index.do");
      var roleIdJson = await dioYjspt
          .get("$base/gsapp/sys/yjsemaphome/modules/pubWork/getUserInfo.do")
          .then((value) => value.data["data"]["grouplist"]);
      developer.log("roleidJson: $roleIdJson.", name: "Yjspt login");
      addUser("roleId", json.decode(roleIdJson)[0]["ROLEID"]);
      developer.log("roleid: ${user["roleId"]}", name: "Yjspt login");
    }
  }

  Future<String> useApp(String name) async {
    developer.log("Ready to use the app $name with ${user["roleId"]}",
        name: "Yjspt useApp");
    developer.log("Try to login.", name: "Yjspt useApp");
    await loginYjspt(
        username: user["idsAccount"]!, password: user["idsPassword"]!);
    developer.log("Try to use the $name. roleId = ${user["roleId"]}",
        name: "Yjspt useApp");
    return "$base/gsapp/sys/$name/*default/index.do?THEME=blue&EMAP_LANG=zh&min=1&_yhz=${user["roleId"]}";
  }
}

var ses = YjsptSession();
