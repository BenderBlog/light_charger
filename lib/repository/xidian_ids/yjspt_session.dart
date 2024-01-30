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
import 'package:watermeter_postgraduate/repository/xidian_ids/ids_session.dart';
import 'package:watermeter_postgraduate/repository/preference.dart';

const base = "https://yjspt.xidian.edu.cn";

class YjsptSession extends IDSSession {
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
      developer.log(
        "Ready to login. Is force relogin: $forceReLogin.",
        name: "Yjspt login",
      );
      await super.login(
        username: username,
        password: password,
        target: "$base/gsapp/sys/yjsemaphome/portal/index.do",
      );
      await dio.get(
        "$base/gsapp/sys/yjsemaphome/portal/index.do",
      );
      var roleIdJson = await dio
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
