import 'todo_item.dart';

class TodoList {
  final String id;
  String name;
  String emoji;
  final DateTime createdAt;
  List<TodoItem> items;

  TodoList({
    required this.id,
    required this.name,
    required this.emoji,
    required this.createdAt,
    List<TodoItem>? items,
  }) : items = items ?? [];

  int get totalItems => items.length;
  int get completedItems => items.where((i) => i.isCompleted).length;
  int get pendingItems => items.where((i) => !i.isCompleted).length;
  double get efficiency =>
      totalItems == 0 ? 0 : (completedItems / totalItems) * 100;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'createdAt': createdAt.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
      };

  factory TodoList.fromJson(Map<String, dynamic> json) => TodoList(
        id: json['id'],
        name: json['name'],
        emoji: json['emoji'] ?? '📋',
        createdAt: DateTime.parse(json['createdAt']),
        items: (json['items'] as List)
            .map((i) => TodoItem.fromJson(i))
            .toList(),
      );
}
