/*
The score model.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO watermeter_postgraduate SOURCE CODE
if you want to use.
*/

class Score {
  int mark; // 编号，用于某种计算，从 0 开始
  String name; // 学科名称
  double score; // 分数
  String year; // 学年
  double credit; // 学分
  String status; // 修读状态
  int how; // 评分方式
  String? level; // 等级
  String? classID; // 教学班序列号
  String? scoreStructure; //成绩构成
  String? scoreDetail; //分项成绩
  int isPassed; //是否及格
  bool? isNoNeedStudy; //是否免修
  Score({
    required this.mark,
    required this.name,
    required this.score,
    required this.year,
    required this.credit,
    required this.status,
    required this.isPassed,
    required this.how,
    this.level,
    this.classID,
    this.scoreStructure,
    this.scoreDetail,
    this.isNoNeedStudy,
  });
}

List<String> toBeCounted = [
  "政治理论课",
  "英语公共课",
  "数学课",
  "专业核心课",
  "专业基础课",
  "工程伦理",
];
