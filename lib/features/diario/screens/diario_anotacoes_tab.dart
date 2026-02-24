// lib/features/diario/screens/diario_anotacoes_tab.dart
// ✅ V9.2 - Sprint 9 Fase 2: Tab Anotações Funcional
// 📅 Atualizado: 21/02/2026

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/diary_provider.dart';
import '../models/diary_entry_model.dart';

class DiarioAnotacoesTab extends ConsumerStatefulWidget {
  const DiarioAnotacoesTab({super.key});

  @override
  ConsumerState<DiarioAnotacoesTab> createState() => _DiarioAnotacoesTabState();
}

class _DiarioAnotacoesTabState extends ConsumerState<DiarioAnotacoesTab> {
  String _filtroMateria = 'Todas';
  String _filtroEmocao = 'Todas';

  @override
  Widget build(BuildContext context) {
    final diaryState = ref.watch(diaryProvider);
    final entries = diaryState.entries;

    // Aplicar filtros
    final entriesFiltradas = _aplicarFiltros(entries);

    // Extrair matérias únicas para o filtro
    final materias = [
      'Todas',
      ...entries.map((e) => e.subject).toSet().toList()..sort()
    ];
    final emocoes = ['Todas', '😫', '😔', '😐', '🙂', '😊'];

    return Column(
      children: [
        // Barra de filtros
        _buildFiltros(materias, emocoes),

        // Lista ou estado vazio
        Expanded(
          child: entriesFiltradas.isEmpty
              ? _buildEmptyState(entries.isEmpty)
              : _buildListaAnotacoes(entriesFiltradas),
        ),
      ],
    );
  }

  List<DiaryEntry> _aplicarFiltros(List<DiaryEntry> entries) {
    return entries.where((entry) {
      final passaMateria =
          _filtroMateria == 'Todas' || entry.subject == _filtroMateria;
      final passaEmocao =
          _filtroEmocao == 'Todas' || entry.emotion == _filtroEmocao;
      return passaMateria && passaEmocao;
    }).toList()
      ..sort((a, b) =>
          b.createdAt.compareTo(a.createdAt)); // Mais recentes primeiro
  }

  Widget _buildFiltros(List<String> materias, List<String> emocoes) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Filtro por matéria
          Expanded(
            child: _buildDropdownComLabel(
              icone: '📚',
              label: 'Matéria',
              value: _filtroMateria,
              items: materias,
              onChanged: (value) => setState(() => _filtroMateria = value!),
            ),
          ),
          const SizedBox(width: 12),
          // Filtro por emoção
          Expanded(
            child: _buildDropdownComLabel(
              icone: '😊',
              label: 'Como me senti',
              value: _filtroEmocao,
              items: emocoes,
              onChanged: (value) => setState(() => _filtroEmocao = value!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownComLabel({
    required String icone,
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label com ícone
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            children: [
              Text(icone, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
        // Dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: Colors.green.shade600),
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool nenhumaAnotacao) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ilustração
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                nenhumaAnotacao ? Icons.book_outlined : Icons.filter_alt_off,
                size: 60,
                color: Colors.green.shade300,
              ),
            ),
            const SizedBox(height: 24),

            // Título
            Text(
              nenhumaAnotacao
                  ? 'Nenhuma anotação ainda'
                  : 'Nenhuma anotação encontrada',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),

            // Descrição
            Text(
              nenhumaAnotacao
                  ? 'Quando você errar uma questão, clique em\n"🌱 Plantar essa lição" para criar sua primeira anotação!'
                  : 'Tente mudar os filtros para ver outras anotações.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Dica
            if (nenhumaAnotacao)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'Cada anotação vale +25 XP!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Botão limpar filtros
            if (!nenhumaAnotacao) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _filtroMateria = 'Todas';
                    _filtroEmocao = 'Todas';
                  });
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpar Filtros'),
                style: TextButton.styleFrom(
                    foregroundColor: Colors.green.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListaAnotacoes(List<DiaryEntry> entries) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _AnotacaoCard(
          entry: entry,
          onTap: () => _showDetalheAnotacao(entry),
        );
      },
    );
  }

  void _showDetalheAnotacao(DiaryEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetalheAnotacaoModal(entry: entry),
    );
  }
}

