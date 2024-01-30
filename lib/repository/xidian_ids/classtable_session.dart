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

import 'dart:io';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:jiffy/jiffy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:watermeter_postgraduate/model/xidian_ids/classtable.dart';
import 'package:watermeter_postgraduate/repository/preference.dart';
import 'package:watermeter_postgraduate/repository/xidian_ids/yjspt_session.dart';

class ClassTableFile extends YjsptSession {
  static const schoolClassName = "ClassTable.json";
  static const userDefinedClassName = "UserClass.json";

  ClassTableData simplifyData(Map<String, dynamic> qResult) {
    ClassTableData toReturn = ClassTableData();

    toReturn.semesterCode = qResult["semesterCode"];
    toReturn.termStartDay = qResult["termStartDay"];

    developer.log(
      "${toReturn.semesterCode} ${toReturn.termStartDay}",
      name: "[getClasstable][simplifyData]",
    );

    for (var i in qResult["rows"]) {
      var toDeal = ClassDetail(
        name: i["KCMC"],
        code: i["KCDM"],
      );
      if (!toReturn.classDetail.contains(toDeal)) {
        toReturn.classDetail.add(toDeal);
      }
      toReturn.timeArrangement.add(
        TimeArrangement(
          source: Source.school,
          index: toReturn.classDetail.indexOf(toDeal),
          start: int.parse(i["KSJCDM"]),
          teacher: i["JSXM"],
          stop: int.parse(i["JSJCDM"]),
          day: int.parse(i["XQ"]),
          weekList: List<bool>.generate(
            i["ZCBH"].toString().length,
            (index) => i["ZCBH"].toString()[index] == "1",
          ),
          classroom: i["JASMC"],
        ),
      );
      if (i["ZCBH"].toString().length > toReturn.semesterLength) {
        toReturn.semesterLength = i["ZCBH"].toString().length;
      }
    }

    // Deal with the not arranged data.
    if (qResult["notArranged"] != null) {
      for (var i in qResult["notArranged"]) {
        toReturn.notArranged.add(NotArrangementClassDetail(
          name: i["KCMC"],
          teacher: i["JSXM"],
          code: i["KCDM"],
        ));
      }
    }

    return toReturn;
  }

  Future<ClassTableData> getFromWeb() async {
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
    if (user["currentSemester"] != semesterCode) {
      user["currentSemester"] = semesterCode;
    }

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

    developer.log(
        "Will get $semesterCode which start at $termStartDay, fetching...",
        name: "Yjspt getClasstable");

    qResult = await dio.post(
      'https://yjspt.xidian.edu.cn/gsapp/sys/wdkbapp/modules/xskcb/xspkjgcx.do',
      data: {'XNXQDM': semesterCode, "*order": "-ZCBH"},
    ).then((value) => value.data['datas']['xspkjgcx']);
    if (qResult['extParams']['code'] != 1) {
      throw Exception("${qResult['extParams']['msg']}在已安排课程");
    }

    developer.log("Caching...", name: "Yjspt getClasstable");
    qResult["semesterCode"] = semesterCode;
    qResult["termStartDay"] = termStartDay;
    return simplifyData(qResult);
  }

  Future<ClassTableData> get({
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
      try {
        var qResult = await getFromWeb();
        file.writeAsStringSync(jsonEncode(qResult));
        return qResult;
      } catch (e) {
        if (isExist) {
          return jsonDecode(file.readAsStringSync());
        } else {
          rethrow;
        }
      }
    }
  }
}
