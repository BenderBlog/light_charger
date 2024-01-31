/// Copyright 2024 BenderBlog Rodriguez and contributors
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

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter_postgraduate/page/home.dart';
import 'package:watermeter_postgraduate/page/login/jc_captcha.dart';
import 'package:watermeter_postgraduate/page/login/login_window.dart';
import 'package:watermeter_postgraduate/repository/ids_session.dart';
import 'package:watermeter_postgraduate/repository/preference.dart';
import 'package:watermeter_postgraduate/repository/yjspt_session.dart';

class EntryPage extends StatefulWidget {
  const EntryPage({super.key});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  Future<void> _loginAsync() async {
    print("_loginAsync entry page");
    try {
      loginState = IDSLoginState.manual;
      await ses.loginYjspt(
        forceReLogin: true,
        sliderCaptcha: (String cookieStr) {
          return Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CaptchaWidget(
                cookie: cookieStr,
              ),
            ),
          );
        },
      );
    } finally {
      Fluttertoast.cancel();
      if (mounted) {
        if (loginState == IDSLoginState.passwordWrong) {
          user["idsPassword"] = null;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text("用户名或密码有误"),
                content: const Text("是否重新登录？"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginWindow(),
                        ),
                      );
                    },
                    child: const Text("是"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    },
                    child: const Text("否，进入离线模式"),
                  ),
                ],
              ),
            );
          });
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      }
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await _loginAsync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: const Text("正在登录，请稍后").center());
  }
}
