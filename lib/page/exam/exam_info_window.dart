// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Exam Infomation Interface.

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watermeter_postgraduate/controller/exam_controller.dart';
import 'package:watermeter_postgraduate/page/exam/exam_info_card.dart';
import 'package:watermeter_postgraduate/public_widget/timeline_widget/timeline_title.dart';
import 'package:watermeter_postgraduate/public_widget/timeline_widget/timeline_widget.dart';

class ExamInfoWindow extends StatelessWidget {
  const ExamInfoWindow({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExamController>(
      builder: (c) => Scaffold(
        appBar: AppBar(
          title: const Text("考试安排"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: c.status == ExamStatus.cache || c.status == ExamStatus.fetched
            ? c.subjects.isNotEmpty
                ? TimelineWidget(
                    isTitle: const [true, false, true, false],
                    children: [
                      const TimelineTitle(title: "未完成考试"),
                      c.isNotFinished.isNotEmpty
                          ? Column(
                              children: List.generate(
                                c.isNotFinished.length,
                                (index) => ExamInfoCard(
                                  toUse: c.isNotFinished[index],
                                ),
                              ),
                            )
                          : const ExamInfoCard(title: "所有考试全部完成"),
                      const TimelineTitle(title: "已完成考试"),
                      c.isFinished.isNotEmpty
                          ? Column(
                              children: List.generate(
                                c.isFinished.length,
                                (index) => ExamInfoCard(
                                  toUse: c.isFinished[index],
                                ),
                              ),
                            )
                          : const ExamInfoCard(title: "一门还没考呢"),
                    ],
                  )
                : const Center(child: Text("没有考试安排"))
            : c.status == ExamStatus.error
                ? Center(child: Text(c.error.toString()))
                : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
