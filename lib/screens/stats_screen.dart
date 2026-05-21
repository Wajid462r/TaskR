import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/todo_list.dart';
import 'list_screen.dart' show kAccent, kBg, kSurface, kBorder;

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: kBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: [
                _buildTitle(),
                const SizedBox(height: 24),
                _buildGlobalStats(state),
                const SizedBox(height: 28),
                _buildEfficiencyBar(state.globalEfficiency),
                const SizedBox(height: 32),
                _buildSectionLabel('STATISTICHE PER LISTA'),
                const SizedBox(height: 12),
                ...state.lists.map((l) => _buildListCard(l)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'STATISTICHE',
              style: TextStyle(
                color: kAccent,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Overview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        const Text('📊', style: TextStyle(fontSize: 32)),
      ],
    );
  }

  Widget _buildGlobalStats(AppState state) {
    return Row(
      children: [
        Expanded(
          child: _StatBox(
            label: 'TOTALI',
            value: '${state.globalTotal}',
            color: Colors.white70,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatBox(
            label: 'DA FARE',
            value: '${state.globalPending}',
            color: const Color(0xFFFF9F47),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatBox(
            label: 'FATTI',
            value: '${state.globalCompleted}',
            color: kAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildEfficiencyBar(double efficiency) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'EFFICIENZA GLOBALE',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Text(
                '${efficiency.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: kAccent,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: kBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: efficiency / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF47B8FF), kAccent],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _getMotivationalText(efficiency),
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _getMotivationalText(double e) {
    if (e == 0) return 'Inizia completando il tuo primo task!';
    if (e < 25) return 'Sei agli inizi. Puoi farcela!';
    if (e < 50) return 'Buon progresso, continua così!';
    if (e < 75) return 'Ottimo lavoro, sei a metà strada!';
    if (e < 100) return 'Quasi perfetto, stai andando alla grande!';
    return '🎉 Perfetto! Hai completato tutto!';
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white30,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildListCard(TodoList list) {
    final efficiency = list.efficiency;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(list.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  list.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _efficiencyColor(efficiency).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _efficiencyColor(efficiency).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '${efficiency.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: _efficiencyColor(efficiency),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MiniStat(label: 'TOT', value: '${list.totalItems}', color: Colors.white54),
              const SizedBox(width: 16),
              _MiniStat(label: 'DA FARE', value: '${list.pendingItems}', color: const Color(0xFFFF9F47)),
              const SizedBox(width: 16),
              _MiniStat(label: 'FATTI', value: '${list.completedItems}', color: kAccent),
            ],
          ),
          if (list.totalItems > 0) ...[
            const SizedBox(height: 12),
            Stack(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: kBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: efficiency / 100,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: _efficiencyColor(efficiency),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _efficiencyColor(double e) {
    if (e < 33) return Colors.red.shade400;
    if (e < 66) return const Color(0xFFFF9F47);
    return kAccent;
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white30,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white30,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
