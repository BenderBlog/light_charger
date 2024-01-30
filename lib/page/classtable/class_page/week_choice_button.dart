// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter_postgraduate/page/classtable/classtable_constant.dart';
import 'package:watermeter_postgraduate/page/classtable/classtable_state.dart';

/// This is the button of the toprow
class WeekChoiceButton extends StatefulWidget {
  final int index;
  final void Function() onTap;
  const WeekChoiceButton({
    super.key,
    required this.index,
    required this.onTap,
  });

  @override
  State<WeekChoiceButton> createState() => _WeekChoiceButtonState();
}

class _WeekChoiceButtonState extends State<WeekChoiceButton> {
  late ClassTableWidgetState classTableState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    classTableState = ClassTableState.of(context)!.controllers;
  }

  /// [buttonInformaion] shows the botton's [index] and the overview.
  ///
  /// A [index] is required to render the botton for the week.
  Widget buttonInformaion({required int index}) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AutoSizeText(
            "第${index + 1}周",
            style: TextStyle(
              fontWeight: index == classTableState.currentWeek
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
            maxLines: 1,
            group: AutoSizeGroup(),
          ),

          /// These code are used to render the overview of the week,
          /// as long as the height of the page is over 500.
          if (MediaQuery.sizeOf(context).height >= 500)
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 5,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (int i = 0; i < 10; i += 2)
                  for (int day = 0; day < 5; ++day)
                    Dot(
                      isOccupied: !classTableState.pretendLayout[index][day][i]
                          .contains(-1),
                    )
              ],
            )
                .paddingDirectional(
                  start: 6,
                  top: 4,
                  end: 6,
                  bottom: 2,
                )
                .expanded(),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: weekButtonHorizontalPadding,
      ),
      child: SizedBox(
        width: weekButtonWidth,
        child: Card(
          color: Theme.of(context).primaryColor.withOpacity(
                classTableState.chosenWeek == widget.index ? 0.3 : 0.0,
              ),
          elevation: 0.0,
          child: InkWell(
            /// The following themes are the same as the Material 3 Card Radius.
            borderRadius: const BorderRadius.all(Radius.circular(12.0)),
            splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
            highlightColor: Theme.of(context).primaryColor.withOpacity(0.3),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: buttonInformaion(index: widget.index),
            ),
          ),
        ),
      ),
    );
  }
}

/// The dot of the overview, [isOccupied] is used to identify the opacity of the dot.
class Dot extends StatelessWidget {
  final bool isOccupied;
  const Dot({
    super.key,
    required this.isOccupied,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        color: Theme.of(context).colorScheme.primary.withOpacity(
              isOccupied ? 1 : 0.25,
            ),
      ),
    );
  }
}
