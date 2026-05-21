import 'package:flutter/foundation.dart';
import '../data/database_helper.dart';
import '../models/todo_list.dart';
import '../models/todo_item.dart';
import '../models/note.dart';

class AppState extends ChangeNotifier {
  final _db = DatabaseHelper.instance;

  List<TodoList> _lists = [];
  List<Note>     _notes = [];
  int  _selectedListIndex = 0;
  bool isLoading = true;

  AppState() { _load(); }

  // ── Getters ───────────────────────────────────────────────────────────────

  List<TodoList> get lists        => _lists;
  List<Note>     get notes        => _notes;
  int  get selectedListIndex      => _selectedListIndex;
  TodoList? get selectedList      =>
      _lists.isEmpty ? null : _lists[_selectedListIndex];

  /// Note collegate a una specifica lista
  List<Note> notesForList(String listId) =>
      _notes.where((n) => n.linkedListId == listId).toList();

  /// Note non collegate a nessuna lista
  List<Note> get standaloneNotes =>
      _notes.where((n) => n.linkedListId == null).toList();

  int    get globalTotal      => _lists.fold(0, (s, l) => s + l.totalItems);
  int    get globalCompleted  => _lists.fold(0, (s, l) => s + l.completedItems);
  int    get globalPending    => _lists.fold(0, (s, l) => s + l.pendingItems);
  double get globalEfficiency =>
      globalTotal == 0 ? 0 : (globalCompleted / globalTotal) * 100;

  // ── Load iniziale ─────────────────────────────────────────────────────────

  Future<void> _load() async {
    _lists = await _db.loadAllLists();
    _notes = await _db.loadAllNotes();
    if (_lists.isEmpty) await _seedDefault();
    if (_selectedListIndex >= _lists.length) _selectedListIndex = 0;
    isLoading = false;
    notifyListeners();
  }

  Future<void> _seedDefault() async {
    final now  = DateTime.now();
    final list = TodoList(
      id: 'default', name: 'My Tasks', emoji: '⚡', createdAt: now,
      items: [
        TodoItem(id: 'sample1', title: 'Benvenuto in TASKR!',           createdAt: now),
        TodoItem(id: 'sample2', title: 'Tocca + per aggiungere un task', createdAt: now),
      ],
    );
    await _db.insertList(list);
    for (final item in list.items) await _db.insertItem(list.id, item);
    _lists = [list];
  }

  // ── Liste ─────────────────────────────────────────────────────────────────

  void selectList(int index) {
    _selectedListIndex = index;
    notifyListeners();
  }

  Future<void> addList(String name, String emoji) async {
    final list = TodoList(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name, emoji: emoji, createdAt: DateTime.now(),
    );
    await _db.insertList(list);
    _lists.add(list);
    _selectedListIndex = _lists.length - 1;
    notifyListeners();
  }

  Future<void> deleteList(String id) async {
    await _db.unlinkNotesForList(id);
    await _db.deleteList(id);
    _lists.removeWhere((l) => l.id == id);
    for (final n in _notes) { if (n.linkedListId == id) n.linkedListId = null; }
    if (_selectedListIndex >= _lists.length) {
      _selectedListIndex = _lists.isEmpty ? 0 : _lists.length - 1;
    }
    notifyListeners();
  }

  Future<void> renameList(String id, String newName, String newEmoji) async {
    final list = _lists.firstWhere((l) => l.id == id);
    list.name = newName; list.emoji = newEmoji;
    await _db.updateList(list);
    notifyListeners();
  }

  // ── Task ──────────────────────────────────────────────────────────────────

  Future<void> addItem(String listId, String title) async {
    final item = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title, createdAt: DateTime.now(),
    );
    await _db.insertItem(listId, item);
    _lists.firstWhere((l) => l.id == listId).items.add(item);
    notifyListeners();
  }

  Future<void> toggleItem(String listId, String itemId) async {
    final item = _lists.firstWhere((l) => l.id == listId)
        .items.firstWhere((i) => i.id == itemId);
    item.toggle();
    await _db.updateItem(listId, item);
    notifyListeners();
  }

  Future<void> deleteItem(String listId, String itemId) async {
    await _db.deleteItem(itemId);
    _lists.firstWhere((l) => l.id == listId)
        .items.removeWhere((i) => i.id == itemId);
    notifyListeners();
  }

  Future<void> editItem(String listId, String itemId, String newTitle) async {
    final item = _lists.firstWhere((l) => l.id == listId)
        .items.firstWhere((i) => i.id == itemId);
    item.title = newTitle;
    await _db.updateItem(listId, item);
    notifyListeners();
  }

  // ── Note ──────────────────────────────────────────────────────────────────

  Future<void> addNote({
    required String title,
    required String content,
    String? linkedListId,
  }) async {
    final now = DateTime.now();
    final note = Note(
      id: now.millisecondsSinceEpoch.toString(),
      title: title, content: content,
      createdAt: now, updatedAt: now,
      linkedListId: linkedListId,
    );
    await _db.insertNote(note);
    _notes.insert(0, note);
    notifyListeners();
  }

  Future<void> editNote({
    required String id,
    required String title,
    required String content,
    String? linkedListId,
  }) async {
    final note = _notes.firstWhere((n) => n.id == id);
    note.title = title; note.content = content;
    note.linkedListId = linkedListId;
    note.updatedAt = DateTime.now();
    await _db.updateNote(note);
    _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    notifyListeners();
  }

  Future<void> deleteNote(String id) async {
    await _db.deleteNote(id);
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  Future<void> linkNote(String noteId, String? listId) async {
    final note = _notes.firstWhere((n) => n.id == noteId);
    note.linkedListId = listId;
    note.updatedAt = DateTime.now();
    await _db.updateNote(note);
    notifyListeners();
  }
}
