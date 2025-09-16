// main.dart - StudyQuest V6.6 - Firebase Real Integrado (Corrigido)

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

// MODOS DE JOGO
import 'features/modos/screens/modo_selection_screen.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// QUESTÕES PERSONALIZADAS - SPRINT 6
import 'features/questoes/screens/questao_personalizada_screen.dart';
import 'features/questoes/screens/questoes_gameover_screen.dart';
import 'features/questoes/screens/questoes_resultado_screen.dart';

// Router configurado com integração dos modos
final router = GoRouter(
  initialLocation: '/onboarding/0',
  routes: [
    // ROTA HOME PRINCIPAL
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),

    // ROTAS DE ONBOARDING
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

    // ROTA DO AVATAR
    GoRoute(
      path: '/avatar-selection',
      builder: (_, __) => const AvatarSelectionScreen(),
    ),

    // ROTA SELEÇÃO DE MODOS
    GoRoute(
      path: '/modo-selection',
      name: 'modo-selection',
      builder: (_, __) => const ModoSelectionScreen(),
    ),

    // ROTAS DO MODO DESCOBERTA
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

    // ROTAS PRINCIPAIS - MENU CENTRAL
    GoRoute(path: '/home', builder: (_, __) => const MenuTrilhasScreen()),
    GoRoute(
        path: '/trilha-mapa', builder: (_, __) => const MenuTrilhasScreen()),
    GoRoute(
        path: '/trail/forest', builder: (_, __) => const MenuTrilhasScreen()),

    // ROTAS ESPECÍFICAS DA TRILHA FLORESTA
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

    // ROTAS ESPECÍFICAS DA TRILHA OCEANO
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

    // ROTAS QUESTÕES PERSONALIZADAS - SPRINT 6
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
      theme: appTheme,
      routerConfig: router,
    );
  }
}

// TELA HOME PRINCIPAL
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo StudyQuest
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.school,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              // Título
              const Text(
                'StudyQuest',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 8),

              // Subtítulo
              Text(
                'Transforme seus estudos em aventuras',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Botões de navegação
              Column(
                children: [
                  SizedBox(
                    width: 280,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => context.go('/onboarding/0'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Começar Jornada',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 280,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => context.go('/modo-selection'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Continuar Estudos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
