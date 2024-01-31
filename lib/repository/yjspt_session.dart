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
import 'package:jiffy/jiffy.dart';
import 'package:watermeter_postgraduate/model/xidian_ids/classtable.dart';
import 'package:watermeter_postgraduate/repository/network_session.dart';
import 'package:watermeter_postgraduate/repository/ids_session.dart';
import 'package:watermeter_postgraduate/repository/preference.dart';

import 'package:watermeter_postgraduate/model/xidian_ids/score.dart';
import 'package:watermeter_postgraduate/model/xidian_ids/exam.dart';

const base = "https://yjspt.xidian.edu.cn";

var ses = YjsptSession();

class YjsptSession extends IDSSession {
  static const schoolClassName = "ClassTable.json";
  static const userDefinedClassName = "UserClass.json";

  /// This header shall only be used in the yjspt related stuff...
  Dio get dioYjspt => super.dio
    ..options = BaseOptions(
      contentType: Headers.formUrlEncodedContentType,
      headers: {
        HttpHeaders.userAgentHeader:
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0",
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
    String? username,
    String? password,
    bool forceReLogin = false,
    void Function(int, String)? onResponse,
    Future<void> Function(String)? sliderCaptcha,
  }) async {
    if (forceReLogin == true || user["roleId"] == null) {
      var response = await dioYjspt.get(base);
      developer.log(
        "Ready to login. Is force relogin: $forceReLogin.",
        name: "Yjspt login",
      );
      late String location;
      if (username == null || password == null) {
        assert(user["idsAccount"] != null || user["idsPassword"] != null);
        location = await super.checkAndLogin(
          target: "$base/gsapp/sys/yjsemaphome/portal/index.do",
          sliderCaptcha: sliderCaptcha,
        );
      } else {
        location = await super.login(
          username: username,
          password: password,
          target: "$base/gsapp/sys/yjsemaphome/portal/index.do",
          sliderCaptcha: sliderCaptcha,
        );
      }
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

  Future<void> useApp(String name) async {
    String toPost = "$base/gsapp/sys/$name/*default/index.do?"
        "THEME=blue&EMAP_LANG=zh&min=1&_yhz=${user["roleId"]}";
    var responseCode =
        await dioYjspt.post(toPost).then((value) => value.statusCode);
    if (responseCode == 302) {
      await loginYjspt(
        username: user["idsAccount"]!,
        password: user["idsPassword"]!,
      );
    }
  }

  Future<List<Subject>> getExam() async {
    String semester = "";
    await useApp("wdksapp");

    /// Get semester information.
    /// Hard to use, I would rather do it by myself.
    /// Nope, I need to choose~
    developer.log("Seek for the semesters", name: "getExam");
    semester = await dioYjspt
        .post(
          "https://yjspt.xidian.edu.cn/gsapp/sys/wdksapp/modules/ksxxck/getXnxqList.do",
        )
        .then(
          (value) => value.data["datas"][0]["DM"],
        );

    /// wdksap 我的考试安排
    developer.log("My exam arrangemet $semester", name: "getExam");
    var data = await dioYjspt.post(
      "https://yjspt.xidian.edu.cn/gsapp/sys/wdksapp/modules/ksxxck/wdksxxcx.do",
      queryParameters: {
        "querySetting": '''[
          {"name":"XNXQDM","caption":"学年学期代码","builder":"equal","linkOpt":"AND","value":"$semester"},
          {"name":"SFFBKSAP","caption":"是否发布考试安排","builder":"equal","linkOpt":"AND","value":"1"},
          {"name":"XH","caption":"学号","builder":"equal","linkOpt":"AND","value":"${user["idsAccount"]}"},
          {"name":"KSAPWID","caption":"考试安排WID","builder":"notEqual","linkOpt":"AND","value":null}]''',
        "pageSize": 1000,
        "pageNumber": 1,
      },
    ).then((value) => value.data["datas"]["wdksxxcx"]["rows"]);

    List<Subject> toReturn = [];

    if (data != null) {
      for (var i in data) {
        toReturn.add(Subject(
          subject: i["KCMC"],
          type: i["KSLXDM_DISPLAY"],
          timeStr: i["KSSJMS"],
          startTimeStr: i["KSKSSJ"],
          stopTimeStr: i["KSJSSJ"],
          place: i["JASMC"],
          roomId: i["KCBH"],
        ));
      }
    }

    return toReturn;
  }

  Future<List<Score>> getScore() async {
    List<Score> toReturn = [];

    /// Get information here. resultCode==00000 is successful.
    developer.log("Check whether the score has fetched in this session.",
        name: "Yjspt getScore");

    /// Get all scores here.
    developer.log("Start getting the score.", name: "Yjspt getScore");

    developer.log("Ready to login the system.", name: "Yjspt getScore");
    await useApp("wdcjapp");

    developer.log("Getting the score data.", name: "Yjspt getScore");
    var getData = await dio.post(
      "https://yjspt.xidian.edu.cn/gsapp/sys/wdcjapp/modules/wdcj/xscjcx.do",
      data: {
        "querySetting": [],
        'pageSize': 1000,
        'pageNumber': 1,
      },
    ).then((value) => value.data);
    developer.log("Dealing the score data.", name: "Yjspt getScore");
    if (getData["datas"]["xscjcx"]["extParams"]["code"] != 1) {
      throw GetScoreFailedException(
          getData['datas']['xscjcx']["extParams"]["msg"]);
    }
    int j = 0;
    for (var i in getData['datas']['xscjcx']['rows']) {
      toReturn.add(Score(
        mark: j,
        name: "${i["KCMC"]}",
        score: i["DYBFZCJ"],
        year: i["XNXQDM_DISPLAY"],
        credit: i["XF"],
        status: i["KCLBMC"],
        how: int.parse(i["CJFZDM"]),
        level: i["CJFZDM"] != "0" ? i["CJXSZ"] : null,
        isPassed: i["SFJG"] ?? -1,
        isNoNeedStudy: i["BZSM"] == "免修" ? true : false,
      ));
      j++;
    }
    return toReturn;
  }

  Future<ClassTableData> _getClasstableFromWeb() async {
    DateTime now = DateTime.now();
    Map<String, dynamic> qResult = {};
    developer.log("Login the system.", name: "Yjspt getClasstable");
    await useApp("wdkbapp");

    developer.log("Fetch the semester information.",
        name: "Yjspt getClasstable");
    String semesterCode = await dioYjspt
        .post(
          "https://yjspt.xidian.edu.cn/gsapp/sys/wdkbapp/modules/xskcb/kfdxnxqcx.do",
        )
        .then((value) => value.data['datas']['kfdxnxqcx']['rows'][0]['XNXQDM']);
    if (user["currentSemester"] != semesterCode) {
      user["currentSemester"] = semesterCode;
    }

    developer.log("Fetch the day the semester begin.",
        name: "Yjspt getClasstable");
    var currentWeek = await dioYjspt.post(
      'https://yjspt.xidian.edu.cn/gsapp/sys/yjsemaphome/portal/queryRcap.do',
      data: {'day': Jiffy.parseFromDateTime(now).format(pattern: "yyyyMMdd")},
    ).then((value) => value.data);

    developer.log(
      "${Jiffy.parseFromDateTime(now).format(pattern: "yyyyMMdd")}  $currentWeek, fetching...",
      name: "Yjspt getClasstable",
    );

    // [termStartDay] set to empty means no classtable avaliable...
    if (currentWeek["xnxq"] == null) {
      return ClassTableData(
        semesterCode: semesterCode,
        termStartDay: "",
      );
    }

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

    qResult = await dioYjspt.post(
      'https://yjspt.xidian.edu.cn/gsapp/sys/wdkbapp/modules/xskcb/xspkjgcx.do',
      data: {'XNXQDM': semesterCode, "*order": "-ZCBH"},
    ).then((value) => value.data['datas']['xspkjgcx']);
    if (qResult['extParams']['code'] != 1) {
      throw Exception("${qResult['extParams']['msg']}在已安排课程");
    }

    developer.log("Caching...", name: "Yjspt getClasstable");
    qResult["semesterCode"] = semesterCode;
    qResult["termStartDay"] = termStartDay;
    return _simplifyData(qResult);
  }

  Future<ClassTableData> getClasstable({
    bool isForce = false,
  }) async {
    developer.log("Check whether the classtable has fetched.",
        name: "Yjspt getClasstable");

    developer.log("Start fetching the classtable.",
        name: "Yjspt getClasstable");
    Directory destination =
        Directory("${supportPath.path}/org.superbart.watermeter_postgraduate");
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
        var qResult = await _getClasstableFromWeb();
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

  Future<void> getInformation() async {
    developer.log("Ready to get the user information.",
        name: "Yjspt getInformation");
    await useApp("wdxj");

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
  }
}

class GetScoreFailedException implements Exception {
  final String msg;
  const GetScoreFailedException(this.msg);

  @override
  String toString() => msg;
}

class NotFinishLoginException implements Exception {}

ClassTableData _simplifyData(Map<String, dynamic> qResult) {
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
