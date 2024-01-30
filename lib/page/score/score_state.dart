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

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:watermeter_postgraduate/model/xidian_ids/score.dart';
import 'package:watermeter_postgraduate/page/score/score_statics.dart';
import 'package:watermeter_postgraduate/repository/preference.dart';

class ScoreState extends InheritedWidget {
  /// Static data.
  final List<Score> scoreTable;
  final Set<String> semester;
  final Set<String> statuses;
  final Set<String> unPassedSet;

  /// Parent's Buildcontext.
  final BuildContext context;

  /// Changeable state.
  final ScoreWidgetState controllers;

  static const notFinish = "(成绩没登完)";
  static const notCoreClassType = "公共任选";
  static const notFirstTime = "(非初修)";

  /// Exclude these from counting avgs
  /// 1. Teacher have not finish uploading scores
  /// 2. Have score below 60 but passed.
  /// 3. Not first time learning this, but still failed.
  bool _evalCount(Score eval) => !(eval.name.contains(notFinish) ||
      (eval.score < 60 && !unPassedSet.contains(eval.name)) ||
      (eval.name.contains(notFirstTime) && eval.score < 60));

  double evalCredit(bool isAll) {
    double totalCredit = 0.0;
    for (var i = 0; i < controllers.isSelected.length; ++i) {
      if (((controllers.isSelected[i] == true && isAll == false) ||
              isAll == true) &&
          _evalCount(scoreTable[i])) {
        totalCredit += scoreTable[i].credit;
      }
    }
    return totalCredit;
  }

