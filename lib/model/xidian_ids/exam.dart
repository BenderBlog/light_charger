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

import 'package:jiffy/jiffy.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exam.g.dart';

@JsonSerializable(explicitToJson: true)
class Subject {
  /// 课程名称
  String subject;

  /// 考试类型
  String type;

  /// 考试时间
  String timeStr;

  /// 考试开始时间
  String startTimeStr;

  /// 考试结束时间
  String stopTimeStr;

  /// 考试地点
  String place;

  /// 考场编号
  String roomId;

  static RegExp timeRegExp = RegExp(
    r'^(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2}) (?<hour>\d{2})(::?)(?<minute>\d{2})',
  );

  Jiffy get startTime {
    RegExpMatch? match = timeRegExp.firstMatch(startTimeStr);
    if (match == null) throw NotImplementedException();

    return Jiffy.parseFromDateTime(DateTime(
      int.parse(match.namedGroup('year')!),
      int.parse(match.namedGroup('month')!),
      int.parse(match.namedGroup('day')!),
      int.parse(match.namedGroup('hour')!),
      int.parse(match.namedGroup('minute')!),
    ));
  }

  Jiffy get stopTime {
    RegExpMatch? match = timeRegExp.firstMatch(stopTimeStr);
    if (match == null) throw NotImplementedException();

    return Jiffy.parseFromDateTime(DateTime(
      int.parse(match.namedGroup('year')!),
      int.parse(match.namedGroup('month')!),
      int.parse(match.namedGroup('day')!),
      int.parse(match.namedGroup('stopHour')!),
      int.parse(match.namedGroup('stopMinute')!),
    ));
  }

  Subject({
    required this.subject,
    required this.type,
    required this.timeStr,
    required this.startTimeStr,
    required this.stopTimeStr,
    required this.place,
    required this.roomId,
  });

  factory Subject.fromJson(Map<String, dynamic> json) =>
      _$SubjectFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectToJson(this);
}

class NotImplementedException implements Exception {}
