/*
Home window.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:flutter/material.dart';
import 'package:watermeter_postgraduate/page/homepage/pad_main_page.dart';
import 'package:watermeter_postgraduate/page/homepage/phone_main_page.dart';
import 'package:watermeter_postgraduate/page/widget.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return isPhone(context) ? PhoneMainPage() : PadMainPage();
  }
}
