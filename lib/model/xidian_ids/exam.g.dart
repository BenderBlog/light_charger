// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subject _$SubjectFromJson(Map<String, dynamic> json) => Subject(
      subject: json['subject'] as String,
      type: json['type'] as String,
      timeStr: json['timeStr'] as String,
      startTimeStr: json['startTimeStr'] as String,
      stopTimeStr: json['stopTimeStr'] as String,
      place: json['place'] as String,
      roomId: json['roomId'] as String,
    );

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
      'subject': instance.subject,
      'type': instance.type,
      'timeStr': instance.timeStr,
      'startTimeStr': instance.startTimeStr,
      'stopTimeStr': instance.stopTimeStr,
      'place': instance.place,
      'roomId': instance.roomId,
    };
