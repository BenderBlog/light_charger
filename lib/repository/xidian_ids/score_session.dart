/*
The score window source.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO watermeter_postgraduate SOURCE CODE
if you want to use.

Thanks xidian-script and libxdauth!
*/

import 'dart:developer' as developer;
import 'package:watermeter_postgraduate/model/xidian_ids/score.dart';
import 'package:watermeter_postgraduate/repository/xidian_ids/yjspt_session.dart';

/// 考试成绩 4768574631264620
class ScoreFile extends YjsptSession {
  Future<List<Score>> get() async {
    List<Score> toReturn = [];

    /// Get information here. resultCode==00000 is successful.
    developer.log("Check whether the score has fetched in this session.",
        name: "Yjspt getScore");

    /// Get all scores here.
    developer.log("Start getting the score.", name: "Yjspt getScore");

    developer.log("Ready to login the system.", name: "Yjspt getScore");
    var firstPost = await useApp("wdcjapp");
    await dio.get(firstPost);

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
      throw getData.toString();
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
      /* //Unable to work.
      if (i["DJCJLXDM"] == "100") {
        try {
          var anotherResponse = await dio.post(
              "https://Yjspt.xidian.edu.cn/jwapp/sys/cjcx/modules/cjcx/cxkxkgcxlrcj.do",
              data: {
                "JXBID": scoreTable.last.classID,
                'XH': user["idsAccount"],
                'XNXQDM':scoreTable.last.year,
                'CKLY': "1",
              },
            options: Options(
              headers: {
                "DNT": "1",
                "Referer": firstPost
              },
            )
          );
          //print(anotherResponse.data);
        } on DioError catch (e) {
          //print("WTF:" + e.toString());
          break;
        }
      }*/
    }
    return toReturn;
  }
}
