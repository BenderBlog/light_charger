import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:watermeter_postgraduate/controller/exam_controller.dart';
import 'package:watermeter_postgraduate/page/exam/exam_info_window.dart';
import 'package:watermeter_postgraduate/repository/ids_session.dart';

class ExamCard extends StatelessWidget {
  const ExamCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExamController>(
      builder: (c) => GestureDetector(
        onTap: () async {
          if (offline) {
            Fluttertoast.showToast(msg: "脱机模式下，一站式相关功能全部禁止使用");
          } else if (c.status == ExamStatus.cache ||
              c.status == ExamStatus.fetched) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ExamInfoWindow()));
          } else if (c.status != ExamStatus.error) {
            Fluttertoast.showToast(msg: "请稍候，正在获取考试信息");
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(c.error.substring(
                  0,
                  min(c.error.length, 120),
                )),
              ),
            );
            Fluttertoast.showToast(msg: "遇到错误，请联系开发者");
          }
        },
        child: Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 48,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "考试查询",
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        "上天保佑时间",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
