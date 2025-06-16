import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/themes/app_theme.dart';
import 'features/onboarding/screens/onboarding_screen.dart';

// Router configurado
final router = GoRouter(
  initialLocation: '/onboarding/0',
  routes: [
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
        builder: (_, __) => const OnboardingComplete()), // ← SÓ ESTA
    GoRoute(path: '/trail/forest', builder: (_, __) => const PlaceholderHome()),
    GoRoute(path: '/home', builder: (_, __) => const PlaceholderHome()),
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
      theme: appTheme, // Mantém seu tema amazônico!
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
