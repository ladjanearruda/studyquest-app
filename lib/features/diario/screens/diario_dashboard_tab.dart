// lib/features/diario/screens/diario_dashboard_tab.dart
// ✅ V9.5 - Sprint 9: Jornada com dados reais
// 📅 Atualizado: 15/03/2026

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/diary_provider.dart';
import '../models/diary_entry_model.dart';
import '../../niveis/providers/nivel_provider.dart';
import '../../niveis/models/nivel_model.dart';

class DiarioDashboardTab extends ConsumerStatefulWidget {
  final VoidCallback? onNavigateToRevisoes;

  const DiarioDashboardTab({super.key, this.onNavigateToRevisoes});

  @override
  ConsumerState<DiarioDashboardTab> createState() => _DiarioDashboardTabState();
}

class _DiarioDashboardTabState extends ConsumerState<DiarioDashboardTab> {
  // 12 matérias fixas do currículo: (ícone, nome, sigla)
  static const _materias = [
    ('📚', 'português',       'Port'),
    ('🔢', 'matemática',      'Mat'),
    ('🧬', 'biologia',        'Bio'),
    ('⚛️', 'física',          'Fís'),
    ('🧪', 'química',         'Quí'),
    ('📜', 'história',        'Hist'),
    ('🌍', 'geografia',       'Geo'),
    ('🤔', 'filosofia',       'Fil'),
    ('👥', 'sociologia',      'Soc'),
    ('🇬🇧', 'inglês',         'Ing'),
    ('🎨', 'artes',           'Art'),
    ('⚽', 'educação física', 'EdF'),
  ];

  // Normaliza o nome da matéria para comparação (remove acentos)
  String _normalizeSubject(String s) {
    const accented = 'áàâãéèêíìóôõúùûçÁÀÂÃÉÈÊÍÌÓÔÕÚÙÛÇ';
    const plain    = 'aaaaeeeiiooouuucAAAAEEEIIOOOUUUC';
    var result = s.toLowerCase().trim();
    for (int i = 0; i < accented.length; i++) {
      result = result.replaceAll(accented[i], plain[i].toLowerCase());
    }
    return result;
  }

