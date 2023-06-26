/*
The class table window source.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO watermeter_postgraduate SOURCE CODE
if you want to use.

Thanks xidian-script and libxdauth!
*/

import 'dart:io';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:jiffy/jiffy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:watermeter_postgraduate/repository/xidian_ids/yjspt_session.dart';

class ClassTableFile extends YjsptSession {
  Future<Map<String, dynamic>> getFromWeb() async {
    DateTime now = DateTime.now();
    Map<String, dynamic> qResult = {};
    developer.log("Login the system.", name: "Yjspt getClasstable");
    String get = await useApp("wdkbapp");
    await dio.post(get);

    developer.log("Fetch the semester information.",
        name: "Yjspt getClasstable");
    String semesterCode = await dio
        .post(
          "https://yjspt.xidian.edu.cn/gsapp/sys/wdkbapp/modules/xskcb/kfdxnxqcx.do",
        )
        .then((value) => value.data['datas']['kfdxnxqcx']['rows'][0]['XNXQDM']);

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

    developer.log(
        "Will get $semesterCode which start at $termStartDay, fetching...",
        name: "Yjspt getClasstable");

    qResult = await dio.post(
      'https://yjspt.xidian.edu.cn/gsapp/sys/wdkbapp/modules/xskcb/xspkjgcx.do',
      data: {'XNXQDM': semesterCode, "*order": "-ZCBH"},
    ).then((value) => value.data['datas']['xspkjgcx']);
    if (qResult['extParams']['code'] != 1) {
      throw qResult['extParams']['msg'] + "在已安排课程";
    }

    developer.log("Caching...", name: "Yjspt getClasstable");
    qResult["semesterCode"] = semesterCode;
    qResult["termStartDay"] = termStartDay;
    return qResult;
  }

  Future<Map<String, dynamic>> get({
    bool isForce = false,
  }) async {
    developer.log("Check whether the classtable has fetched.",
        name: "Yjspt getClasstable");

    developer.log("Start fetching the classtable.",
        name: "Yjspt getClasstable");
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory destination =
        Directory("${appDocDir.path}/org.superbart.watermeter_postgraduate");
    if (!destination.existsSync()) {
      await destination.create();
    }
    var file = File("${destination.path}/ClassTable.json");
    bool isExist = file.existsSync();

    developer.log(
        isExist &&
                isForce == false &&
                DateTime.now().difference(file.lastModifiedSync()).inDays <= 3
            ? "Cache"
            : "Fetch from internet.",
        name: "Yjspt getClasstable");

    if (isExist &&
        isForce == false &&
        DateTime.now().difference(file.lastModifiedSync()).inDays <= 3) {
      return jsonDecode(file.readAsStringSync());
    } else {
      var qResult = await getFromWeb();
      file.writeAsStringSync(jsonEncode(qResult));
      return qResult;
    }

    /*
    onResponse(70, "获取未安排内容");
    var notOnTable = await dio.post(
      "https://Yjspt.xidian.edu.cn/jwapp/sys/wdkb/modules/xskcb/cxxsllsywpk.do",
      data: {'XNXQDM': semesterCode},
    ).then((value) => value.data['datas']['cxxsllsywpk']);
    if (qResult['extParams']['code'] != 1) {
      throw qResult['extParams']['msg'] + "在未安排课程";
    }
    onResponse(90, "处理未安排内容");
    for (var i in notOnTable["rows"]) {
      classData.notOnTable.add(ClassDetail(
        name: i["KCM"],
        teacher: i["SKJS"],
        place: i["JASDM"],
      ));
    }
    */
  }
}
