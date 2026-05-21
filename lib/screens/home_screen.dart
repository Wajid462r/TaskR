import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'list_screen.dart';
import 'notes_screen.dart';
import 'stats_screen.dart';
import 'note_editor_screen.dart' show kNoteAccent;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _screens = const [ListScreen(), NotesScreen(), StatsScreen()];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(builder: (context, state, _) {
        // Schermata di caricamento mentre SQLite inizializza
        if (state.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFF0D0D0D),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFE8FF47), strokeWidth: 2),
            ),
          );
        }
        return Scaffold(
          backgroundColor: const Color(0xFF0D0D0D),
          body: IndexedStack(index: _currentIndex, children: _screens),
          bottomNavigationBar: _nav(),
        );
      }),
    );
  }

  Widget _nav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border(top: BorderSide(
          color: const Color(0xFFE8FF47).withOpacity(0.12), width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _NavItem(icon: Icons.checklist_rounded,      label: 'LISTA',  idx: 0, current: _currentIndex, onTap: _go),
            _NavItem(icon: Icons.sticky_note_2_outlined, label: 'NOTE',   idx: 1, current: _currentIndex, onTap: _go, accent: kNoteAccent),
            _NavItem(icon: Icons.bar_chart_rounded,      label: 'STATS',  idx: 2, current: _currentIndex, onTap: _go),
          ]),
        ),
      ),
    );
  }

  void _go(int i) => setState(() => _currentIndex = i);
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String   label;
  final int      idx, current;
  final void Function(int) onTap;
  final Color?   accent;

  const _NavItem({
    required this.icon, required this.label,
    required this.idx,  required this.current,
    required this.onTap, this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final color = accent ?? kAccent;
    final sel   = idx == current;
    return GestureDetector(
      onTap: () => onTap(idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          color: sel ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: sel ? Border.all(color: color.withOpacity(0.3)) : null,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: sel ? color : Colors.white38, size: 22),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(
            color: sel ? color : Colors.white38,
            fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5,
          )),
        ]),
      ),
    );
  }
}
