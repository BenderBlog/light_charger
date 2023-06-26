/*
Exam Infomation Interface.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO watermeter_postgraduate SOURCE CODE
if you want to use.
*/

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watermeter_postgraduate/model/xidian_ids/exam.dart';
import 'package:watermeter_postgraduate/controller/exam_controller.dart';
import 'package:watermeter_postgraduate/page/widget.dart';

class ExamInfoWindow extends StatefulWidget {
  const ExamInfoWindow({super.key});

  @override
  State<ExamInfoWindow> createState() => _ExamInfoWindowState();
}

class _ExamInfoWindowState extends State<ExamInfoWindow> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExamController>(
      builder: (c) => Scaffold(
        appBar: AppBar(
          title: const Text("考试安排"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => aboutDialog(context),
                );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Container(
                height: 36.0,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("当前展示的学期："),
                    DropdownButton(
                      focusColor: Theme.of(context).appBarTheme.backgroundColor,
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                      value: c.dropdownValue,
                      style: const TextStyle(color: Colors.black),
                      underline: Container(color: Colors.transparent),
                      onChanged: (int? value) {
                        setState(() {
                          c.dropdownValue = value!;
                        });
                        c.get(semesterStr: c.semesters[c.dropdownValue]);
                      },
                      items: List.generate(
                        c.semesters.length,
                        (index) => DropdownMenuItem(
                          value: index,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(c.semesters[index]),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: c.isGet == true
            ? c.subjects.isNotEmpty
                ? dataList<InfoCard, InfoCard>(
                    List.generate(
                      c.subjects.length,
                      (index) => InfoCard(toUse: c.subjects[index]),
                    ),
                    (toUse) => toUse,
                  )
                : const Center(child: Text("没有考试安排"))
            : c.error != null
                ? Center(child: Text(c.error.toString()))
                : const Center(child: Text("正在加载")),
      ),
    );
  }

  Widget aboutDialog(context) => AlertDialog(
        title: const Text("考试还不是所有......"),
        content: Image.asset("assets/Boochi-Afraid-Work.jpg"),
        actions: <Widget>[
          TextButton(
            child: const Text("确定"),
            onPressed: () => Get.back(),
          ),
        ],
      );
}

class InfoCard extends StatelessWidget {
  final Subject toUse;

  const InfoCard({super.key, required this.toUse});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      elevation: 0,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: [
                Text(
                  toUse.subject,
                  textScaleFactor: 1.1,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                TagsBoxes(
                  text: toUse.type,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                const Divider(
                  color: Colors.transparent,
                  height: 5,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_filled_rounded,
                      size: 14,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    const SizedBox(width: 5),
                    Text(toUse.time),
                  ],
                ),
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Icon(
                            Icons.room,
                            size: 14,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          const SizedBox(width: 5),
                          Text(toUse.place),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Icon(
                            Icons.chair,
                            size: 14,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          const SizedBox(width: 5),
                          Text(toUse.roomId),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
