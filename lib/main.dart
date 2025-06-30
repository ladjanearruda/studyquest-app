import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/themes/app_theme.dart';

import 'features/home/screens/menu_trilhas_screen.dart';

// ✅ IMPORTS BÁSICOS
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/trilha/screens/trilha_mapa_screen.dart';
import 'features/trilha/screens/trilha_questao_screen.dart';
import 'features/trilha/screens/trilha_feedback_screen.dart';
import 'features/trilha/screens/trilha_resultados_screen.dart';
import 'features/trilha/screens/trilha_gameover_screen.dart';

// ✅ IMPORTS OCEÂNICOS
import 'features/trilha/screens/trilha_oceano_mapa_screen.dart';
import 'features/trilha/screens/trilha_oceano_questao_screen.dart';
import 'features/trilha/screens/trilha_oceano_feedback_screen.dart';
import 'features/trilha/screens/trilha_oceano_resultados_screen.dart';
import 'features/trilha/screens/trilha_oceano_gameover_screen.dart';

// ✅ MODELS
import 'features/trilha/models/recursos_vitais.dart';

// Router configurado
final router = GoRouter(
  initialLocation: '/onboarding/0',
  routes: [
    // ✅ ROTAS DE ONBOARDING
    GoRoute(path: '/onboarding/0', builder: (_, __) => const Tela0Nome()),
    GoRoute(
        path: '/onboarding/1',
        builder: (_, __) => const Tela1NivelEducacional()),
    GoRoute(
        path: '/onboarding/2',
        builder: (_, __) => const Tela2ObjetivoPrincipal()),
    GoRoute(
        path: '/onboarding/3', builder: (_, __) => const Tela3AreaInteresse()),
    GoRoute(
        path: '/onboarding/4',
        builder: (_, __) => const Tela4UniversidadeSonho()),
    GoRoute(
        path: '/onboarding/5', builder: (_, __) => const Tela5TempoEstudo()),
    GoRoute(
        path: '/onboarding/6', builder: (_, __) => const Tela6Dificuldade()),
    GoRoute(
        path: '/onboarding/7', builder: (_, __) => const Tela7EstiloEstudo()),
    GoRoute(
        path: '/onboarding/complete',
        builder: (_, __) => const OnboardingComplete()),

    // ✅ ROTAS GERAIS
    GoRoute(path: '/home', builder: (_, __) => const MenuTrilhasScreen()),
    GoRoute(
        path: '/trail/forest', builder: (_, __) => const MenuTrilhasScreen()),

    // ✅ ROTAS DA TRILHA FLORESTA (FUNCIONAIS!)
    GoRoute(path: '/trilha-mapa', builder: (_, __) => const TrilhaMapaScreen()),

    GoRoute(
      path: '/trilha-questao/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
        return TrilhaQuestaoScreen(questaoId: id);
      },
    ),

    GoRoute(
      path: '/trilha-feedback',
      builder: (context, state) {
        return TrilhaFeedbackScreen(
          acertou: true,
          energiaAntes: RecursosVitais.inicial(),
          energiaDepois: RecursosVitais.inicial(),
          questaoId: 0,
          escolha: 0,
        );
      },
    ),

    GoRoute(
        path: '/trilha-resultados',
        builder: (_, __) => const TrilhaResultadosScreen()),
    GoRoute(
        path: '/trilha-gameover',
        builder: (_, __) => const TrilhaGameOverScreen()),

    // ✅ ROTAS DO OCEANO (funcionam)
    GoRoute(
        path: '/trilha-oceano-mapa',
        builder: (_, __) => const TrilhaOceanoMapaScreen()),

    GoRoute(
      path: '/trilha-oceano-questao/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
        return TrilhaOceanoQuestaoScreen(questaoId: id);
      },
    ),

    GoRoute(
        path: '/trilha-oceano-resultados',
        builder: (_, __) => const TrilhaOceanoResultadosScreen()),
    GoRoute(
        path: '/trilha-oceano-gameover',
        builder: (_, __) => const TrilhaOceanoGameOverScreen()),
  ],
);

void main() {
  runApp(
    const ProviderScope(
      child: StudyQuestApp(),
    ),
  );
}

class StudyQuestApp extends StatelessWidget {
  const StudyQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'StudyQuest',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routerConfig: router,
    );
  }
}

class PlaceholderHome extends StatelessWidget {
  const PlaceholderHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StudyQuest')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forest, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'Bem-vindo ao StudyQuest!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Transformando estudos em aventura 🌳',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
