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
import 'package:watermeter_postgraduate/model/xidian_ids/score.dart';
import 'package:watermeter_postgraduate/repository/xidian_ids/yjspt_session.dart';

/// 考试成绩 4768574631264620
class ScoreSession extends YjsptSession {
  Future<List<Score>> get() async {
    List<Score> toReturn = [];

    /// Get information here. resultCode==00000 is successful.
    developer.log("Check whether the score has fetched in this session.",
        name: "Yjspt getScore");

    /// Get all scores here.
    developer.log("Start getting the score.", name: "Yjspt getScore");

    developer.log("Ready to login the system.", name: "Yjspt getScore");
    var firstPost = await useApp("wdcjapp");
    await dioYjspt.get(firstPost);

    developer.log("Getting the score data.", name: "Yjspt getScore");
    var getData = await dioYjspt.post(
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
}

class GetScoreFailedException implements Exception {
  final String msg;
  const GetScoreFailedException(this.msg);

  @override
  String toString() => msg;
}