  double evalAvg(bool isAll) {
    double totalScore = 0.0;
    double totalCredit = evalCredit(isAll);
    for (var i = 0; i < controllers.isSelected.length; ++i) {
      if (((controllers.isSelected[i] == true && isAll == false) ||
              isAll == true) &&
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
    if (controllers.chosenSemester != "") {
      whatever.removeWhere(
        (element) => element.year != controllers.chosenSemester,
      );
    }
    if (controllers.chosenStatus != "") {
      whatever.removeWhere(
        (element) => element.status != controllers.chosenStatus,
      );
    }
    whatever.removeWhere(
      (element) => !element.name.contains(controllers.search),
    );
    return whatever;
  }

  List<Score> get getSelectedScoreList => List.from(scoreTable)
    ..removeWhere((element) => !controllers.isSelected[element.mark]);

  List<Score> get selectedScoreList {
    List<Score> whatever = List.from(getSelectedScoreList);
    if (controllers.chosenSemesterInScoreChoice != "") {
      whatever.removeWhere(
        (element) => element.year != controllers.chosenSemesterInScoreChoice,
      );
    }
    if (controllers.chosenStatusInScoreChoice != "") {
      whatever.removeWhere(
        (element) => element.status != controllers.chosenStatusInScoreChoice,
      );
    }
    whatever.removeWhere(
      (element) => !element.name.contains(controllers.searchInScoreChoice),
    );
    return whatever;
  }

  String get unPassed => unPassedSet.isEmpty ? "没有" : unPassedSet.join(",");

  String get bottomInfo =>
      "目前选中科目 ${getSelectedScoreList.length}  总计学分 ${evalCredit(false).toStringAsFixed(2)}\n"
      "均分 ${evalAvg(false).toStringAsFixed(2)}";

  factory ScoreState.init({
    required List<Score> scoreTable,
    required Widget child,
    required BuildContext context,
  }) {
    Set<String> semester = {for (var i in scoreTable) i.year};
    Set<String> statuses = {for (var i in scoreTable) i.status};
    Set<String> unPassedSet = {};

    for (var i in scoreTable) {
      /// The score has not uploaded completely
      if (i.isPassed == -1) {
        i.name += notFinish;
        continue;
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
    }
    return ScoreState._(
      scoreTable: scoreTable,
      controllers: ScoreWidgetState(
        isSelected: List<bool>.generate(
          scoreTable.length,
          (int index) {
            if (toBeCounted.contains(scoreTable[index].status) ||
                toBeCounted.contains(scoreTable[index].name)) {
              return !(scoreTable[index].status == "英语公共课" &&
                  scoreTable[index].isNoNeedStudy == true);
            }
            return false;
          },
        ),
        chosenSemester: user["currentSemester"]!,
      ),
      semester: semester,
      statuses: statuses,
      unPassedSet: unPassedSet,
      context: context,
      child: child,
    );
  }

  const ScoreState._({
    required super.child,
    required this.scoreTable,
    required this.controllers,
    required this.semester,
    required this.statuses,
    required this.unPassedSet,
    required this.context,
  });

  void setScoreChoiceMod() {
    controllers.isSelectMod = !controllers.isSelectMod;
    controllers.notifyListeners();
  }

  void setScoreChoiceFromIndex(int index) {
    controllers.isSelected[index] = !controllers.isSelected[index];
    controllers.notifyListeners();
  }

  void setScoreChoiceState(ChoiceState state) {
    for (var stuff in toShow) {
      if (state == ChoiceState.all) {
        controllers.isSelected[stuff.mark] = true;
      } else if (state == ChoiceState.none) {
        controllers.isSelected[stuff.mark] = false;
      } else {
        bool toBeGiven = false;
        for (var i in toBeCounted) {
          if (stuff.name.contains(i) || stuff.status.contains(i)) {
            toBeGiven = stuff.status != "英语公共课" || stuff.isNoNeedStudy == false;
          }
        }
        controllers.isSelected[stuff.mark] = toBeGiven;
      }
    }
    controllers.notifyListeners();
  }

  set search(String text) {
    controllers.search = text;
    controllers.notifyListeners();
  }

  set chosenSemester(String str) {
    controllers.chosenSemester = str;
    controllers.notifyListeners();
  }

  set chosenStatus(String str) {
    controllers.chosenStatus = str;
    controllers.notifyListeners();
  }

  set searchInScoreChoice(String text) {
    controllers.searchInScoreChoice = text;
    controllers.notifyListeners();
  }

  set chosenSemesterInScoreChoice(String str) {
    controllers.chosenSemesterInScoreChoice = str;
    controllers.notifyListeners();
  }

  set chosenStatusInScoreChoice(String str) {
    controllers.chosenStatusInScoreChoice = str;
    controllers.notifyListeners();
  }

  static ScoreState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ScoreState>();
  }

  @override
  bool updateShouldNotify(covariant ScoreState oldWidget) {
    ScoreWidgetState newState = controllers;
    ScoreWidgetState oldState = oldWidget.controllers;

    return (!listEquals(oldState.isSelected, newState.isSelected) ||
        oldState.chosenSemester != newState.chosenSemester ||
        oldState.chosenStatus != newState.chosenStatus ||
        oldState.chosenSemesterInScoreChoice !=
            newState.chosenSemesterInScoreChoice ||
        oldState.chosenStatusInScoreChoice !=
            newState.chosenStatusInScoreChoice ||
        oldState.search != newState.search ||
        oldState.searchInScoreChoice != newState.chosenSemesterInScoreChoice);
  }
}

class ScoreWidgetState extends ChangeNotifier {
  /// Is score is selected to count.
  List<bool> isSelected;

  /// Is select mod?
  bool isSelectMod = false;

  /// Empty means all semester.
  String chosenSemester = "";

  /// Empty means all status.
  String chosenStatus = "";

  /// Empty means all semester, especially in score choice window.
  String chosenSemesterInScoreChoice = "";

  /// Empty means all status, especially in score choice window.
  String chosenStatusInScoreChoice = "";

  /// Search parameter
  String search = "";
  String searchInScoreChoice = "";

  ScoreWidgetState({
    required this.isSelected,
    required this.chosenSemester,
  });

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
