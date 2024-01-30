// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:watermeter_postgraduate/page/classtable/classtable_state.dart';
import 'package:watermeter_postgraduate/page/classtable/class_page/classtable_page.dart';

/// Intro of the classtable.

class ClassTableWindow extends StatelessWidget {
  const ClassTableWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return ClassTableState(
      context: context,
      controllers: ClassTableWidgetState(),
      child: Navigator(
        onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
          builder: (context) => const ClassTablePage(),
        ),
      ),
    );
  }
}
