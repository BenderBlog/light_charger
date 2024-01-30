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
  String subject;
  String typeStr;
  String? teacher;
  String time;
  String place;
  String roomId;

  static RegExp timeRegExp = RegExp(
    r'^(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2}) (?<hour>\d{2})(::?)(?<minute>\d{2})-(?<stopHour>\d{2})(::?)(?<stopMinute>\d{2})',
  );

  Jiffy get startTime {
    RegExpMatch? match = timeRegExp.firstMatch(time);
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
    RegExpMatch? match = timeRegExp.firstMatch(time);
    if (match == null) throw NotImplementedException();

    return Jiffy.parseFromDateTime(DateTime(
      int.parse(match.namedGroup('year')!),
      int.parse(match.namedGroup('month')!),
      int.parse(match.namedGroup('day')!),
      int.parse(match.namedGroup('stopHour')!),
      int.parse(match.namedGroup('stopMinute')!),
    ));
  }

  String get type {
    if (typeStr.contains("期末考试")) return "期末考试";
    if (typeStr.contains("期中考试")) return "期中考试";
    if (typeStr.contains("结课考试")) return "结课考试";
    if (typeStr.contains("入学")) return "入学考试";
    return typeStr;
  }

  Subject({
    required this.subject,
    required this.typeStr,
    required this.time,
    required this.place,
    required this.roomId,
    this.teacher,
  });

  factory Subject.fromJson(Map<String, dynamic> json) =>
      _$SubjectFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectToJson(this);
}

class NotImplementedException implements Exception {}
