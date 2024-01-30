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

import 'dart:math';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:watermeter_postgraduate/page/home.dart';
import 'package:watermeter_postgraduate/page/login/login_window.dart';
import 'package:watermeter_postgraduate/repository/network_session.dart'
    as repo_general;
import 'package:watermeter_postgraduate/repository/preference.dart'
    as preference;
import 'package:watermeter_postgraduate/repository/preference.dart';

void main() async {
  developer.log(
    "Light Charger by BenderBlog Rodriguez and Contributors.",
  );

  // Init the homepage widget data.
  // Register to receive BackgroundFetch events after app is terminated.
  // Requires {stopOnTerminate: false, enableHeadless: true}
  // Disable horizontal screen in phone.
  // See https://stackoverflow.com/questions/57755174/getting-screen-size-in-a-class-without-buildcontext-in-flutter
  final data = WidgetsBinding.instance.platformDispatcher.views.first;

  developer.log(
    "Shortest size: ${data.physicalSize.width} ${data.physicalSize.height} "
    "${min(data.physicalSize.width, data.physicalSize.height) / data.devicePixelRatio}",
  );

  if (min(data.physicalSize.width, data.physicalSize.height) /
          data.devicePixelRatio <
      480) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Loading cookiejar.
  repo_general.supportPath = await getApplicationSupportDirectory();
  preference.prefs = await SharedPreferences.getInstance();

  // Have user registered?
  bool isFirst = false;
  try {
    initUser();
  } on NotLoginException {
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
    return MaterialApp(
      title: 'Light Charger Pre-Alpha',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.deepPurple,
      ),
      home: isFirst ? const LoginWindow() : const HomePage(),
    );
  }
}
