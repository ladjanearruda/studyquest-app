// main.dart - StudyQuest V7.0 - Arquitetura Completa com Bottom Navigation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/themes/app_theme.dart';

// ===== IMPORTS TELAS PRINCIPAIS V7.0 =====
import 'features/auth/screens/welcome_screen.dart';
import 'features/home/screens/home_screen.dart';

// ===== IMPORTS ONBOARDING =====
import 'features/onboarding/screens/onboarding_screen.dart';

// ===== IMPORTS AVATAR =====
import 'features/avatar/screens/avatar_selection_screen.dart';

// ===== IMPORTS MODOS DE JOGO =====
import 'features/modos/screens/modo_selection_screen.dart';

// ===== IMPORTS MODO DESCOBERTA =====
import 'features/modo_descoberta/screens/modo_descoberta_intro_screen.dart';
import 'features/modo_descoberta/screens/modo_descoberta_questao_screen.dart';
import 'features/modo_descoberta/screens/modo_descoberta_resultado_screen.dart';

// ===== IMPORTS TRILHA FLORESTA (Protótipos) =====
import 'features/trilha/screens/trilha_mapa_screen.dart';
import 'features/trilha/screens/trilha_questao_screen.dart';
import 'features/trilha/screens/trilha_feedback_screen.dart';
import 'features/trilha/screens/trilha_resultados_screen.dart';
import 'features/trilha/screens/trilha_gameover_screen.dart';

// ===== IMPORTS TRILHA OCEANO (Protótipos) =====
import 'features/trilha/screens/trilha_oceano_mapa_screen.dart';
import 'features/trilha/screens/trilha_oceano_questao_screen.dart';
import 'features/trilha/screens/trilha_oceano_feedback_screen.dart';
import 'features/trilha/screens/trilha_oceano_resultados_screen.dart';
import 'features/trilha/screens/trilha_oceano_gameover_screen.dart';

// ===== IMPORTS QUESTÕES PERSONALIZADAS - SPRINT 6 =====
import 'features/questoes/screens/questao_personalizada_screen.dart';
import 'features/questoes/screens/questoes_gameover_screen.dart';
import 'features/questoes/screens/questoes_resultado_screen.dart';

// ===== IMPORTS MODELS =====
import 'features/trilha/models/recursos_vitais.dart';

// ===== FIREBASE =====
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ===== ROUTER V7.0 =====
final router = GoRouter(
  initialLocation: '/', // ← WelcomeScreen verifica se é novo/existente

  routes: [
    // ========================================
    // ROTA INICIAL: WELCOME SCREEN
    // ========================================
    GoRoute(
      path: '/',
      builder: (_, __) => const WelcomeScreen(),
    ),

    // ========================================
    // ROTA HOME PRINCIPAL COM BOTTOM NAV
    // ========================================
    GoRoute(
      path: '/home',
      builder: (_, __) => const HomeScreen(),
    ),

    // ========================================
    // ROTAS DE ONBOARDING (8 telas)
    // ========================================
    GoRoute(
      path: '/onboarding/0',
      builder: (_, __) => const Tela0Nome(),
    ),
    GoRoute(
      path: '/onboarding/1',
      builder: (_, __) => const Tela1NivelEducacional(),
    ),
    GoRoute(
      path: '/onboarding/2',
      builder: (_, __) => const Tela2ObjetivoPrincipal(),
    ),
    GoRoute(
      path: '/onboarding/3',
      builder: (_, __) => const Tela3AreaInteresse(),
    ),
    GoRoute(
      path: '/onboarding/4',
      builder: (_, __) => const Tela4UniversidadeSonho(),
    ),
    GoRoute(
      path: '/onboarding/5',
      builder: (_, __) => const Tela5TempoEstudo(),
    ),
    GoRoute(
      path: '/onboarding/6',
      builder: (_, __) => const Tela6Dificuldade(),
    ),
    GoRoute(
      path: '/onboarding/7',
      builder: (_, __) => const Tela7EstiloEstudo(),
    ),
    GoRoute(
      path: '/onboarding/8',
      builder: (_, __) => const Tela8FinalizacaoPremium(),
    ),
    GoRoute(
      path: '/onboarding/complete',
      builder: (_, __) => const Tela8FinalizacaoPremium(),
    ),

    // ========================================
    // ROTA SELEÇÃO DE AVATAR
    // ========================================
    GoRoute(
      path: '/avatar-selection',
      builder: (_, __) => const AvatarSelectionScreen(),
    ),

    // ========================================
    // ROTA SELEÇÃO DE MODOS (Placeholder)
    // ========================================
    GoRoute(
      path: '/modo-selection',
      name: 'modo-selection',
      builder: (_, __) => const ModoSelectionScreen(),
    ),

    // ========================================
    // ROTAS DO MODO DESCOBERTA
    // ========================================
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

    // ========================================
    // ROTAS TRILHA FLORESTA (Protótipos UX)
    // ========================================
    GoRoute(
      path: '/trilha-floresta-mapa',
      builder: (_, __) => const TrilhaMapaScreen(),
    ),
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
      builder: (_, __) => const TrilhaResultadosScreen(),
    ),
    GoRoute(
      path: '/trilha-gameover',
      builder: (_, __) => const TrilhaGameOverScreen(),
    ),

    // ========================================
    // ROTAS TRILHA OCEANO (Protótipos UX)
    // ========================================
    GoRoute(
      path: '/trilha-oceano-mapa',
      builder: (_, __) => const TrilhaOceanoMapaScreen(),
    ),
    GoRoute(
      path: '/trilha-oceano-questao/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
        return TrilhaOceanoQuestaoScreen(questaoId: id);
      },
    ),
    GoRoute(
      path: '/trilha-oceano-resultados',
      builder: (_, __) => const TrilhaOceanoResultadosScreen(),
    ),
    GoRoute(
      path: '/trilha-oceano-gameover',
      builder: (_, __) => const TrilhaOceanoGameOverScreen(),
    ),

    // ========================================
    // ROTAS QUESTÕES PERSONALIZADAS - SPRINT 6
    // ========================================
    GoRoute(
      path: '/questoes-personalizada',
      builder: (context, state) => const QuestaoPersonalizadaScreen(),
    ),
    GoRoute(
      path: '/questoes-gameover',
      builder: (context, state) => const QuestoesGameOverScreen(),
    ),
    GoRoute(
      path: '/questoes-resultado',
      builder: (context, state) => const QuestoesResultadoScreen(),
    ),
  ],
);

// ========================================
// MAIN - INICIALIZAÇÃO DO APP
// ========================================
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

// ========================================
// WIDGET PRINCIPAL DO APP
// ========================================
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
