import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermeter_postgraduate/controller/classtable_controller.dart';
import 'package:watermeter_postgraduate/model/xidian_ids/classtable.dart';
import 'package:watermeter_postgraduate/page/classtable/classtable.dart';
import 'package:watermeter_postgraduate/page/homepage/info_widget/main_page_card.dart';

class ClassTableCard extends StatelessWidget {
  const ClassTableCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClassTableController>(
      builder: (c) => GestureDetector(
        onTap: () {
          try {
            if (c.isGet == true) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LayoutBuilder(
                    builder: (p0, p1) => ClassTableWindow(constraints: p1),
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(c.error ?? "正在获取课表")));
            }
          } on String catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("遇到错误：${e.substring(0, 150)}")));
          }
        },
        child: MainPageCard(
          height: 135,
          icon: Icons.access_time_filled,
          text: c.isGet == true
              ? c.isNext == null
                  ? "课程表"
                  : c.isNext == true
                      ? "课程表 下一节课是："
                      : "课程表 正在上："
              : "课程表",
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  c.isGet == true
                      ? c.classToShow == null
                          ? "目前没课"
                          : c.classToShow!.name
                      : c.error == null
                          ? "正在加载"
                          : "遇到错误",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                )
              ],
            ),
            c.isGet == true
                ? c.classToShow == null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Text(
                              "寻找什么呢，我也不知道",
                              style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            )
                          ])
                    : Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    c.classToShow!.teacher == null
                                        ? "老师未知"
                                        : c.classToShow!.teacher!.length >= 7
                                            ? c.classToShow!.teacher!
                                                .substring(0, 7)
                                            : c.classToShow!.teacher!,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              Row(
                                children: [
                                  Icon(
                                    Icons.room,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    c.timeArrangementToShow!.classroom ??
                                        "地点未定",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.access_time_filled_outlined,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                                size: 18,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                "${time[(c.timeArrangementToShow!.start - 1) * 2]}-"
                                "${time[(c.timeArrangementToShow!.stop - 1) * 2 + 1]}",
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                : Text(
                    c.error == null ? "请耐心等待片刻" : "课表获取失败",
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
