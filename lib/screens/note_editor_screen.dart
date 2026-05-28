import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/note.dart';

// Costanti condivise col resto dell'app
const kAccent     = Color(0xFFE8FF47);
const kBg         = Color(0xFF0D0D0D);
const kSurface    = Color(0xFF1A1A1A);
const kBorder     = Color(0xFF2A2A2A);
const kNoteAccent = Color(0xFFFFD166); // giallo-arancio per le note

class NoteEditorScreen extends StatefulWidget {
  final Note?   note;              // null = nuova nota
  final String? prelinkedListId;   // pre-seleziona lista alla creazione

  const NoteEditorScreen({super.key, this.note, this.prelinkedListId});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  String? _linkedListId;

  @override
  void initState() {
    super.initState();
    _titleCtrl   = TextEditingController(text: widget.note?.title   ?? '');
    _contentCtrl = TextEditingController(text: widget.note?.content ?? '');
    _linkedListId = widget.note?.linkedListId ?? widget.prelinkedListId;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _save(state);
        if (context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: kBg,
        appBar: _appBar(state),
        body: _body(),
      ),
    );
  }

  PreferredSizeWidget _appBar(AppState state) {
    final linked = _linkedListId != null
        ? state.lists.where((l) => l.id == _linkedListId).firstOrNull
        : null;

    return AppBar(
      backgroundColor: kBg,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white54, size: 18),
        onPressed: () async {
          await _save(state);
          if (context.mounted) Navigator.pop(context);
        },
      ),
      title: GestureDetector(
        onTap: () => _showLinkSheet(state),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: linked != null ? kNoteAccent.withOpacity(0.1) : kSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: linked != null
                  ? kNoteAccent.withOpacity(0.5)
                  : kBorder,
            ),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(
              linked != null ? Icons.link_rounded : Icons.link_off_rounded,
              color: linked != null ? kNoteAccent : Colors.white38,
              size: 15,
            ),
            const SizedBox(width: 6),
            Text(
              linked != null ? '${linked.emoji}  ${linked.name}' : 'Collega a lista',
              style: TextStyle(
                color: linked != null ? kNoteAccent : Colors.white38,
                fontSize: 12, fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.expand_more, color: linked != null ? kNoteAccent : Colors.white24, size: 14),
          ]),
        ),
      ),
      actions: [
        if (widget.note != null)
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
            onPressed: () => _confirmDelete(state),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextButton(
            onPressed: () async {
              await _save(state);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('SALVA',
                style: TextStyle(color: kNoteAccent, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ),
      ],
    );
  }

Widget _body() {
  return SafeArea(
    child: AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                kToolbarHeight -
                MediaQuery.of(context).padding.top,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  TextField(
                    controller: _titleCtrl,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Titolo',
                      hintStyle: TextStyle(
                        color: Colors.white24,
                        fontSize: 22,
                      ),
                      border: InputBorder.none,
                    ),
                  ),

                  Divider(color: kBorder, height: 1),

                  const SizedBox(height: 12),

                  Expanded(
                    child: TextField(
                      controller: _contentCtrl,
                      keyboardType: TextInputType.multiline,
                      minLines: 10,
                      maxLines: null,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.65,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Scrivi i tuoi appunti...',
                        hintStyle: TextStyle(color: Colors.white24),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
  Future<void> _save(AppState state) async {
    final title   = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.isEmpty && content.isEmpty) return;
    final safeTitle = title.isEmpty ? 'Senza titolo' : title;

    if (widget.note == null) {
      await state.addNote(title: safeTitle, content: content, linkedListId: _linkedListId);
    } else {
      await state.editNote(id: widget.note!.id, title: safeTitle, content: content, linkedListId: _linkedListId);
    }
  }

  void _showLinkSheet(AppState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('COLLEGA A LISTA', style: TextStyle(
                color: kNoteAccent, fontSize: 11,
                fontWeight: FontWeight.bold, letterSpacing: 2,
              )),
              const SizedBox(height: 16),
              _LinkOption(
                emoji: '🚫', name: 'Nessuna lista',
                isSelected: _linkedListId == null,
                onTap: () { setState(() => _linkedListId = null); Navigator.pop(ctx); },
              ),
              const SizedBox(height: 4),
              ...state.lists.map((l) => _LinkOption(
                emoji: l.emoji, name: l.name,
                isSelected: _linkedListId == l.id,
                onTap: () { setState(() => _linkedListId = l.id); Navigator.pop(ctx); },
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Elimina nota', style: TextStyle(color: Colors.white)),
        content: const Text('Questa nota verrà eliminata definitivamente.',
            style: TextStyle(color: Colors.white54)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('ANNULLA', style: TextStyle(color: Colors.white38))),
          TextButton(
            onPressed: () {
              state.deleteNote(widget.note!.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('ELIMINA', style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
  }
}

class _LinkOption extends StatelessWidget {
  final String emoji, name;
  final bool isSelected;
  final VoidCallback onTap;
  const _LinkOption({required this.emoji, required this.name, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? kNoteAccent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? kNoteAccent.withOpacity(0.5) : kBorder),
        ),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: TextStyle(
            color: isSelected ? kNoteAccent : Colors.white70,
            fontSize: 14, fontWeight: FontWeight.w500,
          ))),
          if (isSelected) const Icon(Icons.check_rounded, color: kNoteAccent, size: 18),
        ]),
      ),
    );
  }
}
