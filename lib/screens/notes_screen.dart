import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/note.dart';
import 'note_editor_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});
  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      return Scaffold(
        backgroundColor: kBg,
        body: SafeArea(
          child: Column(children: [
            _header(state),
            _tabBar(),
            Expanded(child: TabBarView(
              controller: _tabs,
              children: [
                _allNotes(state),
                _byList(state),
              ],
            )),
          ]),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openEditor(state),
          backgroundColor: kNoteAccent, foregroundColor: kBg, elevation: 0,
          child: const Icon(Icons.add, size: 28),
        ),
      );
    });
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _header(AppState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(children: [
        RichText(text: const TextSpan(children: [
          TextSpan(text: 'NOTE', style: TextStyle(
            color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2)),
          TextSpan(text: 'S', style: TextStyle(
            color: kNoteAccent, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2)),
        ])),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: kNoteAccent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: kNoteAccent.withOpacity(0.25)),
          ),
          child: Text('${state.notes.length} appunti',
              style: const TextStyle(color: kNoteAccent, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  Widget _tabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 14, 24, 0),
      decoration: BoxDecoration(
        color: kSurface, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorder),
      ),
      child: TabBar(
        controller: _tabs,
        indicator: BoxDecoration(
          color: kNoteAccent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: kNoteAccent.withOpacity(0.35)),
        ),
        labelColor: kNoteAccent,
        unselectedLabelColor: Colors.white38,
        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        tabs: const [Tab(text: 'TUTTI'), Tab(text: 'PER LISTA')],
      ),
    );
  }

  // ── Tab: tutti ────────────────────────────────────────────────────────────

  Widget _allNotes(AppState state) {
    if (state.notes.isEmpty) return _empty('Nessun appunto.\nTocca + per crearne uno!');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 88),
      itemCount: state.notes.length,
      itemBuilder: (_, i) => _NoteCard(
        note: state.notes[i], state: state,
        onTap: () => _openEditor(state, note: state.notes[i]),
      ),
    );
  }

  // ── Tab: per lista ────────────────────────────────────────────────────────

  Widget _byList(AppState state) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 88),
      children: [
        // Standalone
        if (state.standaloneNotes.isNotEmpty) ...[
          _groupHeader('📌', 'Senza lista', state.standaloneNotes.length),
          ...state.standaloneNotes.map((n) => _NoteCard(
            note: n, state: state, onTap: () => _openEditor(state, note: n),
          )),
          const SizedBox(height: 8),
        ],
        // Per lista
        ...state.lists.map((list) {
          final linked = state.notesForList(list.id);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _groupHeader(list.emoji, list.name, linked.length),
              if (linked.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 2, 4, 10),
                  child: Text('Nessun appunto collegato',
                      style: TextStyle(color: Colors.white.withOpacity(0.18),
                          fontSize: 12, fontStyle: FontStyle.italic)),
                )
              else
                ...linked.map((n) => _NoteCard(
                  note: n, state: state, onTap: () => _openEditor(state, note: n),
                )),
              const SizedBox(height: 8),
            ],
          );
        }),
      ],
    );
  }

  Widget _groupHeader(String emoji, String name, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 15)),
        const SizedBox(width: 8),
        Text(name, style: const TextStyle(
          color: Colors.white60, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: kNoteAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: kNoteAccent.withOpacity(0.2)),
          ),
          child: Text('$count', style: const TextStyle(
            color: kNoteAccent, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  Widget _empty(String msg) => Center(
    child: Text(msg, textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white.withOpacity(0.18), fontSize: 14)),
  );

  void _openEditor(AppState state, {Note? note}) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider.value(
        value: state,
        child: NoteEditorScreen(note: note),
      ),
    ));
  }
}

// ── NoteCard ─────────────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  final Note note;
  final AppState state;
  final VoidCallback onTap;
  const _NoteCard({required this.note, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final linked = note.linkedListId != null
        ? state.lists.where((l) => l.id == note.linkedListId).firstOrNull
        : null;

    return Dismissible(
      key: ValueKey(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade900, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (_) => state.deleteNote(note.id),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kSurface, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorder),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(
                note.title.isEmpty ? 'Senza titolo' : note.title,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              )),
              const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
            ]),
            if (note.content.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(note.content,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 8),
            Row(children: [
              if (linked != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: kNoteAccent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: kNoteAccent.withOpacity(0.3)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(linked.emoji, style: const TextStyle(fontSize: 10)),
                    const SizedBox(width: 4),
                    Text(linked.name, style: const TextStyle(
                      color: kNoteAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                  ]),
                ),
                const SizedBox(width: 8),
              ],
              Text(_ago(note.updatedAt),
                  style: const TextStyle(color: Colors.white24, fontSize: 11)),
            ]),
          ]),
        ),
      ),
    );
  }

  String _ago(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1)  return 'adesso';
    if (diff.inHours   < 1)  return '${diff.inMinutes}m fa';
    if (diff.inDays    < 1)  return '${diff.inHours}h fa';
    if (diff.inDays    < 7)  return '${diff.inDays}g fa';
    return '${d.day}/${d.month}/${d.year}';
  }
}
