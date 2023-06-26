/*
Change class table swift dialog.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO watermeter_postgraduate SOURCE CODE
if you want to use.
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watermeter_postgraduate/model/user.dart';

class ChangeSwiftDialog extends StatelessWidget {
  final TextEditingController _getNumberController =
      TextEditingController.fromValue(
    TextEditingValue(
      text: user["swift"] ?? "",
      selection: TextSelection.fromPosition(
        TextPosition(
          affinity: TextAffinity.downstream,
          offset: user["swift"] == null ? 0 : user["swift"]!.length,
        ),
      ),
    ),
  );

  ChangeSwiftDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('课程偏移设置'),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        color: Colors.black,
      ),
      content: TextField(
        autofocus: true,
        style: const TextStyle(fontSize: 20),
        controller: _getNumberController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^[-+]?[0-9]*'))
        ],
        decoration: InputDecoration(
          hintText: "请在此输入数字",
          fillColor: Colors.grey.withOpacity(0.4),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('取消'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: const Text('提交'),
          onPressed: () async {
            if (_getNumberController.text.isEmpty) {
              addUser("swift", "0");
            } else {
              addUser("swift", _getNumberController.text);
            }

            Navigator.of(context).pop();
          },
        ),
      ],
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 7, 16, 16),
    );
  }
}
