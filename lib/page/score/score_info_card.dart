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

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter_postgraduate/public_widget/rex_card.dart';
import 'package:watermeter_postgraduate/page/score/score_state.dart';

class ScoreInfoCard extends StatefulWidget {
  // Mark is a variable in ScoreInfo class
  final int mark;
  // Is in score choice window
  final bool isScoreChoice;
  const ScoreInfoCard({
    super.key,
    required this.mark,
    this.isScoreChoice = false,
  });

  @override
  State<ScoreInfoCard> createState() => _ScoreInfoCardState();
}

class _ScoreInfoCardState extends State<ScoreInfoCard> {
  late ScoreState c;

  double get cardOpacity {
    if ((c.controllers.isSelectMod || widget.isScoreChoice) &&
        !c.controllers.isSelected[widget.mark]) {
      return 0.38;
    } else {
      return 1;
    }
  }

  @override
  void didChangeDependencies() {
    c = ScoreState.of(context)!;
    c.controllers.addListener(() => mounted ? setState(() {}) : null);
    super.didChangeDependencies();
  }

  bool _isVisible = true;
  Duration get _duration => Duration(milliseconds: _isVisible ? 0 : 150);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        /// Score choice window
        if (widget.isScoreChoice) {
          setState(() => _isVisible = false);
          Future.delayed(_duration).then((value) {
            c.setScoreChoiceFromIndex(widget.mark);
            setState(() => _isVisible = true);
          });
        } else if (c.controllers.isSelectMod) {
          c.setScoreChoiceFromIndex(widget.mark);
        }
      },
      child: AnimatedOpacity(
        opacity: _isVisible ? 1.0 : 0.0,
        duration: _duration,
        child: ReXCard(
          opacity: cardOpacity,
          title: Text.rich(TextSpan(children: [
            TextSpan(text: c.scoreTable[widget.mark].name),
          ])),
          remaining: [
            ReXCardRemaining(c.scoreTable[widget.mark].status),
          ],
          bottomRow: Row(
            children: [
              Text(
                "学分 ${c.scoreTable[widget.mark].credit}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ).expanded(flex: 3),
              Text(
                "成绩 "
                "${c.toShow[widget.mark].how == 1 || c.toShow[widget.mark].how == 2 ? c.toShow[widget.mark].level : c.toShow[widget.mark].score}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ).expanded(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
