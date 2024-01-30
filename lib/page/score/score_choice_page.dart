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

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter_postgraduate/public_widget/column_choose_dialog.dart';
import 'package:watermeter_postgraduate/page/score/score_info_card.dart';
import 'package:watermeter_postgraduate/page/score/score_state.dart';
import 'package:watermeter_postgraduate/page/score/score_statics.dart';

class ScoreChoicePage extends StatefulWidget {
  const ScoreChoicePage({super.key});

  @override
  State<ScoreChoicePage> createState() => _ScoreChoicePageState();
}

class _ScoreChoicePageState extends State<ScoreChoicePage> {
  late ScoreState state;
  late TextEditingController text;

  @override
  void didChangeDependencies() {
    state = ScoreState.of(context)!;
    state.controllers.addListener(() => mounted ? setState(() {}) : null);
    text = TextEditingController.fromValue(
      TextEditingValue(text: state.controllers.searchInScoreChoice),
    );
    super.didChangeDependencies();
  }

  Future<void> scoreInfoDialog(context) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('小总结'),
          content: Text(
            "所有科目的均分：${state.evalAvg(true).toStringAsFixed(2)}\n"
            "所有科目的学分：${state.evalCredit(true).toStringAsFixed(2)}\n"
            "未通过科目：${state.unPassed}\n"
            "本程序提供的数据仅供参考，开发者对其准确性不负责",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("确定"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Platform.isIOS || Platform.isMacOS
                ? Icons.arrow_back_ios_new
                : Icons.arrow_back,
          ),
          onPressed: Navigator.of(context).pop,
        ),
        title: const Text("成绩单"),
        actions: [
          IconButton(
            onPressed: () => scoreInfoDialog(context),
            icon: const Icon(Icons.info),
          ),
        ],
      ),
      body: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.start,
            children: [
              TextField(
                style: const TextStyle(fontSize: 14),
                controller: text,
                autofocus: false,
                decoration: InputDecoration(
                  isDense: true,
                  fillColor: Colors.grey.withOpacity(0.2),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  hintText: "搜索成绩记录",
                  hintStyle: const TextStyle(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (String text) => state.searchInScoreChoice = text,
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                ),
                onPressed: () async {
                  await showDialog<int>(
                    context: context,
                    builder: (context) => ColumnChooseDialog(
                      chooseList: ["所有学期", ...state.semester],
                    ),
                  ).then((value) {
                    if (value != null) {
                      state.chosenSemesterInScoreChoice =
                          ["", ...state.semester].toList()[value];
                    }
                  });
                },
                child: Text(
                  "学期 ${state.controllers.chosenSemesterInScoreChoice == "" ? "所有学期" : state.controllers.chosenSemesterInScoreChoice}",
                ),
              ).padding(right: 4),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                ),
                onPressed: () async {
                  await showDialog<int>(
                    context: context,
                    builder: (context) => ColumnChooseDialog(
                      chooseList: ["所有类型", ...state.statuses].toList(),
                    ),
                  ).then((value) {
                    if (value != null) {
                      state.chosenStatusInScoreChoice =
                          ["", ...state.statuses].toList()[value];
                    }
                  });
                },
                child: Text(
                  "类型 ${state.controllers.chosenStatusInScoreChoice == "" ? "所有类型" : state.controllers.chosenStatusInScoreChoice}",
                ),
              ),
            ],
          )
              .padding(horizontal: 14, top: 8, bottom: 6)
              .constrained(maxWidth: 480),
          state.selectedScoreList.isNotEmpty
              ? AlignedGridView.count(
                  shrinkWrap: true,
                  itemCount: state.selectedScoreList.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  crossAxisCount: MediaQuery.sizeOf(context).width ~/ cardWidth,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  itemBuilder: (context, index) => ScoreInfoCard(
                    mark: state.selectedScoreList[index].mark,
                    isScoreChoice: true,
                  ),
                ).expanded()
              : const Column(
                  children: [
                    Icon(Icons.inbox_rounded),
                    Text("没有选择该学期的课程计入均分计算"),
                  ],
                ).center().expanded(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              state.bottomInfo,
              textScaler: const TextScaler.linear(1.2),
            ),
          ],
        ),
      ),
    );
  }
}
