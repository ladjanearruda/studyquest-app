// lib/features/diario/screens/diario_revisoes_tab.dart
// ✅ V9.0 - Sprint 9: Tab de Revisões (Spaced Repetition)
// 📅 Criado: 18/02/2026

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiarioRevisoesTab extends ConsumerWidget {
  const DiarioRevisoesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card de resumo
          _buildResumoRevisoes(),

          const SizedBox(height: 20),

          // Calendário visual
          _buildCalendarioVisual(),

          const SizedBox(height: 20),

          // Lista de revisões por urgência
          _buildTituloSecao('Revisões Pendentes'),
          const SizedBox(height: 12),

          _buildRevisaoItem(
            emoji: '🔴',
            titulo: 'Cinemática - MRU',
            subtitulo: 'Atrasado há 3 dias',
            cor: Colors.red,
            urgencia: 'Urgente',
          ),

          _buildRevisaoItem(
            emoji: '🔴',
            titulo: 'Equações do 2º grau',
            subtitulo: 'Atrasado há 1 dia',
            cor: Colors.red,
            urgencia: 'Urgente',
          ),

          _buildRevisaoItem(
            emoji: '🟡',
            titulo: 'Regra de três',
            subtitulo: 'Revisar hoje',
            cor: Colors.orange,
            urgencia: 'Hoje',
          ),

          _buildRevisaoItem(
            emoji: '🟢',
            titulo: 'Biomas brasileiros',
            subtitulo: 'Revisar amanhã',
            cor: Colors.green,
            urgencia: 'Em dia',
          ),

          _buildRevisaoItem(
            emoji: '🟢',
            titulo: 'Verbos irregulares',
            subtitulo: 'Revisar em 3 dias',
            cor: Colors.green,
            urgencia: 'Em dia',
          ),

          const SizedBox(height: 24),

          // Info sobre Spaced Repetition
          _buildInfoSpacedRepetition(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildResumoRevisoes() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.purple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
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
              const Text('📅', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              const Text(
                'Suas Revisões',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRevisaoStat('🔴', '2', 'Atrasadas'),
              _buildRevisaoStat('🟡', '1', 'Hoje'),
              _buildRevisaoStat('🟢', '4', 'Em dia'),
              _buildRevisaoStat('✅', '12', 'Completas'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Iniciar sessão de revisão
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Revisar Agora'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.purple.shade600,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevisaoStat(String emoji, String valor, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarioVisual() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fevereiro 2026',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {},
                    iconSize: 20,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {},
                    iconSize: 20,
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
                        child: Text(
                          d,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: 8),

          // Grid do calendário (placeholder)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 28,
            itemBuilder: (context, index) {
              final dia = index + 1;
              final hoje = dia == 18;
              final temRevisao = [15, 17, 18, 20, 23].contains(dia);
              final atrasado = [15, 17].contains(dia);

              return Container(
                decoration: BoxDecoration(
                  color: hoje
                      ? Colors.green.shade500
                      : temRevisao
                          ? (atrasado
                              ? Colors.red.shade100
                              : Colors.orange.shade100)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: hoje
                      ? null
                      : Border.all(
                          color: Colors.grey.shade200,
                        ),
                ),
                child: Center(
                  child: Text(
                    '$dia',
                    style: TextStyle(
                      color: hoje ? Colors.white : Colors.grey.shade700,
                      fontWeight: hoje ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Legenda
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegenda(Colors.red.shade100, 'Atrasado'),
              const SizedBox(width: 16),
              _buildLegenda(Colors.orange.shade100, 'Pendente'),
              const SizedBox(width: 16),
              _buildLegenda(Colors.green.shade500, 'Hoje'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegenda(Color cor, String texto) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          texto,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildTituloSecao(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRevisaoItem({
    required String emoji,
    required String titulo,
    required String subtitulo,
    required Color cor,
    required String urgencia,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitulo,
                  style: TextStyle(
                    color: cor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              urgencia,
              style: TextStyle(
                color: cor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
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
              const Text(
                'Repetição Espaçada',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Revisamos seus erros em intervalos crescentes para maximizar a retenção:',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIntervalo('1º', '1 dia'),
              const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
              _buildIntervalo('2º', '3 dias'),
              const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
              _buildIntervalo('3º', '7 dias'),
              const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
              _buildIntervalo('4º', '14 dias'),
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
                      fontSize: 13,
                    ),
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
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              numero,
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dias,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
