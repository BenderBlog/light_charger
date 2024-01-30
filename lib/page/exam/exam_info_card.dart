// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter_postgraduate/model/xidian_ids/exam.dart';
import 'package:watermeter_postgraduate/public_widget/public_widget.dart';
import 'package:watermeter_postgraduate/public_widget/rex_card.dart';

class ExamInfoCard extends StatelessWidget {
  final Subject? toUse;
  final String? title;

  const ExamInfoCard({super.key, this.toUse, this.title})
      : assert(toUse != null || title != null);

  @override
  Widget build(BuildContext context) {
    return toUse != null
        ? ReXCard(
            title: Text(toUse!.subject),
            remaining: [
              ReXCardRemaining(toUse!.type),
            ],
            bottomRow: Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: [
                informationWithIcon(
                  Icons.access_time_filled_rounded,
                  toUse!.timeStr,
                  context,
                ),
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    informationWithIcon(
                      Icons.room,
                      toUse!.place,
                      context,
                    ).flexible(),
                    informationWithIcon(
                      Icons.code,
                      toUse!.roomId,
                      context,
                    ).flexible(),
                  ],
                ),
              ],
            ),
          )
        : Text(
            title!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ).padding(all: 14).card(
              margin: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              elevation: 0,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            );
  }
}
