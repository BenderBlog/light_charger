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

class Score {
  int mark; // 编号，用于某种计算，从 0 开始
  String name; // 学科名称
  double score; // 分数
  String year; // 学年
  double credit; // 学分
  String status; // 修读状态
  int how; // 评分方式
  String? level; // 等级
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
    this.isNoNeedStudy,
    this.level,
  });
}
