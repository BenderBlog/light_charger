import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:restart_app/restart_app.dart';

import 'package:watermeter_postgraduate/page/homepage/homepage.dart';
import 'package:watermeter_postgraduate/page/homepage/refresh.dart';
import 'package:watermeter_postgraduate/page/login/jc_captcha.dart';
import 'package:watermeter_postgraduate/page/setting/setting.dart';
import 'package:watermeter_postgraduate/repository/preference.dart';
import 'package:watermeter_postgraduate/repository/xidian_ids/ids_session.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      updateOnAppResumed();
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    developer.log(
      "[home][BackgroundFetchFromHome]"
      "Current loginstate: $loginState, if none will _loginAsync.",
    );
    if (loginState == IDSLoginState.none) {
      _loginAsync();
    } else {
      update();
    }
  }

  void _loginAsync() async {
    Fluttertoast.showToast(msg: "登录中，暂时显示缓存数据");

    try {
      await update(
        forceRetryLogin: true,
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

      if (loginState == IDSLoginState.success) {
        Fluttertoast.showToast(msg: "登录成功");
      } else if (loginState == IDSLoginState.passwordWrong) {
        user["idsPassword"] = null;

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text("用户名或密码有误"),
              content: const Text("是否重启应用后手动登录？"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Restart.restartApp();
                  },
                  child: const Text("是"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showOfflineModeNotice();
                  },
                  child: const Text("否，进入离线模式"),
                ),
              ],
            ),
          );
        });
      } else {
        _showOfflineModeNotice();
      }
    }
  }

  void _showOfflineModeNotice() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("统一认证服务离线模式开启"),
          content: const Text(
            "无法连接到统一认证服务服务器，所有和其相关的服务暂时不可用。\n"
            "成绩查询，考试信息查询，欠费查询，校园卡查询关闭。课表显示缓存数据。其他功能暂不受影响。\n"
            "如有不便，敬请谅解。",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("确定"),
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  static final _page = [
    const MainPage(),
    const SettingWindow(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //extendBodyBehindAppBar: true,
      body: _page[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(
            icon: _selectedIndex == 0
                ? const Icon(Icons.home)
                : const Icon(Icons.home_outlined),
            label: '主页',
          ),
          NavigationDestination(
            icon: _selectedIndex == 3
                ? const Icon(Icons.settings)
                : const Icon(Icons.settings_outlined),
            label: '设置',
          ),
        ],
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
