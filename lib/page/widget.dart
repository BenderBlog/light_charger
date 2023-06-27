/*
Useful weights to simplify watermeter_postgraduate program.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO watermeter_postgraduate SOURCE CODE
if you want to use.
*/

import 'package:flutter/material.dart';

/// Check the width
bool isPhone(context) => MediaQuery.of(context).size.width < 480;
bool isDesktop(context) => MediaQuery.of(context).size.width > 840;

/// Something related to the box.
const double widthOfSquare = 30.0;
const double roundRadius = 10;

/// Use it to show the small items.
class TagsBoxes extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const TagsBoxes(
      {Key? key,
      required this.text,
      this.backgroundColor = Colors.blue,
      this.textColor = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(9)),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor),
        textScaleFactor: 0.9,
      ),
    );
  }
}

/// A listview widget.
Widget dataList<T, W extends Widget>(List<T> a, W Function(T toUse) init,
        {ScrollPhysics? physics}) =>
    ListView.separated(
      physics: physics,
      itemCount: a.length,
      itemBuilder: (context, index) {
        return init(a[index]);
      },
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 3),
      padding: const EdgeInsets.symmetric(
        horizontal: 12.5,
        vertical: 9.0,
      ),
    );

/// Colors for the class information card.
const colorList = [
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.yellow,
  Colors.orange,
  Colors.deepOrange,
  Colors.brown,
];

/// Colors for class information card which not in this week.
const uselessColor = Colors.grey;
