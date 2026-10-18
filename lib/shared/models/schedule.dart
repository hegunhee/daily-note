import 'package:flutter/material.dart';

/// 날짜 하루 안에 시작·종료 시각이 있는 일정 한 건
///
/// 날짜·시각은 기기의 로컬 시간 기준입니다. 종료 시각은 시작 시각보다 늦어야 하며,
/// 자정을 넘기는 일정은 두지 않습니다.
class Schedule {
  const Schedule({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    required this.updatedAt,
    this.memo = '',
    this.isCompleted = false,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
    id: json['id'] as String,
    title: json['title'] as String,
    date: _parseDate(json['date'] as String),
    startTime: _parseTime(json['startTime'] as String),
    endTime: _parseTime(json['endTime'] as String),
    memo: json['memo'] as String? ?? '',
    isCompleted: json['isCompleted'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  final String id;

  final String title;

  /// 일정 날짜. 시각 없이 그날 0시로 둡니다.
  final DateTime date;

  final TimeOfDay startTime;

  final TimeOfDay endTime;

  /// 메모. 없으면 빈 문자열입니다.
  final String memo;

  /// 사용자가 일정을 완료 처리했는지 여부. 세부 작업 완료율과는 따로 둡니다.
  final bool isCompleted;

  final DateTime createdAt;

  final DateTime updatedAt;

  Schedule copyWith({
    String? title,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? memo,
    bool? isCompleted,
    DateTime? updatedAt,
  }) => Schedule(
    id: id,
    title: title ?? this.title,
    date: date ?? this.date,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    memo: memo ?? this.memo,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    // 시간대가 바뀌어도 날짜가 밀리지 않게 달력 날짜 문자열로 저장합니다.
    'date': _formatDate(date),
    'startTime': _formatTime(startTime),
    'endTime': _formatTime(endTime),
    'memo': memo,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  static String _two(int value) => value.toString().padLeft(2, '0');

  static String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${_two(date.month)}-${_two(date.day)}';

  static DateTime _parseDate(String text) {
    final parts = text.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1], parts[2]);
  }

  static String _formatTime(TimeOfDay time) =>
      '${_two(time.hour)}:${_two(time.minute)}';

  static TimeOfDay _parseTime(String text) {
    final parts = text.split(':').map(int.parse).toList();
    return TimeOfDay(hour: parts[0], minute: parts[1]);
  }
}