// ===== CARD DE ANOTAÇÃO =====
class _AnotacaoCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onTap;

  const _AnotacaoCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final urgencia = entry.reviewUrgency;
    final corUrgencia = _getCorUrgencia(urgencia);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Matéria + Emoção + Data
                Row(
                  children: [
                    // Badge matéria
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        entry.subject,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Emoção
                    Text(entry.emotion, style: const TextStyle(fontSize: 18)),

                    // Dificuldade (estrelas)
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(
                          5,
                          (i) => Icon(
                                i < entry.difficultyRating
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 14,
                                color: Colors.amber,
                              )),
                    ),

                    const Spacer(),

                    // Badge urgência revisão
                    if (entry.needsReview)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: corUrgencia.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: corUrgencia.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh, size: 12, color: corUrgencia),
                            const SizedBox(width: 4),
                            Text(
                              'Revisar',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: corUrgencia),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Questão (truncada)
                Text(
                  entry.questionText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                // O que aprendi
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.userNote,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green.shade800,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Footer: Data + XP
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      _formatarData(entry.createdAt),
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '+${entry.xpEarned} XP',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCorUrgencia(ReviewUrgency urgencia) {
    switch (urgencia) {
      case ReviewUrgency.urgent:
        return Colors.red;
      case ReviewUrgency.overdue:
        return Colors.orange;
      case ReviewUrgency.today:
        return Colors.amber.shade700;
      case ReviewUrgency.onTime:
        return Colors.green;
    }
  }

  String _formatarData(DateTime data) {
    final agora = DateTime.now();
    final diff = agora.difference(data);

    if (diff.inDays == 0) {
      return 'Hoje às ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Ontem';
    } else if (diff.inDays < 7) {
      return 'Há ${diff.inDays} dias';
    } else {
      return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
    }
  }
}

// ===== MODAL DE DETALHE =====
class _DetalheAnotacaoModal extends StatelessWidget {
  final DiaryEntry entry;

  const _DetalheAnotacaoModal({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('📝', style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.subject,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Anotado em ${_formatarDataCompleta(entry.createdAt)}',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Text(entry.emotion, style: const TextStyle(fontSize: 32)),
              ],
            ),
          ),

          const Divider(height: 1),

          // Conteúdo scrollável
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Questão original
                  _buildSecao(
                    icon: '❓',
                    titulo: 'Questão',
                    conteudo: entry.questionText,
                    cor: Colors.grey.shade100,
                  ),
                  const SizedBox(height: 16),

                  // Respostas
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniCard(
                          titulo: 'Sua resposta',
                          valor: entry.userAnswer,
                          cor: Colors.red.shade50,
                          corTexto: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMiniCard(
                          titulo: 'Correta',
                          valor: entry.correctAnswer,
                          cor: Colors.green.shade50,
                          corTexto: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // O que aprendi
                  _buildSecao(
                    icon: '💡',
                    titulo: 'O que aprendi',
                    conteudo: entry.userNote,
                    cor: Colors.green.shade50,
                  ),
                  const SizedBox(height: 16),

                  // Estratégia (se tiver)
                  if (entry.userStrategy.isNotEmpty) ...[
                    _buildSecao(
                      icon: '🎯',
                      titulo: 'Como evitar esse erro',
                      conteudo: entry.userStrategy,
                      cor: Colors.blue.shade50,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Dificuldade e emoção
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniCard(
                          titulo: 'Dificuldade',
                          valor:
                              '${'⭐' * entry.difficultyRating}${'☆' * (5 - entry.difficultyRating)}',
                          cor: Colors.amber.shade50,
                          corTexto: Colors.amber.shade800,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMiniCard(
                          titulo: 'Revisões',
                          valor: '${entry.timesReviewed}x',
                          cor: Colors.purple.shade50,
                          corTexto: Colors.purple.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Próxima revisão
                  if (entry.nextReviewDate != null && !entry.mastered)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Próxima revisão',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _formatarDataCompleta(entry.nextReviewDate!),
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Badge conquistado
                  if (entry.mastered) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade100,
                            Colors.orange.shade100
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 28)),
                          const SizedBox(width: 12),
                          Column(
                            children: [
                              const Text(
                                'Erro Transformado!',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                'Você dominou essa lição',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Botão fechar
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Fechar',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecao({
    required String icon,
    required String titulo,
    required String conteudo,
    required Color cor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(titulo,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(conteudo, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildMiniCard({
    required String titulo,
    required String valor,
    required Color cor,
    required Color corTexto,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: corTexto),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatarDataCompleta(DateTime data) {
    final meses = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];
    return '${data.day} de ${meses[data.month - 1]} de ${data.year}';
  }
}
