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
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter_postgraduate/repository/network_session.dart';
import 'dart:developer' as developer;
import 'package:watermeter_postgraduate/model/xidian_ids/exam.dart';
import 'package:watermeter_postgraduate/repository/yjspt_session.dart';

enum ExamStatus {
  cache,
  fetching,
  fetched,
  error,
  none,
}

class ExamController extends GetxController {
  static const examDataCacheName = "exam.json";

  ExamStatus status = ExamStatus.none;
  String error = "";
  List<String> semesters = [];
  late List<Subject> subjects;
  late File file;
  Jiffy now = Jiffy.now();

  List<Subject> get isFinished {
    List<Subject> isFinished = List.from(subjects);
    isFinished.removeWhere(
      (element) => element.startTime.isAfter(now),
    );
    return isFinished;
  }

  List<Subject> get isNotFinished {
    List<Subject> isNotFinished = List.from(subjects);
    isNotFinished.removeWhere(
      (element) => element.startTime.isSameOrBefore(now),
    );
    return isNotFinished
      ..sort(
        (a, b) =>
            a.startTime.microsecondsSinceEpoch -
            b.startTime.microsecondsSinceEpoch,
      );
  }

  @override
  void onInit() {
    super.onInit();
    developer.log(
      "Path at ${supportPath.path}.",
      name: "[ExamController][onInit]",
    );
    file = File("${supportPath.path}/$examDataCacheName");
    bool isExist = file.existsSync();

    if (isExist) {
      developer.log(
        "Init from cache.",
        name: "[ExamController][onInit]",
      );
      subjects = (jsonDecode(file.readAsStringSync()) as List)
          .map((e) => Subject.fromJson(e))
          .toList();
      status = ExamStatus.cache;
    } else {
      subjects = [];
    }
  }

  @override
  void onReady() async {
    super.onReady();
    get().then((value) => update());
  }

  Future<void> get() async {
    ExamStatus previous = status;
    developer.log(
      "Fetching data from Internet.",
      name: "[ExamController][get]",
    );
    try {
      now = Jiffy.now();
      status = ExamStatus.fetching;
      subjects = await ses.getExam();
      status = ExamStatus.fetched;
      error = "";
    } on DioException catch (e, s) {
      developer.log(
        "Network exception: ${e.message}\nStack: $s",
        name: "ScoreController",
      );
      error = "网络错误，可能是没联网，可能是学校服务器出现了故障:-P";
    } catch (e, s) {
      developer.log(
        "Other exception: $e\nStack: $s",
        name: "ScoreController",
      );
      error = "未知错误，感兴趣的话，请接到电脑 adb 查看日志。$e";
    } finally {
      if (status == ExamStatus.fetched) {
        developer.log(
          "Store to cache.",
          name: "[ExamController][get]",
        );
        file.writeAsStringSync(jsonEncode(subjects));
      } else if (previous == ExamStatus.cache) {
        status = ExamStatus.cache;
      } else {
        status = ExamStatus.error;
      }
    }
    update();
  }
}
