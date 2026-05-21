import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/todo_list.dart';
import '../models/note.dart';
import 'note_editor_screen.dart';

const kAccent = Color(0xFFE8FF47);
const kBg = Color(0xFF0D0D0D);
const kSurface = Color(0xFF1A1A1A);
const kBorder = Color(0xFF2A2A2A);

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final _addController = TextEditingController();
  bool _showAddField = false;

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final list = state.selectedList;
        return Scaffold(
          backgroundColor: kBg,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(state),
                _buildListSelector(state),
                if (list != null) ...[
                  _buildListHeader(list),
                  Expanded(child: _buildTaskList(context, state, list)),
                  if (_showAddField) _buildAddField(state, list),
                ],
              ],
            ),
          ),
          floatingActionButton: list == null ? null : _buildFAB(state, list),
        );
      },
    );
  }

  Widget _buildHeader(AppState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'TASK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                TextSpan(
                  text: 'R',
                  style: TextStyle(
                    color: kAccent,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _showAddListDialog(state),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: kAccent.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add, color: kAccent, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'NUOVA LISTA',
                    style: TextStyle(
                      color: kAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSelector(AppState state) {
    return Container(
      height: 52,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: state.lists.length,
        itemBuilder: (context, index) {
          final list = state.lists[index];
          final isSelected = index == state.selectedListIndex;
          return GestureDetector(
            onTap: () => state.selectList(index),
            onLongPress: () => _showListOptions(state, list),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? kAccent : kSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? kAccent : kBorder,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Text(list.emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    list.name.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? kBg : Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListHeader(TodoList list) {
    final pct = list.efficiency.toStringAsFixed(0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(list.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Text(
                      list.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${list.pendingItems} da fare  •  ${list.completedItems} completati',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kAccent.withOpacity(0.3)),
            ),
            child: Text(
              '$pct%',
              style: const TextStyle(
                color: kAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, AppState state, TodoList list) {
    if (list.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('[ ]', style: TextStyle(color: Colors.white12, fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Nessun task. Aggiungine uno!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.2),
                letterSpacing: 1,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    final pending = list.items.where((i) => !i.isCompleted).toList();
    final completed = list.items.where((i) => i.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        if (pending.isNotEmpty) ...[
          _sectionLabel('DA FARE', pending.length),
          ...pending.map((item) => _TaskTile(
                key: ValueKey(item.id),
                item: item,
                onToggle: () => state.toggleItem(list.id, item.id),
                onDelete: () => state.deleteItem(list.id, item.id),
                onEdit: (newTitle) =>
                    state.editItem(list.id, item.id, newTitle),
              )),
        ],
        if (completed.isNotEmpty) ...[
          const SizedBox(height: 8),
          _sectionLabel('COMPLETATI', completed.length),
          ...completed.map((item) => _TaskTile(
                key: ValueKey(item.id),
                item: item,
                onToggle: () => state.toggleItem(list.id, item.id),
                onDelete: () => state.deleteItem(list.id, item.id),
                onEdit: (newTitle) =>
                    state.editItem(list.id, item.id, newTitle),
              )),
        ],
        const SizedBox(height: 16),
        _buildLinkedNotes(context, state, list),
        const SizedBox(height: 88),
      ],
    );
  }

  Widget _buildLinkedNotes(BuildContext context, AppState state, TodoList list) {
    final notes = state.notesForList(list.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header sezione
        Row(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 0, 10),
            child: Row(children: [
              const Text('APPUNTI COLLEGATI', style: TextStyle(
                color: Colors.white30, fontSize: 10,
                fontWeight: FontWeight.bold, letterSpacing: 2,
              )),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(4)),
                child: Text('${notes.length}', style: const TextStyle(
                  color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ]),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) =>
                ChangeNotifierProvider.value(value: state,
                  child: NoteEditorScreen(prelinkedListId: list.id)))),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFFD166).withOpacity(0.4)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: const [
                Icon(Icons.add, color: Color(0xFFFFD166), size: 13),
                SizedBox(width: 3),
                Text('NOTA', style: TextStyle(
                  color: Color(0xFFFFD166), fontSize: 9,
                  fontWeight: FontWeight.bold, letterSpacing: 1)),
              ]),
            ),
          ),
        ]),
        // Lista note
        if (notes.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
            child: Text('Nessun appunto collegato a questa lista.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.18),
                  fontSize: 12, fontStyle: FontStyle.italic)),
          )
        else
          ...notes.map((n) => GestureDetector(
            onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) =>
                ChangeNotifierProvider.value(value: state,
                  child: NoteEditorScreen(note: n)))),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 3),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD166).withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFD166).withOpacity(0.18)),
              ),
              child: Row(children: [
                const Icon(Icons.sticky_note_2_outlined,
                    color: Color(0xFFFFD166), size: 15),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(n.title.isEmpty ? 'Senza titolo' : n.title,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (n.content.isNotEmpty)
                      Text(n.content,
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                )),
                const Icon(Icons.chevron_right, color: Colors.white24, size: 16),
              ]),
            ),
          )),
      ],
    );
  }

  Widget _sectionLabel(String label, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white30,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: kBorder,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddField(AppState state, TodoList list) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: kSurface,
        border: Border(top: BorderSide(color: kBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _addController,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'Nuovo task...',
                hintStyle: TextStyle(color: Colors.white24),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _submitTask(state, list),
            ),
          ),
          GestureDetector(
            onTap: () => _submitTask(state, list),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.arrow_upward, color: kBg, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  void _submitTask(AppState state, TodoList list) {
    final text = _addController.text.trim();
    if (text.isNotEmpty) {
      state.addItem(list.id, text);
      _addController.clear();
      HapticFeedback.lightImpact();
    }
    setState(() => _showAddField = false);
  }

  Widget _buildFAB(AppState state, TodoList list) {
    return FloatingActionButton(
      onPressed: () {
        setState(() => _showAddField = !_showAddField);
        if (_showAddField) HapticFeedback.selectionClick();
      },
      backgroundColor: kAccent,
      foregroundColor: kBg,
      elevation: 0,
      child: AnimatedRotation(
        turns: _showAddField ? 0.125 : 0,
        duration: const Duration(milliseconds: 200),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  void _showAddListDialog(AppState state) {
    final nameCtrl = TextEditingController();
    String selectedEmoji = '📋';
    final emojis = ['📋', '🛒', '📚', '💼', '🏠', '🎯', '⚡', '🌟', '🔥', '💡'];

    showModalBottomSheet(
      context: context,
      backgroundColor: kSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NUOVA LISTA',
                style: TextStyle(
                  color: kAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: emojis.map((e) {
                  final sel = e == selectedEmoji;
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedEmoji = e),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: sel ? kAccent.withOpacity(0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: sel ? kAccent : kBorder,
                        ),
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 20)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Nome lista...',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: kBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kAccent),
                  ),
                ),
                onSubmitted: (_) {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    state.addList(nameCtrl.text.trim(), selectedEmoji);
                    Navigator.pop(ctx);
                  }
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isNotEmpty) {
                      state.addList(nameCtrl.text.trim(), selectedEmoji);
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccent,
                    foregroundColor: kBg,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'CREA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showListOptions(AppState state, TodoList list) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${list.emoji} ${list.name}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _OptionTile(
              icon: Icons.edit_outlined,
              label: 'Rinomina lista',
              onTap: () {
                Navigator.pop(ctx);
                _showRenameDialog(state, list);
              },
            ),
            if (state.lists.length > 1)
              _OptionTile(
                icon: Icons.delete_outline,
                label: 'Elimina lista',
                isDestructive: true,
                onTap: () {
                  state.deleteList(list.id);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(AppState state, TodoList list) {
    final ctrl = TextEditingController(text: list.name);
    String selectedEmoji = list.emoji;
    final emojis = ['📋', '🛒', '📚', '💼', '🏠', '🎯', '⚡', '🌟', '🔥', '💡'];

    showModalBottomSheet(
      context: context,
      backgroundColor: kSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MODIFICA LISTA',
                style: TextStyle(
                  color: kAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: emojis.map((e) {
                  final sel = e == selectedEmoji;
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedEmoji = e),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: sel ? kAccent.withOpacity(0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: sel ? kAccent : kBorder),
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 20)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Nome lista...',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: kBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kAccent),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (ctrl.text.trim().isNotEmpty) {
                      state.renameList(list.id, ctrl.text.trim(), selectedEmoji);
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccent,
                    foregroundColor: kBg,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'SALVA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final Function(String) onEdit;

  const _TaskTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade900,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isCompleted
                ? kAccent.withOpacity(0.15)
                : kBorder,
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onToggle();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: item.isCompleted ? kAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: item.isCompleted ? kAccent : Colors.white30,
                  width: 1.5,
                ),
              ),
              child: item.isCompleted
                  ? const Icon(Icons.check, color: kBg, size: 16)
                  : null,
            ),
          ),
          title: Text(
            item.title,
            style: TextStyle(
              color:
                  item.isCompleted ? Colors.white24 : Colors.white,
              fontSize: 15,
              decoration:
                  item.isCompleted ? TextDecoration.lineThrough : null,
              decorationColor: Colors.white24,
            ),
          ),
          trailing: GestureDetector(
            onTap: () => _showEditDialog(context),
            child: const Icon(Icons.more_horiz, color: Colors.white24, size: 18),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final ctrl = TextEditingController(text: item.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'MODIFICA TASK',
          style: TextStyle(
            color: kAccent,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: kBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kAccent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ANNULLA', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                onEdit(ctrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('SALVA', style: TextStyle(color: kAccent)),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red.shade400 : Colors.white70;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color, size: 20),
      title: Text(
        label,
        style: TextStyle(color: color, fontSize: 15),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
