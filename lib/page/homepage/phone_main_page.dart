import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:watermeter_postgraduate/controller/classtable_controller.dart';
import 'package:watermeter_postgraduate/controller/exam_controller.dart';
import 'package:watermeter_postgraduate/page/clipper.dart';
import 'package:watermeter_postgraduate/page/homepage/info_widget/classtable_card.dart';
import 'package:watermeter_postgraduate/page/homepage/info_widget/exam_card.dart';
import 'package:watermeter_postgraduate/page/homepage/info_widget/score_card.dart';
import 'package:watermeter_postgraduate/page/homepage/refresh.dart';

class PhoneMainPage extends StatelessWidget {
  final classTableController = Get.put(ClassTableController());
  final examController = Get.put(ExamController());

  PhoneMainPage({super.key});

  final classCardHeight = 135.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: GetBuilder<ClassTableController>(
          builder: (c) => Text(
            "第 ${c.currentWeek + 1} 周",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: EasyRefresh(
        onRefresh: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text("请稍候，正在刷新信息"),
          ));
          update();
        },
        header: PhoenixHeader(
          skyColor: Theme.of(context).colorScheme.primary,
          position: IndicatorPosition.locator,
          safeArea: false,
        ),
        child: ListView(
          children: [
            const HeaderLocator(),
            Stack(
              alignment: Alignment.center,
              children: [
                ClipPath(
                  clipper: RoundClipper(
                    height: classCardHeight,
                  ),
                  child: Container(
                    height: classCardHeight,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const ClassTableCard(),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.025),
              child: GridView.count(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: MediaQuery.of(context).size.width / 160,
                children: [
                  ScoreCard(),
                  const ExamCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
