// lib/features/diario/screens/diario_tab.dart
// ✅ V9.2 - Sprint 9 Fase 2: Tabs com UX gamificada
// 📅 Atualizado: 21/02/2026

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'diario_dashboard_tab.dart';
import 'diario_anotacoes_tab.dart';
import 'diario_revisoes_tab.dart';
import 'diario_conquistas_tab.dart';
import 'diario_insights_tab.dart';
import '../providers/diary_provider.dart';

class DiarioTab extends ConsumerStatefulWidget {
  const DiarioTab({super.key});

  @override
  ConsumerState<DiarioTab> createState() => _DiarioTabState();
}

class _DiarioTabState extends ConsumerState<DiarioTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diaryState = ref.watch(diaryProvider);
    final pendingReviews =
        diaryState.entries.where((e) => e.needsReview).length;
    final totalEntries = diaryState.entries.length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Header com título
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.green.shade600,
              elevation: 0,
              title: Row(
                children: [
                  // Ícone do diário animado
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('📒', style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meu Diário',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Sua jornada de aprendizado',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                // Botão de configurações
                IconButton(
                  onPressed: () {
                    // TODO: Abrir configurações do diário
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Configurações em breve!')),
                    );
                  },
                  icon: const Icon(Icons.settings, color: Colors.white),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.green.shade700,
                    unselectedLabelColor: Colors.grey.shade500,
                    indicatorColor: Colors.green.shade600,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: [
                      _buildTab(
                        icon: '🗺️',
                        label: 'Jornada',
                        isSelected: _tabController.index == 0,
                      ),
                      _buildTabComBadge(
                        icon: '📝',
                        label: 'Lições',
                        badge:
                            totalEntries > 0 ? totalEntries.toString() : null,
                        badgeColor: Colors.green,
                        isSelected: _tabController.index == 1,
                      ),
                      _buildTabComBadge(
                        icon: '🔄',
                        label: 'Revisar',
                        badge: pendingReviews > 0
                            ? pendingReviews.toString()
                            : null,
                        badgeColor:
                            pendingReviews > 0 ? Colors.orange : Colors.grey,
                        isSelected: _tabController.index == 2,
                      ),
                      _buildTab(
                        icon: '🏆',
                        label: 'Troféus',
                        isSelected: _tabController.index == 3,
                      ),
                      _buildTab(
                        icon: '📊',
                        label: 'Análise',
                        isSelected: _tabController.index == 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            DiarioDashboardTab(
              onNavigateToRevisoes: () => _tabController.animateTo(2),
            ),
            const DiarioAnotacoesTab(),
            const DiarioRevisoesTab(),
            const DiarioConquistasTab(),
            const DiarioInsightsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({
    required String icon,
    required String label,
    required bool isSelected,
  }) {
    return Tab(
      height: 60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícone com container
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isSelected ? Colors.green.shade50 : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              icon,
              style: TextStyle(
                fontSize: isSelected ? 22 : 20,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildTabComBadge({
    required String icon,
    required String label,
    String? badge,
    required Color badgeColor,
    required bool isSelected,
  }) {
    return Tab(
      height: 60,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícone com badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green.shade50 : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  icon,
                  style: TextStyle(
                    fontSize: isSelected ? 22 : 20,
                  ),
                ),
              ),
              // Badge de contagem
              if (badge != null)
                Positioned(
                  right: -8,
                  top: -4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: badgeColor.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}
