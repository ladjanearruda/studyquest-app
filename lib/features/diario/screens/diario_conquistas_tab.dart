// lib/features/diario/screens/diario_conquistas_tab.dart
// ✅ V9.3 - Sprint 9 Fase 3: Tab de Conquistas/Badges
// 📅 Atualizado: 24/02/2026
// 🎯 Visualização de todas as badges com filtros

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/diary_badge_model.dart';
import '../providers/diary_badges_provider.dart';
import '../widgets/badge_unlock_modal.dart';

class DiarioConquistasTab extends ConsumerStatefulWidget {
  const DiarioConquistasTab({super.key});

  @override
  ConsumerState<DiarioConquistasTab> createState() =>
      _DiarioConquistasTabState();
}

class _DiarioConquistasTabState extends ConsumerState<DiarioConquistasTab> {
  BadgeCategory? _selectedCategory;
  bool _showOnlyUnlocked = false;

  @override
  Widget build(BuildContext context) {
    final badgesState = ref.watch(diaryBadgesProvider);
    final allBadges =
        ref.read(diaryBadgesProvider.notifier).getAllBadgesWithStatus();

    // Filtrar badges
    var filteredBadges = allBadges;

    if (_selectedCategory != null) {
      filteredBadges = filteredBadges
          .where((b) => b.badge.categoria == _selectedCategory)
          .toList();
    }

    if (_showOnlyUnlocked) {
      filteredBadges = filteredBadges.where((b) => b.unlocked).toList();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com progresso
          _buildProgressHeader(badgesState),

          const SizedBox(height: 20),

          // Filtros
          _buildFilters(),

          const SizedBox(height: 20),

          // Grid de badges
          _buildBadgesGrid(filteredBadges),

          const SizedBox(height: 20),

          // Hall da Fama (erros transformados)
          _buildHallOfFame(badgesState),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(DiaryBadgesState state) {
    final totalBadges = DiaryBadgeCatalog.totalBadges;
    final unlocked = state.totalUnlocked;
    final progress = state.progressPercentage;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade100, Colors.orange.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Ícone
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade400, Colors.orange.shade500],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('🏆', style: TextStyle(fontSize: 30)),
                ),
              ),

              const SizedBox(width: 16),

              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Suas Conquistas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$unlocked de $totalBadges badges',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              // XP total
              Column(
                children: [
                  Text(
                    '${state.totalXpFromBadges}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade800,
                    ),
                  ),
                  Text(
                    'XP ganhos',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Barra de progresso
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progresso total',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.white,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.amber.shade600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle desbloqueadas
        Row(
          children: [
            const Text(
              'Filtrar por:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            FilterChip(
              label: const Text('Só desbloqueadas'),
              selected: _showOnlyUnlocked,
              onSelected: (value) {
                setState(() {
                  _showOnlyUnlocked = value;
                });
              },
              selectedColor: Colors.green.shade100,
              checkmarkColor: Colors.green,
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Categorias
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryChip(null, '🎖️ Todas'),
              _buildCategoryChip(BadgeCategory.anotacao, '📝 Anotação'),
              _buildCategoryChip(
                  BadgeCategory.transformacao, '🔄 Transformação'),
              _buildCategoryChip(BadgeCategory.consistencia, '📅 Consistência'),
              _buildCategoryChip(BadgeCategory.emocao, '😊 Emoção'),
              _buildCategoryChip(BadgeCategory.revisao, '📖 Revisão'),
              _buildCategoryChip(BadgeCategory.especial, '👑 Especial'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(BadgeCategory? categoria, String label) {
    final isSelected = _selectedCategory == categoria;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (value) {
          setState(() {
            _selectedCategory = value ? categoria : null;
          });
        },
        selectedColor: Colors.amber.shade100,
        checkmarkColor: Colors.amber.shade800,
      ),
    );
  }

  Widget _buildBadgesGrid(
    List<({DiaryBadge badge, bool unlocked, DateTime? unlockedAt})> badges,
  ) {
    if (badges.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              const Text('🔍', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'Nenhuma badge encontrada',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final item = badges[index];
        return BadgeGridItem(
          badge: item.badge,
          unlocked: item.unlocked,
          unlockedAt: item.unlockedAt,
          onTap: () {
            BadgeDetailModal.show(
              context: context,
              badge: item.badge,
              unlocked: item.unlocked,
              unlockedAt: item.unlockedAt,
            );
          },
        );
      },
    );
  }

  Widget _buildHallOfFame(DiaryBadgesState state) {
    final transformacoes = state.stats.totalTransformacoes;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.indigo.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.indigo.shade500],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🏅', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hall da Fama',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Erros transformados em acertos',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Contador de transformações
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHallStat('🔄', transformacoes.toString(), 'Transformações'),
              _buildHallStat(
                  '📚', state.stats.topicosDominados.toString(), 'Tópicos'),
              _buildHallStat(
                  '🔥', '${state.stats.streakDias}', 'Dias seguidos'),
            ],
          ),

          if (transformacoes == 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Erre uma questão, anote no Diário, e depois acerte ela para transformar seu erro!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHallStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
