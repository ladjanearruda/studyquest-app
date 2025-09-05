// main.dart - StudyQuest V6.2 - Integração Modos (baseado no original)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/themes/app_theme.dart';

import 'features/home/screens/menu_trilhas_screen.dart';

// IMPORTS BÁSICOS
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/trilha/screens/trilha_mapa_screen.dart';
import 'features/trilha/screens/trilha_questao_screen.dart';
import 'features/trilha/screens/trilha_feedback_screen.dart';
import 'features/trilha/screens/trilha_resultados_screen.dart';
import 'features/trilha/screens/trilha_gameover_screen.dart';

// IMPORTS OCEÂNICOS
import 'features/trilha/screens/trilha_oceano_mapa_screen.dart';
import 'features/trilha/screens/trilha_oceano_questao_screen.dart';
import 'features/trilha/screens/trilha_oceano_feedback_screen.dart';
import 'features/trilha/screens/trilha_oceano_resultados_screen.dart';
import 'features/trilha/screens/trilha_oceano_gameover_screen.dart';

// IMPORTS MODO DESCOBERTA
import 'features/modo_descoberta/screens/modo_descoberta_intro_screen.dart';
import 'features/modo_descoberta/screens/modo_descoberta_questao_screen.dart';
import 'features/modo_descoberta/screens/modo_descoberta_resultado_screen.dart';

// MODELS
import 'features/trilha/models/recursos_vitais.dart';

// Avatars
import 'features/avatar/screens/avatar_selection_screen.dart';

// 🎯 NOVO IMPORT - MODOS DE JOGO
import 'features/modos/screens/modo_selection_screen.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Router configurado com integração dos modos
final router = GoRouter(
  initialLocation: '/onboarding/0',
  routes: [
    // ROTAS DE ONBOARDING (mantidas exatamente iguais)
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
        path: '/onboarding/8',
        builder: (_, __) => const Tela8FinalizacaoPremium()),
    GoRoute(
        path: '/onboarding/complete',
        builder: (_, __) => const Tela8FinalizacaoPremium()),

    // ROTA DO AVATAR (mantida)
    GoRoute(
      path: '/avatar-selection',
      builder: (_, __) => const AvatarSelectionScreen(),
    ),

    // 🎯 NOVA ROTA - SELEÇÃO DE MODOS
    GoRoute(
      path: '/modo-selection',
      name: 'modo-selection',
      builder: (_, __) => const ModoSelectionScreen(),
    ),

    // ROTAS DO MODO DESCOBERTA (mantidas)
    GoRoute(
      path: '/modo-descoberta/intro',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final nivelEscolar = extra?['nivelEscolar'] as EducationLevel?;

        if (nivelEscolar == null) {
          return const Scaffold(
            body: Center(child: Text('Erro: Nível escolar não informado')),
          );
        }

        return ModoDescobertaIntroScreen(nivelEscolar: nivelEscolar);
      },
    ),
    GoRoute(
      path: '/modo-descoberta/questao',
      builder: (context, state) => const ModoDescobertaQuestaoScreen(),
    ),
    GoRoute(
      path: '/modo-descoberta/resultado',
      builder: (context, state) => const ModoDescobertaResultadoScreen(),
    ),

    // ROTAS PRINCIPAIS - MENU CENTRAL (mantidas)
    GoRoute(path: '/home', builder: (_, __) => const MenuTrilhasScreen()),
    GoRoute(
        path: '/trilha-mapa', builder: (_, __) => const MenuTrilhasScreen()),
    GoRoute(
        path: '/trail/forest', builder: (_, __) => const MenuTrilhasScreen()),

    // ROTAS ESPECÍFICAS DA TRILHA FLORESTA (mantidas)
    GoRoute(
        path: '/trilha-floresta-mapa',
        builder: (_, __) => const TrilhaMapaScreen()),
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

    // ROTAS ESPECÍFICAS DA TRILHA OCEANO (mantidas)
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('🔥 Firebase inicializado com sucesso!');
  } catch (e) {
    print('❌ Erro na inicialização Firebase: $e');
  }

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
      theme: appTheme, // ✅ Mantém tema original
      routerConfig: router,
    );
  }
}

// MANTIDA PARA COMPATIBILIDADE
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
              'Transformando estudos em aventura',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