  // Anotações criadas em cada dia da semana atual (dom=0...sab=6)
  List<int> _weeklyCountsFromEntries(List<DiaryEntry> entries) {
    final now = DateTime.now();
    // encontrar o início da semana (segunda-feira)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    final counts = List<int>.filled(7, 0); // seg=0 ... dom=6
    for (final e in entries) {
      final diff = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day)
          .difference(start)
          .inDays;
      if (diff >= 0 && diff < 7) {
        counts[diff]++;
      }
    }
    return counts;
  }

  // Distribuição de emoções: { emoji -> count }
  Map<String, int> _emotionCounts(List<DiaryEntry> entries) {
    final map = <String, int>{};
    for (final e in entries) {
      if (e.emotion.isEmpty) continue;
      map[e.emotion] = (map[e.emotion] ?? 0) + 1;
    }
    return map;
  }

  // Revisões pendentes: usa reviewUrgency para consistência com a aba Revisar
  List<DiaryEntry> _pendingReviews(List<DiaryEntry> entries) {
    return entries
        .where((e) =>
            e.reviewUrgency == ReviewUrgency.urgent ||
            e.reviewUrgency == ReviewUrgency.overdue ||
            e.reviewUrgency == ReviewUrgency.today)
        .toList()
      ..sort((a, b) {
        final da = a.nextReviewDate ?? DateTime(2000);
        final db = b.nextReviewDate ?? DateTime(2000);
        return da.compareTo(db);
      });
  }

  @override
  Widget build(BuildContext context) {
    final diaryState = ref.watch(diaryProvider);
    final nivel = ref.watch(nivelProvider);
    final entries = diaryState.entries;

    final weeklyCounts = _weeklyCountsFromEntries(entries);
    final emotionMap = _emotionCounts(entries);
    final pendingRevs = _pendingReviews(entries);
    final userResponses = diaryState.userResponses;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card 1: Resumo Rápido
          _buildResumoCard(nivel, diaryState.stats),
          const SizedBox(height: 16),

          // Card 2: Esta Semana
          _buildEvolucaoSemanalCard(weeklyCounts),
          const SizedBox(height: 16),

          // Card 2b: Performance Semanal
          _buildPerformanceSemanalCard(userResponses),
          const SizedBox(height: 16),

          // Card 3: Heatmap de Matérias
          _buildProgressoMateriasCard(entries),
          const SizedBox(height: 16),

          // Card 5: Hora de Revisar
          _buildRevisoesPendentesCard(pendingRevs),
          const SizedBox(height: 16),

          // Card 6: Humor de Estudo
          _buildHumorCard(emotionMap),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CARD 1: RESUMO RÁPIDO
  // ═══════════════════════════════════════════════════════════════
  Widget _buildResumoCard(NivelUsuario nivel, DiaryStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade500, Colors.green.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌟', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              const Text(
                'Sua Jornada',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${nivel.tier.emoji} ${nivel.tier.nome}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildResumoItem('XP Total', '${nivel.xpTotal}', '⭐'),
              _buildResumoItem('Nível', '${nivel.nivel}', '🌱'),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${nivel.xpNoNivel}/${nivel.xpParaProximo} XP para o próximo',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${(nivel.progresso * 100).round()}%',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: nivel.progresso,
                  minHeight: 10,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildResumoItem(
                  'Streak', '${stats.currentStreak} dias', '🔥'),
              _buildResumoItem('Anotações', '${stats.totalEntries}', '📝'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResumoItem(String label, String value, String emoji) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CARD 2: EVOLUÇÃO SEMANAL
  // ═══════════════════════════════════════════════════════════════
  Widget _buildEvolucaoSemanalCard(List<int> counts) {
    const labels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final maxCount = counts.reduce((a, b) => a > b ? a : b);
    final today = DateTime.now().weekday - 1; // 0=seg...6=dom
    final totalSemana = counts.reduce((a, b) => a + b);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('📈', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  const Text('Esta Semana',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$totalSemana anotações',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 110,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final count = counts[i];
                final ratio = maxCount > 0 ? count / maxCount : 0.0;
                final isToday = i == today;
                return _buildBarVertical(
                  label: labels[i],
                  ratio: ratio,
                  count: count,
                  isToday: isToday,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarVertical({
    required String label,
    required double ratio,
    required int count,
    required bool isToday,
  }) {
    final color = isToday ? Colors.green.shade600 : Colors.green.shade300;
    // Barra ocupa todo o espaço disponível menos label + gap
    // Container pai: 110px. Label ≈ 16px + gap 8px = 24px → barra max 86px.
    final barHeight = (82 * ratio + 8).clamp(8.0, 86.0);
    final showLabel = count > 0 && barHeight >= 20;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Barra com número sobreposto internamente (sem afetar o layout externo)
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: 32,
              height: barHeight,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            if (showLabel)
              Positioned(
                top: 4,
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isToday ? Colors.green.shade700 : Colors.grey.shade600,
            fontSize: 11,
            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CARD 2b: PERFORMANCE SEMANAL
  // ═══════════════════════════════════════════════════════════════

  /// Acertos e erros por dia da semana atual a partir de userResponses
  ({List<int> acertos, List<int> erros}) _weeklyPerformance(
      List<Map<String, dynamic>> responses) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    final acertos = List<int>.filled(7, 0);
    final erros = List<int>.filled(7, 0);

    for (final r in responses) {
      final answeredAt = r['answered_at'];
      if (answeredAt is! DateTime) continue;
      final day =
          DateTime(answeredAt.year, answeredAt.month, answeredAt.day);
      final diff = day.difference(start).inDays;
      if (diff < 0 || diff >= 7) continue;
      if (r['was_correct'] == true) {
        acertos[diff]++;
      } else {
        erros[diff]++;
      }
    }
    return (acertos: acertos, erros: erros);
  }

  Widget _buildPerformanceSemanalCard(
      List<Map<String, dynamic>> userResponses) {
    const dayLabels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final perf = _weeklyPerformance(userResponses);
    final totalAcertos = perf.acertos.fold(0, (a, b) => a + b);
    final totalErros = perf.erros.fold(0, (a, b) => a + b);
    final totalGeral = totalAcertos + totalErros;
    final hasData = totalGeral > 0;

    // Altura máxima = valor máximo dentre todos os dias
    final maxTotal = List.generate(
            7, (i) => perf.acertos[i] + perf.erros[i])
        .fold(0, (a, b) => a > b ? a : b);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          const Text('📊 Performance Semanal',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          const Text('Acertos vs Erros por dia',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),

          if (!hasData)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text('Jogue mais para ver sua performance!',
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 14)),
              ),
            )
          else ...[
            // Barras empilhadas
            SizedBox(
              height: 130,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (i) {
                  final total = perf.acertos[i] + perf.erros[i];
                  final maxH = 86.0;
                  final totalH = maxTotal > 0
                      ? (total / maxTotal * maxH).clamp(4.0, maxH)
                      : 0.0;
                  final acertosH = total > 0
                      ? totalH * perf.acertos[i] / total
                      : 0.0;
                  final errosH = totalH - acertosH;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Número total acima (só se tem dados)
                      if (total > 0)
                        Text('$total',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w600))
                      else
                        const SizedBox(height: 14),
                      const SizedBox(height: 2),
                      // Barra empilhada
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Erros (topo)
                            if (errosH > 0)
                              Container(
                                  width: 28,
                                  height: errosH,
                                  color: Colors.red.shade300),
                            // Acertos (base)
                            if (acertosH > 0)
                              Container(
                                  width: 28,
                                  height: acertosH,
                                  color: Colors.green.shade400),
                            // Placeholder se sem dados
                            if (total == 0)
                              Container(
                                  width: 28,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(dayLabels[i],
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500)),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            // Legenda com totais
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _perfLegendDot(Colors.green.shade400, '✅ Acertos'),
                const SizedBox(width: 4),
                Text(
                  '$totalAcertos (${totalGeral > 0 ? (totalAcertos / totalGeral * 100).round() : 0}%)',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 16),
                _perfLegendDot(Colors.red.shade300, '❌ Erros'),
                const SizedBox(width: 4),
                Text(
                  '$totalErros (${totalGeral > 0 ? (totalErros / totalGeral * 100).round() : 0}%)',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _perfLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style:
                TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CARD 3: HEATMAP DE MATÉRIAS
  // ═══════════════════════════════════════════════════════════════

  /// Cor de fundo da célula baseada na quantidade de anotações
  Color _heatColorSubject(int count) {
    if (count == 0) return const Color(0xFFEBEDF0);
    if (count == 1) return const Color(0xFF9BE9A8);
    if (count <= 3) return const Color(0xFF40C463);
    if (count <= 5) return const Color(0xFF30A14E);
    return const Color(0xFF216E39);
  }

  /// Cor do texto sobre a célula (escuro para fundos claros, branco para escuros)
  Color _heatTextColor(int count) {
    if (count >= 2) return Colors.white;
    return Colors.grey.shade800;
  }

  Widget _buildProgressoMateriasCard(List<DiaryEntry> entries) {
    // Contagem de anotações por matéria normalizada
    final counts = <String, int>{};
    for (final e in entries) {
      final key = _normalizeSubject(e.subject);
      counts[key] = (counts[key] ?? 0) + 1;
    }

    final totalAnnotations = entries.length;
    final withAnnotations =
        _materias.where((m) => (counts[_normalizeSubject(m.$2)] ?? 0) > 0).length;

    // Dividir as 12 matérias em 2 linhas de 6
    final row1 = _materias.sublist(0, 6);
    final row2 = _materias.sublist(6, 12);

    Widget buildCell((String, String, String) m) {
      final count = counts[_normalizeSubject(m.$2)] ?? 0;
      final bg = _heatColorSubject(count);
      final textColor = _heatTextColor(count);
      return Expanded(
        child: Container(
          margin: const EdgeInsets.all(3),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(m.$1, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 3),
              Text(
                m.$3,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          const Text('Anotações por Matéria',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          const Text(
            'Quanto mais você anota, mais intensa a cor!',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 14),
          // Linha 1
          Row(children: row1.map(buildCell).toList()),
          const SizedBox(height: 2),
          // Linha 2
          Row(children: row2.map(buildCell).toList()),
          const SizedBox(height: 14),
          // Legenda
          Row(
            children: [
              _legendDot(const Color(0xFFEBEDF0), '0', Colors.grey.shade700),
              const SizedBox(width: 10),
              _legendDot(const Color(0xFF9BE9A8), '1', Colors.grey.shade800),
              const SizedBox(width: 10),
              _legendDot(const Color(0xFF40C463), '2-3', Colors.white),
              const SizedBox(width: 10),
              _legendDot(const Color(0xFF30A14E), '4-5', Colors.white),
              const SizedBox(width: 10),
              _legendDot(const Color(0xFF216E39), '6+', Colors.white),
            ],
          ),
          const SizedBox(height: 10),
          // Totais
          Text(
            totalAnnotations == 0
                ? 'Erre e anote questões para começar!'
                : 'Total: $totalAnnotations anotaç${totalAnnotations != 1 ? 'ões' : 'ão'} em $withAnnotations matéri${withAnnotations != 1 ? 'as' : 'a'}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.grey.shade300, width: 0.5),
          ),
        ),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CARD 5: REVISÕES PENDENTES
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRevisoesPendentesCard(List<DiaryEntry> pending) {
    final count = pending.length;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Text('📅', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                const Text('Hora de Revisar!',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: count > 0 ? Colors.orange.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count > 0 ? '$count pendente${count != 1 ? 's' : ''}' : 'Em dia ✅',
                  style: TextStyle(
                    color: count > 0
                        ? Colors.orange.shade700
                        : Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (pending.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Nenhuma revisão pendente 🎉',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                ),
              ),
            )
          else ...[
            ...pending.take(3).map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildRevisaoItem(e),
                )),
            if (pending.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '+ ${pending.length - 3} mais pendente${pending.length - 3 != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.orange.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
          const SizedBox(height: 16),
          if (count > 0)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: widget.onNavigateToRevisoes,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Ver todas as revisões'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green.shade600,
                  side: BorderSide(color: Colors.green.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRevisaoItem(DiaryEntry entry) {
    final now = DateTime.now();
    final urgency = entry.reviewUrgency;
    final String emoji;
    final Color cor;
    final String tempo;

    switch (urgency) {
      case ReviewUrgency.urgent:
        emoji = '🔴';
        cor = Colors.red.shade600;
        final days = now.difference(entry.nextReviewDate!).inDays;
        tempo = '$days dia${days != 1 ? 's' : ''} atrasado';
        break;
      case ReviewUrgency.overdue:
        emoji = '🟡';
        cor = Colors.orange.shade600;
        tempo = 'atrasado';
        break;
      case ReviewUrgency.today:
        emoji = '🟠';
        cor = Colors.orange.shade400;
        tempo = 'hoje';
        break;
      default:
        emoji = '🟢';
        cor = Colors.green;
        tempo = 'no prazo';
    }

    final subject = entry.subject.isNotEmpty ? entry.subject : 'Sem matéria';
    final title = entry.questionText.length > 45
        ? '${entry.questionText.substring(0, 45)}…'
        : entry.questionText;

    return InkWell(
      onTap: widget.onNavigateToRevisoes,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isNotEmpty ? title : subject,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$subject · $tempo',
                    style: TextStyle(color: cor, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CARD 6: HUMOR DE ESTUDO
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHumorCard(Map<String, int> emotionMap) {
    if (emotionMap.isEmpty) {
      return _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Text('😊', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text('Seu Humor de Estudo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Adicione anotações com emoções para ver aqui',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    final total = emotionMap.values.fold(0, (a, b) => a + b);
    // Ordenar por frequência
    final sorted = emotionMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Cores para a barra empilhada
    final barColors = [
      Colors.green.shade400,
      Colors.lightGreen.shade400,
      Colors.amber.shade400,
      Colors.orange.shade400,
      Colors.red.shade400,
      Colors.purple.shade300,
    ];

    // Emoção mais frequente
    final topEmotion = sorted.first;
    final topPct = (topEmotion.value / total * 100).round();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('😊', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            const Text('Seu Humor de Estudo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 16),
          // Barra 100% empilhada
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 22,
              child: Row(
                children: sorted.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final e = entry.value;
                  final fraction = e.value / total;
                  return Flexible(
                    flex: (fraction * 1000).round(),
                    child: Container(
                      color: barColors[idx % barColors.length],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Legenda compacta
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: sorted.asMap().entries.map((entry) {
              final idx = entry.key;
              final e = entry.value;
              final pct = (e.value / total * 100).round();
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: barColors[idx % barColors.length],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(e.key, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 4),
                  Text('$pct%',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600)),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Insight
          Builder(builder: (context) {
            final isNeutral = topEmotion.key == '😐';
            final insightTitle = isNeutral
                ? 'Concentração é seu ponto forte! 💪'
                : 'Você estuda mais com ${topEmotion.key}!';
            final insightSub = isNeutral
                ? 'Baseado em $total anotações — $topPct% com foco constante'
                : 'Baseado em $total anotações — $topPct% com esse humor';
            return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insightTitle,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        insightSub,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
          }), // fim Builder
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPER: card base
  // ═══════════════════════════════════════════════════════════════
  Widget _card({required Widget child}) {
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
      child: child,
    );
  }
}
