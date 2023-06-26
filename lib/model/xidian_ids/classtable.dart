/*
The class table model.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO watermeter_postgraduate SOURCE CODE
if you want to use.
*/

class ClassDetail {
  String name; // 名称
  String? teacher; // 老师
  String? place; // 地方

  ClassDetail({
    required this.name,
    this.teacher,
    this.place,
  });

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) =>
      other is ClassDetail &&
      other.runtimeType == runtimeType &&
      name == other.name;

  @override
  String toString() {
    if (place != null) {
      return "${name.length <= 15 ? name : "${name.substring(0, 14)}..."}\n$place";
    } else {
      return name;
    }
  }
}

class TimeArrangement {
  int index; // 课程索引
  // 返回的是 0 和 1 组成的数组，0 代表这周没课程，1 代表这周有课
  String weekList; // 上课周次
  int day; // 星期几上课
  int start; // 上课开始
  int stop; // 上课结束
  late int step; // 上课长度
  TimeArrangement({
    required this.index,
    required this.weekList,
    required this.day,
    required this.start,
    required this.stop,
  }) {
    step = stop - start;
  }
}

// Time arrangements.
// Even means start, odd means end.
List<String> time = [
  "8:30",
  "9:15",
  "9:20",
  "10:05",
  "10:25",
  "11:10",
  "11:15",
  "12:00",
  "14:00",
  "14:45",
  "14:50",
  "15:35",
  "15:55",
  "16:40",
  "16:45",
  "17:30",
  "19:00",
  "19:45",
  "19:55",
  "20:35",
  "20:40",
  "21:25",
];
