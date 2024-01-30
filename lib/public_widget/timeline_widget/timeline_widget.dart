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
import 'package:watermeter_postgraduate/public_widget/timeline_widget/flow_event_row.dart';
import 'package:watermeter_postgraduate/public_widget/public_widget.dart';

class TimelineWidget extends StatelessWidget {
  final List<bool> isTitle;
  final List<Widget> children;
  const TimelineWidget({
    super.key,
    required this.isTitle,
    required this.children,
  }) : assert(isTitle.length == children.length);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: sheetMaxWidth),
        child: Stack(
          alignment: AlignmentDirectional.center,
          fit: StackFit.loose,
          children: <Widget>[
            Positioned(
              left: isPhone(context) ? 14 : 20,
              top: 16,
              bottom: 16,
              child: const VerticalDivider(
                width: 1,
              ),
            ),
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: children.length,
              itemBuilder: (BuildContext context, int index) {
                return FlowEventRow(
                  isTitle: isTitle[index],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: children[index],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
