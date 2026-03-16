// lib/features/diario/screens/diario_insights_tab.dart
// ✅ V9.6 - Sprint 9: Análise de Revisões + Domínio
// 📅 Atualizado: 15/03/2026

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/diary_provider.dart';
import '../models/diary_entry_model.dart';

// ─────────────────────────────────────────────────────────
class DiarioInsightsTab extends ConsumerWidget {
  const DiarioInsightsTab({super.key});

  // 12 matérias fixas (mesma lista do dashboard)
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

  // ── Normalização (mesma lógica do dashboard) ──────────
  String _normalizeSubject(String s) {
    const accented = 'áàâãéèêíìóôõúùûçÁÀÂÃÉÈÊÍÌÓÔÕÚÙÛÇ';
    const plain    = 'aaaaeeeiiooouuucAAAAEEEIIOOOUUUC';
    var result = s.toLowerCase().trim();
    for (int i = 0; i < accented.length; i++) {
      result = result.replaceAll(accented[i], plain[i].toLowerCase());
    }
    return result;
  }

  // ── Helpers de dados ─────────────────────────────────

  /// Soma total de timesReviewed por matéria
  Map<String, int> _reviewsPerSubject(List<DiaryEntry> entries) {
    final map = <String, int>{};
    for (final e in entries) {
      if (e.timesReviewed <= 0) continue;
      final key = _normalizeSubject(e.subject);
      if (key.isEmpty) continue;
      map[key] = (map[key] ?? 0) + e.timesReviewed;
    }
    return map;
  }

  /// Contagem de anotações com mastered=true por matéria
  Map<String, int> _masteredPerSubject(List<DiaryEntry> entries) {
    final map = <String, int>{};
    for (final e in entries) {
      if (!e.mastered) continue;
      final key = _normalizeSubject(e.subject);
      if (key.isEmpty) continue;
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  /// Revisões realizadas por dia nos últimos 7 dias (aproximação via nextReviewDate)
  /// lastReviewDate ≈ nextReviewDate - intervals[timesReviewed]
  List<FlSpot> _weeklyReviewSpots(List<DiaryEntry> entries) {
    const intervals = [1, 3, 7, 14, 30];
    final now = DateTime.now();
    final counts = List<int>.filled(7, 0);

    for (final e in entries) {
      if (e.timesReviewed <= 0 || e.nextReviewDate == null) continue;
      final interval =
          intervals[e.timesReviewed.clamp(0, intervals.length - 1)];
      final lastReview = e.nextReviewDate!.subtract(Duration(days: interval));
      final lastReviewDay =
          DateTime(lastReview.year, lastReview.month, lastReview.day);

      for (int i = 0; i < 7; i++) {
        final day = DateTime(now.year, now.month, now.day - (6 - i));
        if (lastReviewDay == day) {
          counts[i]++;
          break;
        }
      }
    }
    return List.generate(7, (i) => FlSpot(i.toDouble(), counts[i].toDouble()));
  }

  /// Anotações criadas por dia nos últimos 7 dias
  List<FlSpot> _weeklySpots(List<DiaryEntry> entries) {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = DateTime(now.year, now.month, now.day - (6 - i));
      final count = entries
          .where((e) =>
              e.createdAt.year == day.year &&
              e.createdAt.month == day.month &&
              e.createdAt.day == day.day)
          .length;
      return FlSpot(i.toDouble(), count.toDouble());
    });
  }

