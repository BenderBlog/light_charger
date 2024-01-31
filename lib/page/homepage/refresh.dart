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

import 'package:get/get.dart';
import 'package:watermeter_postgraduate/controller/classtable_controller.dart';
import 'package:watermeter_postgraduate/controller/exam_controller.dart';
import 'dart:developer' as developer;

import 'package:watermeter_postgraduate/repository/ids_session.dart';
import 'package:watermeter_postgraduate/repository/preference.dart';
import 'package:watermeter_postgraduate/repository/yjspt_session.dart';
// Refresh formula for homepage.

Future<void> _comboLogin({
  Future<void> Function(String)? sliderCaptcha,
}) async {
  // Guard
  if (loginState == IDSLoginState.requesting) {
    return;
  }
  loginState = IDSLoginState.requesting;

  try {
    await ses.loginYjspt(
      username: user["idsAccount"]!,
      password: user["idsPassword"]!,
      forceReLogin: false,
      sliderCaptcha: sliderCaptcha,
    );
    loginState = IDSLoginState.success;
  } on PasswordWrongException {
    loginState = IDSLoginState.passwordWrong;

    developer.log(
      "Combo login failed! Because your password is wrong.",
      name: "[_comboLogin]",
    );
  } catch (e, s) {
    loginState = IDSLoginState.fail;

    developer.log(
      "Combo login failed! Because of the following error: "
      "$e\nThe stack of the error is: \n$s",
      name: "[_comboLogin] ",
    );
  }
}

Future<void> update({
  bool forceRetryLogin = false,
  Future<void> Function(String)? sliderCaptcha,
}) async {
  final classTableController = Get.put(ClassTableController());
  final examController = Get.put(ExamController());

  // Retry Login
  if (forceRetryLogin || loginState == IDSLoginState.fail) {
    await _comboLogin(sliderCaptcha: sliderCaptcha);
  }

  // Update Classtable
  developer.log(
    "Updating current class",
    name: "[refresh][update]",
  );
  classTableController.updateCurrent();
  classTableController.update();

  // Update Examation Info
  developer.log(
    "Updating exam info",
    name: "[refresh][update]",
  );
  examController.get().then((value) => examController.update());

  // Update Library
  /*
  log.i(
    "[refresh][update] "
    "Updating library",
  );
  borrow_info.LibrarySession().getBorrowList();
  */
}

void updateOnAppResumed() {
  final classTableController = Get.put(ClassTableController());

  // Update Classtable
  developer.log(
    "Updating current class",
    name: "[updateOnAppResumed]",
  );
  classTableController.updateCurrent();
  classTableController.update();
}
