import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:watermeter_postgraduate/controller/classtable_controller.dart';
import 'package:watermeter_postgraduate/page/classtable/classtable.dart';
import 'package:watermeter_postgraduate/page/homepage/info_widget/main_page_card.dart';

class ClassTableCard extends StatelessWidget {
  const ClassTableCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClassTableController>(
      builder: (c) => GestureDetector(
        onTap: () {
          switch (c.state) {
            case ClassTableState.fetched:
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ClassTableWindow(),
                ),
              );
            case ClassTableState.error:
              Fluttertoast.showToast(msg: "遇到错误：${c.error?.substring(0, 150)}");
            case ClassTableState.fetching:
            case ClassTableState.none:
              Fluttertoast.showToast(msg: "正在获取课表");
          }
        },
        child: MainPageCard(
          height: 135,
          icon: Icons.access_time_filled,
          text: c.state == ClassTableState.fetched
              ? c.currentData.$1 == true
                  ? "课程表 下一节课是："
                  : "课程表 正在上："
              : "课程表",
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  c.state == ClassTableState.fetched
                      ? c.currentData.$2 == null
                          ? "目前没课"
                          : c.currentData.$2!.name
                      : c.state == ClassTableState.fetching
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
            c.state == ClassTableState.fetched
                ? c.currentData.$2 == null
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
                                    c.currentData.$2!.teacher.length >= 7
                                        ? c.currentData.$2!.teacher
                                            .substring(0, 7)
                                        : c.currentData.$2!.teacher,
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
                                    c.currentData.$2!.place,
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
                                "${c.currentData.$2!.startTimeStr}-"
                                "${c.currentData.$2!.endTimeStr}",
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
