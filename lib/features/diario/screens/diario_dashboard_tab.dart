// lib/features/diario/screens/diario_dashboard_tab.dart
// ✅ V9.0 - Sprint 9: Dashboard do Diário com 5 cards
// 📅 Criado: 18/02/2026

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiarioDashboardTab extends ConsumerWidget {
  const DiarioDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card 1: Resumo Rápido
          _buildResumoCard(),

          const SizedBox(height: 16),

          // Card 2: Evolução Semanal
          _buildEvolucaoSemanalCard(),

          const SizedBox(height: 16),

          // Card 3: Radar de Matérias
          _buildRadarMateriasCard(),

          const SizedBox(height: 16),

          // Card 4: Revisões Pendentes
          _buildRevisoesPendentesCard(),

          const SizedBox(height: 16),

          // Card 5: Emoção × Performance
          _buildEmocaoPerformanceCard(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CARD 1: RESUMO RÁPIDO
  // ═══════════════════════════════════════════════════════════════
  Widget _buildResumoCard() {
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
            color: Colors.green.withOpacity(0.3),
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
            ],
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildResumoItem('XP Total', '1.250', '⭐'),
              _buildResumoItem('Nível', '8', '🌱'),
            ],
          ),

          const SizedBox(height: 16),

          // Barra de progresso
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '75/150 XP para o próximo nível',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '50%',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
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
                  value: 0.5,
                  minHeight: 10,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildResumoItem('Streak', '7 dias', '🔥'),
              _buildResumoItem('Precisão', '72%', '📊'),
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
            color: Colors.white.withOpacity(0.7),
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
  Widget _buildEvolucaoSemanalCard() {
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
              Row(
                children: [
                  const Text('📈', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  const Text(
                    'Esta Semana',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+15% 🚀',
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

          // Gráfico de barras simples (placeholder para fl_chart)
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBarraSimples('S', 0.5, Colors.green.shade300),
                _buildBarraSimples('T', 0.7, Colors.green.shade400),
                _buildBarraSimples('Q', 0.9, Colors.green.shade500),
                _buildBarraSimples('Q', 0.85, Colors.green.shade600),
                _buildBarraSimples('S', 0.3, Colors.green.shade200),
                _buildBarraSimples('S', 0.0, Colors.grey.shade200),
                _buildBarraSimples('D', 0.0, Colors.grey.shade200),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'vs semana passada',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarraSimples(String dia, double valor, Color cor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 80 * valor + 10,
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          dia,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CARD 3: RADAR DE MATÉRIAS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRadarMateriasCard() {
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
            children: [
              const Text('🎯', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text(
                'Performance por Matéria',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Placeholder para radar chart (fl_chart)
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.radar, size: 60, color: Colors.green.shade300),
                    const SizedBox(height: 8),
                    Text(
                      'Radar Chart',
                      style: TextStyle(
                        color: Colors.green.shade400,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '(fl_chart)',
                      style: TextStyle(
                        color: Colors.green.shade300,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Destaques
          Row(
            children: [
              Expanded(
                child: _buildDestaqueMateria(
                    '💪', 'Forte', 'Biologia', '90%', Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDestaqueMateria(
                    '⚠️', 'Melhorar', 'Física', '52%', Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDestaqueMateria(
      String emoji, String tipo, String materia, String percent, Color cor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                tipo,
                style: TextStyle(
                  color: cor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            materia,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            percent,
            style: TextStyle(
              color: cor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CARD 4: REVISÕES PENDENTES
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRevisoesPendentesCard() {
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
              Row(
                children: [
                  const Text('📅', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  const Text(
                    'Hora de Revisar!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '3 pendentes',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRevisaoItem('🔴', 'Cinemática', '3 dias atrás', Colors.red),
          const SizedBox(height: 10),
          _buildRevisaoItem('🟡', 'Equações 2º grau', 'hoje', Colors.orange),
          const SizedBox(height: 10),
          _buildRevisaoItem('🟢', 'Biomas', 'amanhã', Colors.green),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Navegar para tab de revisões
              },
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

  Widget _buildRevisaoItem(
      String emoji, String titulo, String tempo, Color cor) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                tempo,
                style: TextStyle(
                  color: cor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: Colors.grey.shade400),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CARD 5: EMOÇÃO × PERFORMANCE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildEmocaoPerformanceCard() {
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
            children: [
              const Text('😊', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text(
                'Seu Humor de Estudo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildEmocaoBar('😊', 0.8, '80%', Colors.green),
          const SizedBox(height: 10),
          _buildEmocaoBar('🙂', 0.65, '65%', Colors.lightGreen),
          const SizedBox(height: 10),
          _buildEmocaoBar('😐', 0.45, '45%', Colors.orange),
          const SizedBox(height: 20),
          Container(
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
                      const Text(
                        'Você aprende melhor feliz!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Baseado em 23 sessões',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmocaoBar(
      String emoji, double valor, String percent, Color cor) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: valor,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: cor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          child: Text(
            percent,
            style: TextStyle(
              color: cor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
