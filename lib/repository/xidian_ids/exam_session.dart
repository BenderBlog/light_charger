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

import 'dart:developer' as developer;
import 'package:watermeter_postgraduate/model/xidian_ids/exam.dart';
import 'package:watermeter_postgraduate/repository/preference.dart';
import 'package:watermeter_postgraduate/repository/xidian_ids/yjspt_session.dart';

/// 考试安排 4768687067472349
class ExamFile extends YjsptSession {
  Future<List<Subject>> get() async {
    String semester = "";
    var firstPost = await useApp("wdksapp");
    await dioYjspt.get(firstPost);

    /// Get semester information.
    /// Hard to use, I would rather do it by myself.
    /// Nope, I need to choose~
    developer.log("Seek for the semesters", name: "getExam");
    semester = await dioYjspt
        .post(
          "https://yjspt.xidian.edu.cn/gsapp/sys/wdksapp/modules/ksxxck/getXnxqList.do",
        )
        .then(
          (value) => value.data["datas"]["semester"][0]["DM"],
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

    if (data["rows"] != null) {
      for (var i in data) {
        toReturn.add(Subject(
          subject: i["KCMC"],
          typeStr: i["KSLXDM_DISPLAY"],
          time: i["KSSJMS"],
          place: i["JASMC"],
          // 考场编号
          roomId: i["KCBH"],
        ));
      }
    }

    return toReturn;
  }
}
