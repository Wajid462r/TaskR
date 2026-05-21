class Note {
  final String id;
  String title;
  String content;
  final DateTime createdAt;
  DateTime updatedAt;
  String? linkedListId; // null = nota standalone

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.linkedListId,
  });
}
