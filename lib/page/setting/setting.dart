/*
Setting window.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO watermeter_postgraduate SOURCE CODE
if you want to use.
*/

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watermeter_postgraduate/repository/network_session.dart';
import 'package:watermeter_postgraduate/repository/preference.dart';
import 'package:watermeter_postgraduate/page/setting/subwindow/change_swift_dialog.dart';

class SettingWindow extends StatefulWidget {
  const SettingWindow({Key? key}) : super(key: key);

  @override
  State<SettingWindow> createState() => _SettingWindowState();
}

class _SettingWindowState extends State<SettingWindow> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SettingsList(
        lightTheme: SettingsThemeData(
          settingsListBackground: Theme.of(context).colorScheme.background,
        ),
        sections: [
          SettingsSection(
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                title: const Text('启明灯软件 - 测试版'),
                value: const Text(
                  "Copyright 2024 BenderBlog Rodriguez and contributors",
                ),
                onPressed: (context) => launchUrl(
                  Uri.parse(
                      "https://github.com/BenderBlog/watermeter_postgraduate"),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('用户相关'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                title: const Text('查看网络拦截器'),
                onPressed: (context) => alice.showInspector(),
              ),
              SettingsTile.navigation(
                  title: const Text('用户信息'), value: Text("${user["name"]}")),
              SettingsTile.navigation(
                title: const Text('清除缓存'),
                value: const Text("清除所有缓存"),
              ),
              SettingsTile.navigation(
                  title: const Text('退出登录'),
                  value: const Text("退出登录该帐号，该帐号在本地的所有信息均将被删除！")),
            ],
          ),
          SettingsSection(
            title: const Text('课表相关设置'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                  title: const Text('课程偏移设置'),
                  value: const Text("为应对某些紧急状况，可通过这个调整开学日期\n"
                      "输入负数提前开学日期，输入正数延后开学日期\n"
                      "(希望以后没有因为疫情导致提前上下学期课程的情况，tmd 这大学真白上了)"),
                  onPressed: (content) {
                    showDialog(
                      context: context,
                      builder: (context) => ChangeSwiftDialog(),
                    );
                  }),
              SettingsTile.switchTile(
                title: const Text("开启课表背景图"),
                initialValue:
                    user["decorated"] != null && user["decorated"]! == "true"
                        ? true
                        : false,
                onToggle: (bool value) {
                  if (value == true &&
                      (user["decoration"] == null ||
                          user["decoration"]!.isEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('你先选个图片罢，就在下面'),
                    ));
                  } else {
                    setState(() {
                      addUser("decorated", value.toString());
                    });
                  }
                },
              ),
              SettingsTile.navigation(
                  title: const Text('课表背景图选择'),
                  value: const Text("把你的对象搁课程表上面，上课没事就看(这不神经病)"),
                  onPressed: (content) async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(type: FileType.image);
                    if (mounted) {
                      if (result != null) {
                        Directory appDocDir =
                            await getApplicationDocumentsDirectory();
                        Directory destination = Directory(
                            "${appDocDir.path}/org.superbart.watermeter_postgraduate");
                        if (!destination.existsSync()) {
                          await destination.create();
                        }
                        var decorated = File(result.files.single.path!)
                            .copySync("${destination.path}/decoration.jpg");
                        addUser("decoration", decorated.path);
                        if (mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('设定成功'),
                          ));
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('你没有选捏，目前设置${user["decoration"]}'),
                        ));
                      }
                    }
                  }),
            ],
          ),
        ],
      ),
    );
  }
}
