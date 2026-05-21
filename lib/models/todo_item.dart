class TodoItem {
  final String id;
  String title;
  bool isCompleted;
  final DateTime createdAt;
  DateTime? completedAt;

  TodoItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  void toggle() {
    isCompleted = !isCompleted;
    completedAt = isCompleted ? DateTime.now() : null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        id: json['id'],
        title: json['title'],
        isCompleted: json['isCompleted'],
        createdAt: DateTime.parse(json['createdAt']),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
      );
}
