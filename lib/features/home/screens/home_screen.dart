// lib/features/home/screens/home_screen.dart
// ✅ V8.1 - Sprint 8: Aceita initialTab via extra do GoRouter
// 📅 Atualizado: 17/02/2026

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Imports das tabs
import 'inicio_tab.dart';
import 'jogar_tab.dart';
import 'observatorio_tab.dart';
import 'perfil_tab.dart';

/// Provider para controlar a tab atual
final currentTabProvider = StateProvider<int>((ref) => 0);

/// HomeScreen - Container principal com Bottom Navigation
///
/// Estrutura:
/// - Tab 0: Início (Dashboard)
/// - Tab 1: Jogar (Questões)
/// - Tab 2: Observatório (Rankings)
/// - Tab 3: Perfil (Dados usuário)
///
/// ✅ V8.1: Aceita initialTab via extra para navegação de outras telas
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // ✅ V8.1: Verificar se há initialTab no extra após o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialTab();
    });
  }

  /// ✅ V8.1: Verifica se veio initialTab via GoRouter extra
  void _checkInitialTab() {
    try {
      final extra = GoRouterState.of(context).extra;
      if (extra != null && extra is Map<String, dynamic>) {
        final initialTab = extra['initialTab'] as int?;
        if (initialTab != null && initialTab >= 0 && initialTab <= 3) {
          ref.read(currentTabProvider.notifier).state = initialTab;
          print('📍 HomeScreen: Navegando para aba $initialTab');
        }
      }
    } catch (e) {
      // Se não conseguir ler o extra, mantém a aba atual
      print('⚠️ HomeScreen: Não foi possível ler initialTab: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(currentTabProvider);

    // Lista de telas correspondentes às tabs
    final List<Widget> tabs = [
      const InicioTab(),
      const JogarTab(),
      const ObservatorioTab(),
      const PerfilTab(),
    ];

    return Scaffold(
      // Corpo principal - mostra tab atual
      body: IndexedStack(
        index: currentTab,
        children: tabs,
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentTab,
          onTap: (index) {
            ref.read(currentTabProvider.notifier).state = index;
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.green[700],
          unselectedItemColor: Colors.grey[600],
          selectedFontSize: 12,
          unselectedFontSize: 11,
          elevation: 0,
          items: const [
            // Tab 0: Início
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded, size: 26),
              activeIcon: Icon(Icons.home, size: 28),
              label: 'Início',
            ),

            // Tab 1: Jogar
            BottomNavigationBarItem(
              icon: Icon(Icons.videogame_asset_rounded, size: 26),
              activeIcon: Icon(Icons.videogame_asset, size: 28),
              label: 'Jogar',
            ),

            // Tab 2: Observatório
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_rounded, size: 26),
              activeIcon: Icon(Icons.emoji_events, size: 28),
              label: 'Ranking',
            ),

            // Tab 3: Perfil
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded, size: 26),
              activeIcon: Icon(Icons.person, size: 28),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
