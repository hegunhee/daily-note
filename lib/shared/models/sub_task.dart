/// 일정 하나에 딸린 세부 작업(체크리스트 한 줄)
class SubTask {
  const SubTask({
    required this.id,
    required this.scheduleId,
    required this.title,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false,
  });

  factory SubTask.fromJson(Map<String, dynamic> json) => SubTask(
    id: json['id'] as String,
    scheduleId: json['scheduleId'] as String,
    title: json['title'] as String,
    isCompleted: json['isCompleted'] as bool? ?? false,
    sortOrder: json['sortOrder'] as int,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  final String id;

  /// 속한 일정의 id
  final String scheduleId;

  final String title;

  final bool isCompleted;

  /// 일정 안에서 보여 주는 순서. 작은 값이 위입니다.
  final int sortOrder;

  final DateTime createdAt;

  final DateTime updatedAt;

  SubTask copyWith({
    String? title,
    bool? isCompleted,
    int? sortOrder,
    DateTime? updatedAt,
  }) => SubTask(
    id: id,
    scheduleId: scheduleId,
    title: title ?? this.title,
    isCompleted: isCompleted ?? this.isCompleted,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'scheduleId': scheduleId,
    'title': title,
    'isCompleted': isCompleted,
    'sortOrder': sortOrder,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
