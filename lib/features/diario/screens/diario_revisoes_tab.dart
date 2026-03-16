// lib/features/diario/screens/diario_revisoes_tab.dart
// ✅ V9.5 - Sprint 9: Spaced Repetition + Calendário real + Modal de revisão
// 📅 Atualizado: 15/03/2026

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/diary_provider.dart';
import '../models/diary_entry_model.dart';
import '../../niveis/providers/nivel_provider.dart';

enum _DayStatus { overdue, today, upcoming }

class DiarioRevisoesTab extends ConsumerStatefulWidget {
  const DiarioRevisoesTab({super.key});

  @override
  ConsumerState<DiarioRevisoesTab> createState() => _DiarioRevisoesTabState();
}

class _DiarioRevisoesTabState extends ConsumerState<DiarioRevisoesTab> {
  DateTime _calendarMonth =
      DateTime(DateTime.now().year, DateTime.now().month);
  bool _isProcessingReview = false;

  // ─── Helpers ────────────────────────────────────────────────

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  /// Mapeia dia do mês → status mais urgente das revisões daquele dia
  Map<int, _DayStatus> _buildDayStatusMap(List<DiaryEntry> pendentes) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final map = <int, _DayStatus>{};

    for (final entry in pendentes) {
      if (entry.nextReviewDate == null) continue;
      final d = entry.nextReviewDate!;
      if (!_isSameMonth(d, _calendarMonth)) continue;

      final dayDate = DateTime(d.year, d.month, d.day);
      final isOverdue = dayDate.isBefore(today);
      final isToday = _isSameDay(d, now);
      final newStatus =
          isOverdue ? _DayStatus.overdue : isToday ? _DayStatus.today : _DayStatus.upcoming;

      final current = map[d.day];
      // Upgrade priority: overdue > today > upcoming
      if (current == null ||
          (current != _DayStatus.overdue && newStatus == _DayStatus.overdue) ||
          (current == _DayStatus.upcoming && newStatus == _DayStatus.today)) {
        map[d.day] = newStatus;
      }
    }
    return map;
  }

  /// Mapeia dia do mês → número de revisões agendadas naquele dia
  Map<int, int> _buildDayCountMap(List<DiaryEntry> pendentes) {
    final map = <int, int>{};
    for (final entry in pendentes) {
      if (entry.nextReviewDate == null) continue;
      final d = entry.nextReviewDate!;
      if (!_isSameMonth(d, _calendarMonth)) continue;
      map[d.day] = (map[d.day] ?? 0) + 1;
    }
    return map;
  }

  // ─── Review modal ────────────────────────────────────────────

  Future<void> _showRevisaoModal(DiaryEntry entry) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _RevisaoDialog(entry: entry),
    );
    if (result == null || !mounted) return;

    setState(() => _isProcessingReview = true);
    try {
      final xpGanho =
          await ref.read(diaryProvider.notifier).completeReview(entry.id, dominei: result);

      if (xpGanho > 0) {
        await ref.read(nivelProvider.notifier).adicionarXp(xpGanho);
      }

      if (!mounted) return;
      final msg = result ? '🏆 Dominou! +$xpGanho XP' : '🔄 Revisão agendada para amanhã';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: result ? Colors.green.shade600 : Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessingReview = false);
    }
  }

  // ─── Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final diaryState = ref.watch(diaryProvider);
    final entries = diaryState.entries;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Categorizar entradas não dominadas
    final pendentes = entries.where((e) => !e.mastered).toList();

    final atrasadas = pendentes
        .where((e) =>
            e.reviewUrgency == ReviewUrgency.urgent ||
            e.reviewUrgency == ReviewUrgency.overdue)
        .toList()
      ..sort((a, b) => (a.nextReviewDate ?? DateTime(2000))
          .compareTo(b.nextReviewDate ?? DateTime(2000)));

    final paraHoje =
        pendentes.where((e) => e.reviewUrgency == ReviewUrgency.today).toList();

    final proximas = pendentes
        .where((e) =>
            e.reviewUrgency == ReviewUrgency.onTime &&
            e.nextReviewDate != null &&
            e.nextReviewDate!.isBefore(today.add(const Duration(days: 8))))
        .toList()
      ..sort((a, b) => a.nextReviewDate!.compareTo(b.nextReviewDate!));

    final dominadas = entries.where((e) => e.mastered).length;
    final dayStatusMap = _buildDayStatusMap(pendentes);
    final dayCountMap = _buildDayCountMap(pendentes);

    if (diaryState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResumoCard(
              atrasadas.length, paraHoje.length, proximas.length, dominadas,
              pendentesUrgentes: [...atrasadas, ...paraHoje]),
          const SizedBox(height: 20),
          _buildCalendario(dayStatusMap, dayCountMap),
          const SizedBox(height: 20),

          // Seção: Atrasadas
          if (atrasadas.isNotEmpty) ...[
            _buildSectionTitle('🔴 Atrasadas', atrasadas.length, Colors.red.shade700),
            const SizedBox(height: 10),
            ...atrasadas.map((e) => _buildRevisaoCard(context, e)),
            const SizedBox(height: 20),
          ],

          // Seção: Hoje
          if (paraHoje.isNotEmpty) ...[
            _buildSectionTitle('🟡 Para Hoje', paraHoje.length, Colors.orange.shade700),
            const SizedBox(height: 10),
            ...paraHoje.map((e) => _buildRevisaoCard(context, e)),
            const SizedBox(height: 20),
          ],

          // Seção: Próximos 7 dias
          if (proximas.isNotEmpty) ...[
            _buildSectionTitle(
                '🟢 Próximos 7 dias', proximas.length, Colors.green.shade700),
            const SizedBox(height: 10),
            ...proximas.map((e) => _buildRevisaoCard(context, e)),
            const SizedBox(height: 20),
          ],

          // Estado vazio
          if (pendentes.isEmpty) _buildEmptyState(entries.isEmpty),

          _buildInfoSpacedRepetition(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Widgets ─────────────────────────────────────────────────

  Widget _buildResumoCard(
    int atrasadas,
    int hoje,
    int proximas,
    int dominadas, {
    required List<DiaryEntry> pendentesUrgentes,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.purple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('📅', style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Text(
                'Suas Revisões',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('🔴', atrasadas.toString(), 'Atrasadas'),
              _buildStat('🟡', hoje.toString(), 'Hoje'),
              _buildStat('🟢', proximas.toString(), 'Em dia'),
              _buildStat('✅', dominadas.toString(), 'Dominadas'),
            ],
          ),
          if (pendentesUrgentes.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessingReview
                    ? null
                    : () => _showRevisaoModal(pendentesUrgentes.first),
                icon: const Icon(Icons.play_arrow),
                label: Text('Revisar agora (${atrasadas + hoje})'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.purple.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStat(String emoji, String valor, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(valor,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildCalendario(
      Map<int, _DayStatus> dayStatusMap, Map<int, int> dayCountMap) {
    const monthNames = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];

    final now = DateTime.now();
    final daysInMonth =
        DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0).day;
    // Dart: Monday=1..Sunday=7. We want Sunday-first grid (D S T Q Q S S).
    // firstWeekday: 0=Sun, 1=Mon, ..., 6=Sat
    final firstWeekday =
        DateTime(_calendarMonth.year, _calendarMonth.month, 1).weekday % 7;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cabeçalho do mês
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${monthNames[_calendarMonth.month - 1]} ${_calendarMonth.year}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => setState(() {
                      _calendarMonth = DateTime(
                          _calendarMonth.year, _calendarMonth.month - 1);
                    }),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => setState(() {
                      _calendarMonth = DateTime(
                          _calendarMonth.year, _calendarMonth.month + 1);
                    }),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Dias da semana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['D', 'S', 'T', 'Q', 'Q', 'S', 'S']
                .map((d) => SizedBox(
                      width: 36,
                      child: Center(
                        child: Text(d,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            )),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),

          // Grid do mês
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: firstWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < firstWeekday) return const SizedBox();
              final day = index - firstWeekday + 1;
              final isToday =
                  day == now.day && _isSameMonth(_calendarMonth, now);
              final status = dayStatusMap[day];
              final count = dayCountMap[day] ?? 0;

              Color? bgColor;
              Color textColor = Colors.grey.shade700;
              Border? border;
              Color badgeColor;

              if (isToday) {
                bgColor = Colors.green.shade500;
                textColor = Colors.white;
                badgeColor = Colors.white.withValues(alpha: 0.85);
              } else if (status == _DayStatus.overdue) {
                bgColor = Colors.red.shade100;
                badgeColor = Colors.red.shade600;
              } else if (status == _DayStatus.today) {
                bgColor = Colors.orange.shade100;
                badgeColor = Colors.orange.shade700;
              } else if (status == _DayStatus.upcoming) {
                bgColor = Colors.purple.shade50;
                border = Border.all(color: Colors.purple.shade100);
                badgeColor = Colors.purple.shade600;
              } else {
                border = Border.all(color: Colors.grey.shade200);
                badgeColor = Colors.grey.shade500;
              }

              return Stack(
                children: [
                  // Célula do dia
                  Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                      border: border,
                    ),
                    child: Center(
                      child: Text('$day',
                          style: TextStyle(
                            color: textColor,
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          )),
                    ),
                  ),
                  // Badge de contagem
                  if (count > 0)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: isToday
                              ? Colors.white.withValues(alpha: 0.9)
                              : badgeColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: isToday
                                  ? Colors.green.shade700
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Legenda
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(Colors.red.shade100, 'Atrasada'),
              const SizedBox(width: 12),
              _buildLegend(Colors.orange.shade100, 'Pendente'),
              const SizedBox(width: 12),
              _buildLegend(Colors.purple.shade50, 'Agendada'),
              const SizedBox(width: 12),
              _buildLegend(Colors.green.shade500, 'Hoje'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color cor, String texto) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration:
              BoxDecoration(color: cor, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(texto,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
      ],
    );
  }

  Widget _buildSectionTitle(String title, int count, Color color) {
    return Row(
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('$count',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildRevisaoCard(BuildContext context, DiaryEntry entry) {
    final urgency = entry.reviewUrgency;
    final now = DateTime.now();

    final Color cor;
    final String urgencyLabel;
    final String subtitulo;

    switch (urgency) {
      case ReviewUrgency.urgent:
        cor = Colors.red;
        urgencyLabel = '🔴 Urgente';
        final days = entry.nextReviewDate != null
            ? now.difference(entry.nextReviewDate!).inDays
            : 0;
        subtitulo = 'Atrasado há $days dias';
      case ReviewUrgency.overdue:
        cor = Colors.red.shade400;
        urgencyLabel = '🔴 Atrasada';
        final days = entry.nextReviewDate != null
            ? now.difference(entry.nextReviewDate!).inDays
            : 1;
        subtitulo = days == 1 ? 'Atrasado há 1 dia' : 'Atrasado há $days dias';
      case ReviewUrgency.today:
        cor = Colors.orange;
        urgencyLabel = '🟡 Hoje';
        subtitulo = 'Revisar hoje';
      case ReviewUrgency.onTime:
        cor = Colors.green;
        urgencyLabel = '🟢 Em dia';
        if (entry.nextReviewDate != null) {
          final days = entry.nextReviewDate!.difference(now).inDays;
          subtitulo = days == 0
              ? 'Amanhã'
              : days == 1
                  ? 'Em 1 dia'
                  : 'Em $days dias';
        } else {
          subtitulo = 'Agendada';
        }
    }

    final letra = entry.subject.isNotEmpty
        ? entry.subject[0].toUpperCase()
        : '?';

    return GestureDetector(
      onTap: () => _showRevisaoModal(entry),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cor.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Badge da matéria
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(letra,
                    style: TextStyle(
                        color: cor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),

            // Conteúdo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(entry.subject,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: cor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(urgencyLabel,
                            style: TextStyle(
                                color: cor,
                                fontWeight: FontWeight.bold,
                                fontSize: 9)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.questionText.length > 70
                        ? '${entry.questionText.substring(0, 70)}...'
                        : entry.questionText,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(subtitulo,
                          style: TextStyle(
                              color: cor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                      Text('${entry.timesReviewed}/5 revisões',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool noEntries) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(noEntries ? '📒' : '🎉',
              style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            noEntries ? 'Nenhuma anotação ainda' : 'Tudo em dia!',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            noEntries
                ? 'Erre uma questão e anote a lição para\ncriar seu sistema de revisões!'
                : 'Continue praticando para novos erros e\nnovas anotações aparecerem aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, height: 1.5),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInfoSpacedRepetition() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🧠', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text('Repetição Espaçada',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue.shade800)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Revisamos seus erros em intervalos crescentes para maximizar a retenção:',
            style: TextStyle(
                color: Colors.grey.shade700, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIntervalo('1º', '1 dia'),
              Icon(Icons.arrow_forward, size: 14, color: Colors.grey.shade400),
              _buildIntervalo('2º', '3 dias'),
              Icon(Icons.arrow_forward, size: 14, color: Colors.grey.shade400),
              _buildIntervalo('3º', '7 dias'),
              Icon(Icons.arrow_forward, size: 14, color: Colors.grey.shade400),
              _buildIntervalo('4º', '14 dias'),
              Icon(Icons.arrow_forward, size: 14, color: Colors.grey.shade400),
              _buildIntervalo('5º', '30 dias'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Text('📈', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '+40% de retenção comprovado cientificamente!',
                    style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                        fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalo(String numero, String dias) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(numero,
                style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 10)),
          ),
        ),
        const SizedBox(height: 4),
        Text(dias,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 9)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// 🪟 MODAL DE REVISÃO
// ─────────────────────────────────────────────────────────

class _RevisaoDialog extends StatefulWidget {
  final DiaryEntry entry;

  const _RevisaoDialog({required this.entry});

  @override
  State<_RevisaoDialog> createState() => _RevisaoDialogState();
}

class _RevisaoDialogState extends State<_RevisaoDialog> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(entry.subject,
                        style: TextStyle(
                            color: Colors.purple.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                  const Spacer(),
                  Text('Revisão ${entry.timesReviewed + 1}/5',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 18, color: Colors.grey.shade400),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Barra de progresso ───────────────────────────
              Row(
                children: List.generate(5, (i) {
                  final done = i < entry.timesReviewed;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 6,
                      decoration: BoxDecoration(
                        color: done
                            ? Colors.purple.shade400
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // ── Questão ──────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  entry.questionText,
                  style: const TextStyle(fontSize: 13, height: 1.5),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),

              // ── Minha anotação ────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text('Minha anotação',
                            style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.userNote.isNotEmpty
                          ? entry.userNote
                          : 'Sem anotação registrada.',
                      style: TextStyle(
                          color: Colors.green.shade800,
                          fontSize: 13,
                          height: 1.4),
                    ),
                    if (entry.userStrategy.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Divider(color: Colors.green.shade200, height: 1),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🎯', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(entry.userStrategy,
                                style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 12,
                                    height: 1.4)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Área de decisão ──────────────────────────────
              if (!_revealed) ...[
                Center(
                  child: Text('Você lembra como resolver?',
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 13)),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => setState(() => _revealed = true),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Ver resposta correta'),
                  ),
                ),
              ] else ...[
                // Resposta correta
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('✅ Resposta correta:',
                          style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(entry.correctAnswer,
                          style: TextStyle(
                              color: Colors.blue.shade800, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Como foi?',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),

                Row(
                  children: [
                    // Precisa revisar mais
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade50,
                          foregroundColor: Colors.orange.shade800,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          side: BorderSide(color: Colors.orange.shade200),
                        ),
                        child: const Column(
                          children: [
                            Text('🔄', style: TextStyle(fontSize: 22)),
                            SizedBox(height: 4),
                            Text('Revisar mais',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Dominei
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Column(
                          children: [
                            Text('🏆', style: TextStyle(fontSize: 22)),
                            SizedBox(height: 4),
                            Text('Dominei! +5 XP',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
