/*
Refresh formula for homepage.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:get/get.dart';
import 'package:watermeter_postgraduate/controller/classtable_controller.dart';
import 'package:watermeter_postgraduate/controller/exam_controller.dart';
import 'dart:developer' as developer;

void update() {
  final classTableController = Get.put(ClassTableController());
  final examController = Get.put(ExamController());
  // Update Classtable
  developer.log(
    "Updating current class",
    name: "Homepage Update",
  );
  classTableController.updateCurrent();
  classTableController.update();
  // Update Examation Info
  developer.log(
    "Updating exam info",
    name: "Homepage Update",
  );
  examController.get().then((value) => examController.update());
  // Update Electricity
  developer.log(
    "Updating electricity",
    name: "Homepage Update",
  );
}
