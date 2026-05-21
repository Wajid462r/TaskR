import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo_list.dart';
import '../models/todo_item.dart';
import '../models/note.dart';

/// Singleton che gestisce il database SQLite dell'app.
/// Tabelle:
///   lists  — le liste todo
///   items  — i task, con FK -> lists (ON DELETE CASCADE)
///   notes  — gli appunti, con linked_list_id nullable -> lists
class DatabaseHelper {
  static const _dbName    = 'taskr.db';
  static const _dbVersion = 1;

  static const tLists = 'lists';
  static const tItems = 'items';
  static const tNotes = 'notes';

  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  Database? _db;

  Future<Database> get db async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int _) async {
    await db.execute('''
      CREATE TABLE $tLists (
        id         TEXT PRIMARY KEY,
        name       TEXT NOT NULL,
        emoji      TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $tItems (
        id           TEXT PRIMARY KEY,
        list_id      TEXT NOT NULL,
        title        TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at   TEXT NOT NULL,
        completed_at TEXT,
        FOREIGN KEY (list_id) REFERENCES $tLists(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE $tNotes (
        id             TEXT PRIMARY KEY,
        title          TEXT NOT NULL,
        content        TEXT NOT NULL,
        created_at     TEXT NOT NULL,
        updated_at     TEXT NOT NULL,
        linked_list_id TEXT
      )
    ''');
  }

  // ── LISTE ─────────────────────────────────────────────────────────────────

  Future<List<TodoList>> loadAllLists() async {
    final database = await db;
    final listRows = await database.query(tLists, orderBy: 'created_at ASC');
    final result = <TodoList>[];
    for (final row in listRows) {
      final itemRows = await database.query(
        tItems,
        where: 'list_id = ?',
        whereArgs: [row['id']],
        orderBy: 'created_at ASC',
      );
      result.add(TodoList(
        id:        row['id'] as String,
        name:      row['name'] as String,
        emoji:     row['emoji'] as String,
        createdAt: DateTime.parse(row['created_at'] as String),
        items:     itemRows.map(_rowToItem).toList(),
      ));
    }
    return result;
  }

  Future<void> insertList(TodoList l) async =>
      (await db).insert(tLists, {
        'id': l.id, 'name': l.name,
        'emoji': l.emoji, 'created_at': l.createdAt.toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<void> updateList(TodoList l) async =>
      (await db).update(tLists, {'name': l.name, 'emoji': l.emoji},
          where: 'id = ?', whereArgs: [l.id]);

  Future<void> deleteList(String id) async =>
      (await db).delete(tLists, where: 'id = ?', whereArgs: [id]);

  // ── TASK ──────────────────────────────────────────────────────────────────

  Future<void> insertItem(String listId, TodoItem i) async =>
      (await db).insert(tItems, _itemToRow(listId, i),
          conflictAlgorithm: ConflictAlgorithm.replace);

  Future<void> updateItem(String listId, TodoItem i) async =>
      (await db).update(tItems, _itemToRow(listId, i),
          where: 'id = ?', whereArgs: [i.id]);

  Future<void> deleteItem(String id) async =>
      (await db).delete(tItems, where: 'id = ?', whereArgs: [id]);

  // ── NOTE ──────────────────────────────────────────────────────────────────

  Future<List<Note>> loadAllNotes() async {
    final rows = await (await db).query(tNotes, orderBy: 'updated_at DESC');
    return rows.map(_rowToNote).toList();
  }

  Future<void> insertNote(Note n) async =>
      (await db).insert(tNotes, _noteToRow(n),
          conflictAlgorithm: ConflictAlgorithm.replace);

  Future<void> updateNote(Note n) async =>
      (await db).update(tNotes, _noteToRow(n),
          where: 'id = ?', whereArgs: [n.id]);

  Future<void> deleteNote(String id) async =>
      (await db).delete(tNotes, where: 'id = ?', whereArgs: [id]);

  /// Quando si elimina una lista, le note collegate vengono scollegate
  /// (non eliminate) impostando linked_list_id = NULL.
  Future<void> unlinkNotesForList(String listId) async =>
      (await db).update(tNotes, {'linked_list_id': null},
          where: 'linked_list_id = ?', whereArgs: [listId]);

  // ── Conversioni row <-> model ─────────────────────────────────────────────

  Map<String, dynamic> _itemToRow(String listId, TodoItem i) => {
        'id': i.id, 'list_id': listId, 'title': i.title,
        'is_completed': i.isCompleted ? 1 : 0,
        'created_at': i.createdAt.toIso8601String(),
        'completed_at': i.completedAt?.toIso8601String(),
      };

  TodoItem _rowToItem(Map<String, dynamic> r) => TodoItem(
        id:          r['id'] as String,
        title:       r['title'] as String,
        isCompleted: (r['is_completed'] as int) == 1,
        createdAt:   DateTime.parse(r['created_at'] as String),
        completedAt: r['completed_at'] != null
            ? DateTime.parse(r['completed_at'] as String) : null,
      );

  Map<String, dynamic> _noteToRow(Note n) => {
        'id': n.id, 'title': n.title, 'content': n.content,
        'created_at': n.createdAt.toIso8601String(),
        'updated_at': n.updatedAt.toIso8601String(),
        'linked_list_id': n.linkedListId,
      };

  Note _rowToNote(Map<String, dynamic> r) => Note(
        id:           r['id'] as String,
        title:        r['title'] as String,
        content:      r['content'] as String,
        createdAt:    DateTime.parse(r['created_at'] as String),
        updatedAt:    DateTime.parse(r['updated_at'] as String),
        linkedListId: r['linked_list_id'] as String?,
      );
}
