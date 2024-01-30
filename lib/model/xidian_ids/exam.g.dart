// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subject _$SubjectFromJson(Map<String, dynamic> json) => Subject(
      subject: json['subject'] as String,
      typeStr: json['typeStr'] as String,
      time: json['time'] as String,
      place: json['place'] as String,
      roomId: json['roomId'] as String,
      teacher: json['teacher'] as String?,
    );

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
      'subject': instance.subject,
      'typeStr': instance.typeStr,
      'teacher': instance.teacher,
      'time': instance.time,
      'place': instance.place,
      'roomId': instance.roomId,
    };
