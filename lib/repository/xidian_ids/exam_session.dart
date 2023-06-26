/*
The exam source.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO watermeter_postgraduate SOURCE CODE
if you want to use.

Thanks xidian-script and libxdauth!
*/

import 'dart:developer' as developer;
import 'package:watermeter_postgraduate/model/user.dart';
import 'package:watermeter_postgraduate/repository/xidian_ids/yjspt_session.dart';

/// 考试安排 4768687067472349
class ExamFile extends YjsptSession {
  Future<Map<String, dynamic>> get({
    String? semester,
  }) async {
    Map<String, dynamic> qResult = {};

    var firstPost = await useApp("wdksapp");
    await dio.get(firstPost);

    /// Get semester information.
    /// Hard to use, I would rather do it by myself.
    /// Nope, I need to choose~
    if (semester == null) {
      developer.log("Seek for the semesters", name: "getExam");
      var whatever = await dio.post(
        "https://yjspt.xidian.edu.cn/gsapp/sys/wdksapp/modules/ksxxck/getXnxqList.do",
      );
      qResult["semester"] = whatever.data["datas"];
    }

    /// wdksap 我的考试安排
    developer.log(
        "My exam arrangemet ${semester ?? qResult["semester"][0]["DM"]}",
        name: "getExam");
    var data = await dio.post(
      "https://yjspt.xidian.edu.cn/gsapp/sys/wdksapp/modules/ksxxck/wdksxxcx.do",
      queryParameters: {
        "querySetting": '''[
          {"name":"XNXQDM","caption":"学年学期代码","builder":"equal","linkOpt":"AND","value":"${semester ?? qResult["semester"][0]["DM"]}"},
          {"name":"SFFBKSAP","caption":"是否发布考试安排","builder":"equal","linkOpt":"AND","value":"1"},
          {"name":"XH","caption":"学号","builder":"equal","linkOpt":"AND","value":"${user["idsAccount"]}"},
          {"name":"KSAPWID","caption":"考试安排WID","builder":"notEqual","linkOpt":"AND","value":null}]''',
        "pageSize": 1000,
        "pageNumber": 1,
      },
    ).then((value) => value.data["datas"]["wdksxxcx"]);
    qResult["subjects"] = data["rows"];

    return qResult;
  }
}
