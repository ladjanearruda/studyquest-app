// lib/features/home/screens/home_screen.dart
// ✅ V9.0 - Sprint 9: 5 abas com Diário
// 📅 Atualizado: 18/02/2026

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Imports das tabs
import 'inicio_tab.dart';
import 'jogar_tab.dart';
import 'observatorio_tab.dart';
import 'perfil_tab.dart';
import '../../diario/screens/diario_tab.dart';

/// Provider para controlar a tab atual
final currentTabProvider = StateProvider<int>((ref) => 0);

/// HomeScreen - Container principal com Bottom Navigation
///
/// Estrutura (V9.0 - 5 abas):
/// - Tab 0: Início (Dashboard)
/// - Tab 1: Diário (Anotações) ← NOVO
/// - Tab 2: Jogar (Questões)
/// - Tab 3: Observatório (Rankings)
/// - Tab 4: Perfil (Dados usuário)
///
/// ✅ V9.0: Adicionada aba do Diário
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // Verificar se há initialTab no extra após o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialTab();
    });
  }

  /// Verifica se veio initialTab via GoRouter extra
  void _checkInitialTab() {
    try {
      final extra = GoRouterState.of(context).extra;
      if (extra != null && extra is Map<String, dynamic>) {
        final initialTab = extra['initialTab'] as int?;
        if (initialTab != null && initialTab >= 0 && initialTab <= 4) {
          ref.read(currentTabProvider.notifier).state = initialTab;
          print('📍 HomeScreen: Navegando para aba $initialTab');
        }
      }
    } catch (e) {
      print('⚠️ HomeScreen: Não foi possível ler initialTab: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(currentTabProvider);

    // Lista de telas correspondentes às tabs (V9.0 - 5 abas)
    final List<Widget> tabs = [
      const InicioTab(), // 0
      const DiarioTab(), // 1 ← NOVO
      const JogarTab(), // 2
      const ObservatorioTab(), // 3
      const PerfilTab(), // 4
    ];

    return Scaffold(
      // Corpo principal - mostra tab atual
      body: IndexedStack(
        index: currentTab,
        children: tabs,
      ),

      // Bottom Navigation Bar (5 abas)
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
          selectedFontSize: 11,
          unselectedFontSize: 10,
          iconSize: 24,
          elevation: 0,
          items: const [
            // Tab 0: Início
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 24),
              activeIcon: Icon(Icons.home, size: 26),
              label: 'Início',
            ),

            // Tab 1: Diário ← NOVO
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined, size: 24),
              activeIcon: Icon(Icons.book, size: 26),
              label: 'Diário',
            ),

            // Tab 2: Jogar
            BottomNavigationBarItem(
              icon: Icon(Icons.play_circle_outline, size: 24),
              activeIcon: Icon(Icons.play_circle_fill, size: 26),
              label: 'Jogar',
            ),

            // Tab 3: Observatório
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined, size: 24),
              activeIcon: Icon(Icons.emoji_events, size: 26),
              label: 'Ranking',
            ),

            // Tab 4: Perfil
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 24),
              activeIcon: Icon(Icons.person, size: 26),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
