/*
Intro of the watermeter_postgraduate program.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO watermeter_postgraduate SOURCE CODE
if you want to use.
*/

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:watermeter_postgraduate/repository/general.dart';
import 'package:watermeter_postgraduate/model/user.dart';
import 'package:watermeter_postgraduate/page/home.dart';
import 'package:watermeter_postgraduate/page/login.dart';
import 'dart:developer' as developer;
import 'package:get/get.dart';

void main() async {
  developer.log(
    "watermeter_postgraduate, by BenderBlog, with dragon power.",
    name: "watermeter_postgraduate",
  );
  // Make sure the library is initialized.
  WidgetsFlutterBinding.ensureInitialized();
  supportPath = await getApplicationSupportDirectory();
  // Have user registered?
  bool isFirst = false;
  try {
    await initUser();
  } on String {
    isFirst = true;
  }
  developer.log(
    "Logged in status: ${!isFirst}",
    name: "watermeter_postgraduate",
  );
  runApp(MyApp(isFirst: isFirst));
}

class MyApp extends StatelessWidget {
  final bool isFirst;

  const MyApp({Key? key, required this.isFirst}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'watermeter_postgraduate Pre-Alpha',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.deepPurple,
      ),
      home: isFirst ? const LoginWindow() : const HomePage(),
    );
  }
}
