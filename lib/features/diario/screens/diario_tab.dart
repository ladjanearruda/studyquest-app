// lib/features/diario/screens/diario_tab.dart
// ✅ V9.0 - Sprint 9: Tela principal do Diário com tabs internas
// 📅 Criado: 18/02/2026

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'diario_dashboard_tab.dart';
import 'diario_anotacoes_tab.dart';
import 'diario_revisoes_tab.dart';
import 'diario_conquistas_tab.dart';

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
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('📒', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            const Text(
              'Meu Diário',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // TODO: Configurações do diário
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.dashboard, size: 20),
              text: 'Dashboard',
            ),
            Tab(
              icon: Icon(Icons.edit_note, size: 20),
              text: 'Anotações',
            ),
            Tab(
              icon: Icon(Icons.calendar_today, size: 20),
              text: 'Revisões',
            ),
            Tab(
              icon: Icon(Icons.emoji_events, size: 20),
              text: 'Conquistas',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DiarioDashboardTab(),
          DiarioAnotacoesTab(),
          DiarioRevisoesTab(),
          DiarioConquistasTab(),
        ],
      ),
    );
  }
}
