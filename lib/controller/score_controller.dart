import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:watermeter_postgraduate/model/user.dart';
import 'dart:developer' as developer;
import 'package:watermeter_postgraduate/model/xidian_ids/score.dart';
import 'package:watermeter_postgraduate/repository/xidian_ids/score_session.dart';

class ScoreController extends GetxController {
  bool isGet = false;
  String? error;
  late String currentSemester;
  late List<Score> scoreTable;
  late List<bool> isSelected;

  bool isSelectMod = false;
  Set<String> semester = {};
  Set<String> statuses = {};
  Set<String> unPassedSet = {};
  double notCoreClass = 0.0;

  static const notFinish = "(成绩没登完)";
  static const notCoreClassType = "公共任选";
  static const notFirstTime = "(非初修)";

  /// Empty means all semester.
  String chosenSemester = "";

  /// Empty means all status.
  String chosenStatus = "";

  /// Exclude these from counting avgs
  /// 1. Teacher have not finish uploading scores
  /// 2. Have score below 60 but passed.
  /// 3. Not first time learning this, but still failed.
  bool _evalCount(Score eval) => !(eval.name.contains(notFinish) ||
      (eval.score < 60 && !unPassedSet.contains(eval.name)) ||
      (eval.name.contains(notFirstTime) && eval.score < 60));

  double evalCredit(bool isAll) {
    double totalCredit = 0.0;
    for (var i = 0; i < isSelected.length; ++i) {
      if (((isSelected[i] == true && isAll == false) || isAll == true) &&
          _evalCount(scoreTable[i])) {
        totalCredit += scoreTable[i].credit;
      }
    }
    return totalCredit;
  }

  /// [isGPA] true for the GPA, false for the avgScore
  double evalAvg(bool isAll) {
    double totalScore = 0.0;
    double totalCredit = evalCredit(isAll);
    for (var i = 0; i < isSelected.length; ++i) {
      if (((isSelected[i] == true && isAll == false) || isAll == true) &&
          _evalCount(scoreTable[i])) {
        totalScore += scoreTable[i].score * scoreTable[i].credit;
      }
    }
    return totalCredit != 0 ? totalScore / totalCredit : 0.0;
  }

  List<Score> get toShow {
    /// If I write "whatever = scores.scoreTable", every change I made to "whatever"
    /// also applies to scores.scoreTable. Since reference whatsoever.
    List<Score> whatever = List.from(scoreTable);
    if (chosenSemester != "") {
      whatever.removeWhere((element) => element.year != chosenSemester);
    }
    if (chosenStatus != "") {
      whatever.removeWhere((element) => element.status != chosenStatus);
    }
    return whatever;
  }

  String get unPassed {
    if (unPassedSet.isEmpty) {
      return "没有";
    }
    return unPassedSet.join(",");
  }

  @override
  void onInit() {
    currentSemester = user["currentSemester"]!;
    super.onInit();
  }

  @override
  void onReady() async {
    get(semesterStr: currentSemester);
    update();
  }

  Future<void> get({String? semesterStr}) async {
    isGet = false;
    error = "正在加载";
    try {
      /// Init scorefile
      scoreTable = await ScoreFile().get();
      isSelected = List<bool>.generate(scoreTable.length, (int index) => false);
      semester = {for (var i in scoreTable) i.year};
      statuses = {for (var i in scoreTable) i.status};

      for (var i in scoreTable) {
        /// The score has not uploaded completely
        if (i.isPassed == -1) {
          i.name += notFinish;
          continue;
        }

        /// Passed notCoreClass credit. Meet graduate requirement.
        if (i.status == notCoreClassType && i.isPassed == 1) {
          notCoreClass += i.credit;
        }

        if (i.isPassed != 1 &&
            i.isPassed != -1 &&
            !unPassedSet.contains(i.name)) {
          unPassedSet.add(i.name);
          continue;
        }

        /// Whatever score is, if not passed in the first time, count as 60.
        /// Please take a note of it.
        if (unPassedSet.contains(i.name)) {
          if (i.isPassed == 1) {
            i.score = 60;
            unPassedSet.remove(i.name);
          }
          i.name += notFirstTime;
        }

        /// Pre-choice some course.
        if (toBeCounted.contains(i.status) || toBeCounted.contains(i.name)) {
          if (i.status == "英语公共课" && i.isNoNeedStudy == true) {
            isSelected[scoreTable.indexOf(i)] = false;
          } else {
            isSelected[scoreTable.indexOf(i)] = true;
          }
        }
      }

      isGet = true;
      error = null;
      chosenSemester = semester.last;
    } on DioException catch (e, s) {
      developer.log(
        "Network exception: ${e.message}\nStack: $s",
        name: "ScoreController",
      );
      error = "网络错误，可能是没联网，可能是学校服务器出现了故障:-P";
    } on GetScoreFailedException catch (e) {
      developer.log("没有获取到成绩：$e", name: "ScoreSession");
      error = "没有获取到成绩：$e";
    } catch (e) {
      developer.log("未知故障：$e", name: "ScoreSession");
      error = e.toString();
    }
    update();
  }
}
