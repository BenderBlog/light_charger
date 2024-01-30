// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';

class AppIconWidget extends StatelessWidget {
  const AppIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      backgroundImage: AssetImage("assets/Login-Background.jpg"),
      radius: 60.0,
    );
  }
}
