/*
E-hall class, which get lots of useful data here.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO watermeter_postgraduate SOURCE CODE
if you want to use.

Thanks xidian-script and libxdauth!
*/

import 'dart:convert';

import 'dart:developer' as developer;
import 'package:jiffy/jiffy.dart';
import 'package:watermeter_postgraduate/repository/xidian_ids/ids_session.dart';
import 'package:watermeter_postgraduate/model/user.dart';

const base = "https://yjspt.xidian.edu.cn";

class YjsptSession extends IDSSession {
  @override
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
    void Function(int number, String status)? onResponse,
  }) async {
    if (forceReLogin == true || user["roleId"] == null) {
      developer.log("Ready to login. Is force relogin: $forceReLogin.",
          name: "Yjspt login");
      await super.login(
        username: username,
        password: password,
        target:
            "https://yjspt.xidian.edu.cn/gsapp/sys/yjsemaphome/portal/index.do",
      );
      await dio.get(
          "https://yjspt.xidian.edu.cn/gsapp/sys/yjsemaphome/portal/index.do");
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

  Future<void> getInformation() async {
    developer.log("Ready to get the user information.",
        name: "Yjspt getInformation");
    var firstPost = await useApp("wdxj");
    var data = await dio.get(firstPost).then((value) => value.headers);

    developer.log(data.toString(), name: "Yjspt getInformation");

    /// Get information here. resultCode==00000 is successful.
    developer.log("Getting the user information.",
        name: "Yjspt getInformation");
    var detailed = await dio.post(
        "https://yjspt.xidian.edu.cn/gsapp/sys/wdxj/modules/wdxj/xsjcxxcx.do",
        data: {
          "pageSize": "1",
          "pageNumber": "1",
          "XH": user["idsAccount"],
        }).then((value) => value.data["datas"]["xsjcxxcx"]);

    /// Get information here. resultCode==00000 is successful.
    developer.log("Storing the user information.",
        name: "Yjspt getInformation");
    if (detailed["extParams"]["code"] != 1) {
      throw detailed.toString();
    } else {
      await addUser("name", detailed["rows"][0]["XM"]);
    }

    String get = await useApp("wdkbapp");
    await dio.post(get);

    developer.log("Fetch the semester information.",
        name: "Yjspt getClasstable");
    String semesterCode = await dio
        .post(
          "https://yjspt.xidian.edu.cn/gsapp/sys/wdkbapp/modules/xskcb/kfdxnxqcx.do",
        )
        .then((value) => value.data['datas']['kfdxnxqcx']['rows'][0]['XNXQDM']);
    if (user["currentSemester"] != semesterCode) {
      user["currentSemester"] = semesterCode;
    }

    var now = DateTime.now();

    developer.log("Fetch the day the semester begin.",
        name: "Yjspt getClasstable");
    var currentWeek = await dio.post(
      'https://yjspt.xidian.edu.cn/gsapp/sys/yjsemaphome/portal/queryRcap.do',
      data: {'day': Jiffy.parseFromDateTime(now).format(pattern: "yyyyMMdd")},
    ).then((value) => value.data);

    developer.log(
        "${Jiffy.parseFromDateTime(now).format(pattern: "yyyyMMdd")}  $currentWeek, fetching...",
        name: "Yjspt getClasstable");

    currentWeek = RegExp(r'[0-9]+').firstMatch(currentWeek["xnxq"])![0]!;

    developer.log("Current week is $currentWeek, fetching...",
        name: "Yjspt getClasstable");

    int weekDay = now.weekday - 1;

    String termStartDay = Jiffy.parseFromDateTime(now)
        .add(weeks: 1 - int.parse(currentWeek), days: -weekDay)
        .format(pattern: "yyyy-MM-dd");

    if (user["currentStartDay"] != termStartDay) {
      user["currentStartDay"] = termStartDay;
    }
  }
}

var ses = YjsptSession();