  List<String> _weekLabels() {
    const abbrev = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = DateTime(now.year, now.month, now.day - (6 - i));
      return i == 6 ? 'Hj' : abbrev[day.weekday % 7];
    });
  }

  /// Insights automáticos focados em revisões e domínio
  List<_Insight> _generateInsights(List<DiaryEntry> entries) {
    final insights = <_Insight>[];
    if (entries.isEmpty) return insights;

    // Matéria com mais revisões pendentes
    final pendingBySubj = <String, int>{};
    for (final e in entries) {
      if (e.needsReview) {
        final k = e.subject.isNotEmpty ? e.subject : 'Geral';
        pendingBySubj[k] = (pendingBySubj[k] ?? 0) + 1;
      }
    }
    if (pendingBySubj.isNotEmpty) {
      final top =
          pendingBySubj.entries.reduce((a, b) => a.value > b.value ? a : b);
      insights.add(_Insight(
        emoji: '⏰',
        text:
            '${top.key} tem ${top.value} anotaç${top.value == 1 ? 'ão' : 'ões'} pendente${top.value == 1 ? '' : 's'} de revisão',
        color: Colors.orange,
      ));
    }

    // Matéria com mais lições dominadas
    final mastBySubj = <String, int>{};
    for (final e in entries) {
      if (e.mastered) {
        final k = e.subject.isNotEmpty ? e.subject : 'Geral';
        mastBySubj[k] = (mastBySubj[k] ?? 0) + 1;
      }
    }
    if (mastBySubj.isNotEmpty) {
      final top =
          mastBySubj.entries.reduce((a, b) => a.value > b.value ? a : b);
      insights.add(_Insight(
        emoji: '🏆',
        text:
            'Você dominou ${top.value} tópico${top.value == 1 ? '' : 's'} de ${top.key}!',
        color: Colors.green,
      ));
    }

    // Taxa de revisão geral
    final reviewed = entries.where((e) => e.timesReviewed > 0).length;
    if (reviewed > 0 && entries.length > reviewed) {
      final pct = (reviewed / entries.length * 100).round();
      insights.add(_Insight(
        emoji: '📈',
        text: '$pct% das anotações já foram revisadas. Continue assim!',
        color: Colors.blue,
      ));
    }

    // Motivacional se ainda sem revisões
    if (reviewed == 0) {
      insights.add(_Insight(
        emoji: '💡',
        text: 'Revise suas anotações para fixar o conteúdo!',
        color: Colors.purple,
      ));
    }

    return insights.take(3).toList();
  }

  // ── Build principal ──────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryState = ref.watch(diaryProvider);
    final entries = diaryState.entries;

    if (diaryState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (entries.isEmpty) {
      return _buildEmptyState();
    }

    final reviewed = entries.where((e) => e.timesReviewed > 0).length;
    final mastered = entries.where((e) => e.mastered).length;
    final revBySubj = _reviewsPerSubject(entries);
    final mastBySubj = _masteredPerSubject(entries);
    final userResponses = diaryState.userResponses;
    final insights = _generateInsights(entries);
    final annotationSpots = _weeklySpots(entries);
    final reviewSpots = _weeklyReviewSpots(entries);
    final labels = _weekLabels();
    final maxSpot = [
      ...annotationSpots.map((s) => s.y),
      ...reviewSpots.map((s) => s.y),
    ].fold(0.0, (a, b) => a > b ? a : b);

    // 🔍 DEBUG: verificar dados reais da Taxa de Domínio
    for (final entry in entries) {
      print('[DOMINIO] Anotação: ${entry.questionId}, mastered: ${entry.mastered}, timesReviewed: ${entry.timesReviewed}');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Insights de Aprendizado ────────────────
          if (insights.isNotEmpty) ...[
            _sectionTitle('✨ Insights de Aprendizado',
                'Baseado no seu histórico de revisões'),
            const SizedBox(height: 12),
            ...insights.map((i) => _buildInsightCard(i)),
            const SizedBox(height: 24),
          ],

          // ── 2. Progresso de Revisões ──────────────────
          _sectionTitle(
              '🔄 Progresso de Revisões', 'Anotações revisadas ao menos uma vez'),
          const SizedBox(height: 12),
          _buildProgressoRevisoesCard(entries.length, reviewed),
          const SizedBox(height: 24),

          // ── 3. Revisões por Matéria ───────────────────
          _sectionTitle(
              '📚 Revisões por Matéria', 'Total de revisões acumuladas por matéria'),
          const SizedBox(height: 12),
          _buildRevisoesPorMateriaCard(revBySubj),
          const SizedBox(height: 24),

          // ── 4. Taxa de Domínio ────────────────────────
          _sectionTitle(
              '🏆 Taxa de Domínio', 'Lições dominadas após 5 revisões'),
          const SizedBox(height: 12),
          _buildTaxaDominioCard(mastered, entries.length, mastBySubj),
          const SizedBox(height: 24),

          // ── 4b. Pontos Fortes e Fracos ────────────────
          _sectionTitle('🎯 Seus Pontos Fortes e Fracos',
              'Baseado nas suas respostas'),
          const SizedBox(height: 12),
          _buildPontosFortesFracosCard(userResponses),
          const SizedBox(height: 24),

          // ── 5. Evolução Semanal ───────────────────────
          _sectionTitle('📈 Evolução Semanal',
              'Anotações criadas vs revisões feitas nos últimos 7 dias'),
          const SizedBox(height: 12),
          _buildLineChartCard(annotationSpots, reviewSpots, labels, maxSpot),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // CARD 1: PROGRESSO DE REVISÕES
  // ══════════════════════════════════════════════════════

  Widget _buildProgressoRevisoesCard(int total, int reviewed) {
    final pct = total > 0 ? reviewed / total : 0.0;
    final pctInt = (pct * 100).round();

    return _card(
      child: Row(
        children: [
          // Circular progress
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: pct,
                    strokeWidth: 9,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.green.shade500),
                  ),
                ),
                Text(
                  '$pctInt%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$reviewed de $total revisadas',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  reviewed == 0
                      ? 'Vá para a aba Revisar para começar!'
                      : reviewed == total
                          ? '🎉 Todas as anotações foram revisadas!'
                          : 'Faltam ${total - reviewed} anotações para revisar',
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade600, height: 1.4),
                ),
                if (reviewed > 0) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.green.shade400),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // CARD 2: REVISÕES POR MATÉRIA
  // ══════════════════════════════════════════════════════

  Color _heatColorReview(int count) {
    if (count == 0) return const Color(0xFFEBEDF0);
    if (count <= 2) return const Color(0xFFFED8B1);
    if (count <= 5) return const Color(0xFFFDBA74);
    return const Color(0xFF22C55E);
  }

  Color _heatTextColorReview(int count) {
    if (count >= 6) return Colors.white;
    return Colors.grey.shade800;
  }

  Widget _buildRevisoesPorMateriaCard(Map<String, int> revBySubj) {
    final totalRevs = revBySubj.values.fold(0, (a, b) => a + b);
    final withRevs = _materias
        .where((m) => (revBySubj[_normalizeSubject(m.$2)] ?? 0) > 0)
        .length;

    final row1 = _materias.sublist(0, 6);
    final row2 = _materias.sublist(6, 12);

    Widget buildCell((String, String, String) m) {
      final count = revBySubj[_normalizeSubject(m.$2)] ?? 0;
      final bg = _heatColorReview(count);
      final textColor = _heatTextColorReview(count);
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
              Text(m.$3,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: textColor)),
              const SizedBox(height: 2),
              Text('$count',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
            ],
          ),
        ),
      );
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: row1.map(buildCell).toList()),
          const SizedBox(height: 2),
          Row(children: row2.map(buildCell).toList()),
          const SizedBox(height: 14),
          // Legenda
          Row(
            children: [
              _legendDot(const Color(0xFFEBEDF0), '0', Colors.grey.shade700),
              const SizedBox(width: 10),
              _legendDot(const Color(0xFFFED8B1), '1-2', Colors.grey.shade700),
              const SizedBox(width: 10),
              _legendDot(const Color(0xFFFDBA74), '3-5', Colors.grey.shade700),
              const SizedBox(width: 10),
              _legendDot(const Color(0xFF22C55E), '6+', Colors.white),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            totalRevs == 0
                ? 'Revise suas anotações para ver o progresso aqui!'
                : 'Total: $totalRevs revisões em $withRevs matéri${withRevs != 1 ? 'as' : 'a'}',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // CARD 3: TAXA DE DOMÍNIO
  // ══════════════════════════════════════════════════════

  Widget _buildTaxaDominioCard(
      int mastered, int total, Map<String, int> mastBySubj) {
    final pct = total > 0 ? mastered / total : 0.0;
    final masteredList = mastBySubj.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Número destacado
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: mastered > 0
                      ? Colors.green.shade50
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: mastered > 0
                          ? Colors.green.shade200
                          : Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      '$mastered',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: mastered > 0
                            ? Colors.green.shade700
                            : Colors.grey.shade400,
                      ),
                    ),
                    Text(
                      'dominada${mastered != 1 ? 's' : ''}',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mastered == 0
                          ? 'Nenhuma lição dominada ainda'
                          : '$mastered ${mastered != 1 ? 'lições' : 'lição'} dominada${mastered != 1 ? 's' : ''} de $total anotações',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      mastered == 0
                          ? 'Revise 5x uma anotação para dominá-la!'
                          : '${(pct * 100).round()}% do total dominado',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                    if (mastered > 0) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green.shade500),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          // Lista de matérias com lições dominadas
          if (masteredList.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Text(
              'Matérias com lições dominadas:',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: masteredList.map((e) {
                final icon = _materias
                        .where((m) => _normalizeSubject(m.$2) == e.key)
                        .map((m) => m.$1)
                        .firstOrNull ??
                    '📚';
                final sigla = _materias
                        .where((m) => _normalizeSubject(m.$2) == e.key)
                        .map((m) => m.$3)
                        .firstOrNull ??
                    e.key;
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(icon, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text('$sigla: ${e.value}',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // CARD 4b: PONTOS FORTES E FRACOS
  // ══════════════════════════════════════════════════════

  /// Calcula % acertos por matéria a partir de userResponses
  /// Retorna Map<normalizedSubject, (acertos, total)>
  Map<String, (int, int)> _subjectAccuracy(
      List<Map<String, dynamic>> responses) {
    final map = <String, (int, int)>{};
    for (final r in responses) {
      final subj = _normalizeSubject(r['subject'] as String? ?? '');
      if (subj.isEmpty) continue;
      final prev = map[subj] ?? (0, 0);
      final wasCorrect = r['was_correct'] == true;
      map[subj] = (
        wasCorrect ? prev.$1 + 1 : prev.$1,
        prev.$2 + 1,
      );
    }
    // Manter só matérias com ao menos 3 respostas para dados confiáveis
    map.removeWhere((_, v) => v.$2 < 3);
    return map;
  }

  Widget _buildPontosFortesFracosCard(
      List<Map<String, dynamic>> userResponses) {
    final accuracy = _subjectAccuracy(userResponses);

    if (accuracy.length < 2) {
      return _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Continue estudando para descobrir\nseus pontos fortes!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                      height: 1.5),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Ordenar por % de acertos
    final sorted = accuracy.entries
        .map((e) => (
              key: e.key,
              acertos: e.value.$1,
              total: e.value.$2,
              pct: e.value.$2 > 0 ? e.value.$1 / e.value.$2 : 0.0,
            ))
        .toList()
      ..sort((a, b) => b.pct.compareTo(a.pct));

    final topFortes = sorted.take(3).toList();
    final topFracos = sorted.reversed.take(3).toList();

    Widget buildSubjectRow(
        {required String key,
        required int acertos,
        required int total,
        required double pct,
        required bool isStrong}) {
      final icon = _materias
              .where((m) => _normalizeSubject(m.$2) == key)
              .map((m) => m.$1)
              .firstOrNull ??
          '📚';
      final sigla = _materias
              .where((m) => _normalizeSubject(m.$2) == key)
              .map((m) => m.$3)
              .firstOrNull ??
          key;
      final pctInt = (pct * 100).round();
      final barColor = isStrong ? Colors.green.shade400 : Colors.orange.shade400;

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(sigla,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis),
                ),
                Text('$pctInt% ($acertos/$total)',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: barColor)),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 6,
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ],
        ),
      );
    }

    return _card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coluna esquerda: Pontos Fortes
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text('💪', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text('Pontos Fortes',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700)),
                ]),
                const SizedBox(height: 2),
                Text('Matérias com mais acertos',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                const SizedBox(height: 10),
                ...topFortes.map((s) => buildSubjectRow(
                      key: s.key,
                      acertos: s.acertos,
                      total: s.total,
                      pct: s.pct,
                      isStrong: true,
                    )),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Coluna direita: Precisa Melhorar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text('⚠️', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text('Precisa Melhorar',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700)),
                ]),
                const SizedBox(height: 2),
                Text('Matérias com menos acertos',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                const SizedBox(height: 10),
                ...topFracos.map((s) => buildSubjectRow(
                      key: s.key,
                      acertos: s.acertos,
                      total: s.total,
                      pct: s.pct,
                      isStrong: false,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // CARD 4: LINE CHART
  // ══════════════════════════════════════════════════════

  Widget _buildLineChartCard(List<FlSpot> annotationSpots,
      List<FlSpot> reviewSpots, List<String> labels, double maxY) {
    final hasData = annotationSpots.any((s) => s.y > 0) ||
        reviewSpots.any((s) => s.y > 0);
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 160,
            child: hasData
                ? LineChart(
                    _lineChartData(annotationSpots, reviewSpots, labels, maxY))
                : Center(
                    child: Text('Nenhuma atividade esta semana',
                        style: TextStyle(color: Colors.grey.shade400))),
          ),
          const SizedBox(height: 10),
          // Legenda das duas linhas
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _lineLegend(Colors.green.shade500, '📝 Anotações'),
              const SizedBox(width: 20),
              _lineLegend(Colors.blue.shade400, '🔄 Revisões'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _lineLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  LineChartData _lineChartData(List<FlSpot> annotationSpots,
      List<FlSpot> reviewSpots, List<String> labels, double maxY) {
    return LineChartData(
      minY: 0,
      maxY: maxY < 1 ? 4 : maxY + 1,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (v) =>
            FlLine(color: Colors.grey.shade100, strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false, reservedSize: 12)),
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            interval: maxY < 4 ? 1 : (maxY / 4).ceilToDouble(),
            getTitlesWidget: (v, _) => Text(
              v.toInt().toString(),
              style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: 1,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= labels.length) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(labels[i],
                    style: TextStyle(
                        fontSize: 11,
                        color: i == 6
                            ? Colors.green.shade700
                            : Colors.grey.shade500,
                        fontWeight: i == 6
                            ? FontWeight.bold
                            : FontWeight.normal)),
              );
            },
          ),
        ),
      ),
      lineBarsData: [
        // Linha verde: Anotações
        LineChartBarData(
          spots: annotationSpots,
          isCurved: true,
          curveSmoothness: 0.35,
          gradient: LinearGradient(
            colors: [Colors.green.shade300, Colors.green.shade600],
          ),
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
              radius: spot.y > 0 ? 4 : 2,
              color:
                  spot.y > 0 ? Colors.green.shade600 : Colors.grey.shade300,
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.green.shade100.withValues(alpha: 0.4),
                Colors.green.shade50.withValues(alpha: 0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Linha azul: Revisões
        LineChartBarData(
          spots: reviewSpots,
          isCurved: true,
          curveSmoothness: 0.35,
          color: Colors.blue.shade400,
          barWidth: 2.5,
          dashArray: [6, 3], // linha tracejada para diferenciar
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
              radius: spot.y > 0 ? 4 : 2,
              color:
                  spot.y > 0 ? Colors.blue.shade500 : Colors.grey.shade300,
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // ── Insight card ──────────────────────────────────────

  Widget _buildInsightCard(_Insight insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: insight.color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: insight.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
                child: Text(insight.emoji,
                    style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(insight.text,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4)),
          ),
        ],
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📊', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          const Text('Ainda sem dados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Faça suas primeiras anotações para\nver sua análise aqui!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, height: 1.5)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        Text(subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      ],
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

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}

// ── Modelo interno ────────────────────────────────────────

class _Insight {
  final String emoji;
  final String text;
  final Color color;
  const _Insight({required this.emoji, required this.text, required this.color});
}
