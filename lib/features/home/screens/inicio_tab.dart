// lib/features/home/screens/inicio_tab.dart
// ✅ V8.2 - Sprint 8: Redesign com Avatar + Sem redundância
// 📅 Atualizado: 17/02/2026

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/avatar.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../niveis/providers/nivel_provider.dart';
import '../../niveis/models/nivel_model.dart';
import '../../niveis/services/nivel_persistence.dart';
import '../../diario/providers/diary_badges_provider.dart';
import '../../diario/models/diary_badge_model.dart';
import 'home_screen.dart';

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}

// Providers públicos para que possam ser invalidados de outras telas
final statsHojeProvider = FutureProvider<Map<String, int>>((ref) {
  return NivelPersistence.carregarQuestoesHoje();
});

final statsSemanaisProvider = FutureProvider<Map<String, int>>((ref) {
  return NivelPersistence.carregarEstatisticasQuestoes();
});

class InicioTab extends ConsumerStatefulWidget {
  const InicioTab({super.key});

  @override
  ConsumerState<InicioTab> createState() => _InicioTabState();
}

class _InicioTabState extends ConsumerState<InicioTab> {
  @override
  Widget build(BuildContext context) {
    // Invalida stats sempre que o usuário retorna à aba Início (tab 0)
    ref.listen(currentTabProvider, (prev, next) {
      if (next == 0) {
        ref.invalidate(statsHojeProvider);
        ref.invalidate(statsSemanaisProvider);
      }
    });

    final onboarding = ref.watch(onboardingProvider);
    final nivelUsuario = ref.watch(nivelProvider);
    final userName = onboarding.name ?? 'Explorador';

    // Obter avatar
    Avatar? avatar;
    if (onboarding.selectedAvatarType != null &&
        onboarding.selectedAvatarGender != null) {
      avatar = Avatar.fromTypeAndGender(
        onboarding.selectedAvatarType!,
        onboarding.selectedAvatarGender!,
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Header com Avatar
          SliverToBoxAdapter(
            child: _buildHeader(context, ref, userName, avatar, nivelUsuario),
          ),

          // Conteúdo
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta do Dia
                  _buildMetaDoDia(context, ref),

                  const SizedBox(height: 24),

                  // Resumo Geral
                  _buildResumoSemana(ref),

                  const SizedBox(height: 24),

                  // Conquistas Recentes
                  _buildConquistasRecentes(ref),

                  const SizedBox(height: 24),

                  // Dica do Dia
                  _buildDicaDoDia(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, String userName,
      Avatar? avatar, NivelUsuario nivelUsuario) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Linha superior com notificação
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Text(
                    'StudyQuest',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Notificações
                    },
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Avatar e Info
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(37),
                      child: avatar != null
                          ? Image.asset(
                              avatar.getPath(AvatarEmotion.feliz),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildAvatarPlaceholder(userName),
                            )
                          : _buildAvatarPlaceholder(userName),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Info do usuário
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, $userName! 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            // ✅ CORRIGIDO: Acessar emoji via extension
                            Text(
                              nivelUsuario.tier.emoji,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Nível ${nivelUsuario.nivel}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7)),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${nivelUsuario.xpTotal} XP',
                              style: TextStyle(
                                color: Colors.amber.shade300,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Barra de progresso do nível
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: nivelUsuario.progresso,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.amber.shade400,
                                    Colors.orange.shade500
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String userName) {
    return Container(
      color: Colors.green.shade100,
      child: Center(
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildMetaDoDia(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsHojeProvider);
    const int meta = 10;

    return statsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (stats) {
        final respondidas = stats['respondidas'] ?? 0;
        final progresso = (respondidas / meta).clamp(0.0, 1.0);
        final faltam = (meta - respondidas).clamp(0, meta);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        Icon(Icons.flag, color: Colors.green.shade600, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meta de Hoje',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Complete para ganhar bônus!',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: respondidas >= meta
                          ? Colors.green.shade100
                          : Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$respondidas/$meta',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: respondidas >= meta
                            ? Colors.green.shade800
                            : Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Barra de progresso
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progresso,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade400,
                          Colors.green.shade600
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                respondidas >= meta
                    ? 'Meta concluída! Parabéns! 🎉'
                    : faltam == 1
                        ? 'Falta apenas 1 questão para completar!'
                        : 'Responda mais $faltam questões para completar!',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: respondidas >= meta
                      ? null
                      : () {
                          ref.read(currentTabProvider.notifier).state = 1;
                        },
                  icon: Icon(respondidas >= meta
                      ? Icons.check_circle
                      : Icons.play_arrow),
                  label: Text(respondidas >= meta ? 'Meta Completa!' : 'Jogar Agora'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.green.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResumoSemana(WidgetRef ref) {
    final statsAsync = ref.watch(statsSemanaisProvider);
    final nivelUsuario = ref.watch(nivelProvider);

    return statsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (stats) {
        final respondidas = stats['respondidas'] ?? 0;
        final corretas = stats['corretas'] ?? 0;
        final precisao = respondidas > 0
            ? ((corretas / respondidas) * 100).round()
            : 0;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bar_chart, color: Colors.blue.shade600, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Resumo Geral',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildStatItem(
                      '$respondidas', 'Questões', Icons.check_circle, Colors.green),
                  _buildStatItem(
                      '$precisao%', 'Precisão', Icons.trending_up, Colors.blue),
                  _buildStatItem('${nivelUsuario.nivel}', 'Nível',
                      Icons.local_fire_department, Colors.orange),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
      String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConquistasRecentes(WidgetRef ref) {
    final badgesState = ref.watch(diaryBadgesProvider);
    final unlocked = badgesState.unlockedBadges;

    // Pegar as 3 mais recentes (ordenadas por data)
    final recentes = [...unlocked]
      ..sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));
    final top3 = recentes.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.emoji_events,
                      color: Colors.amber.shade600, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Conquistas Recentes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Text(
                '${unlocked.length}/${DiaryBadgeCatalog.totalBadges}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (top3.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Nenhuma conquista ainda.\nJogue para desbloquear badges!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: top3.map((unlockedBadge) {
                final badge = DiaryBadgeCatalog.todas
                    .where((b) => b.id == unlockedBadge.badgeId)
                    .firstOrNull;
                if (badge == null) return const SizedBox.shrink();
                return _buildConquistaItem(badge.emoji, badge.nome);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildConquistaItem(String emoji, String label) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.amber.shade200, width: 2),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildDicaDoDia() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('💡', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dica do Dia',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Estudar um pouco todos os dias é mais eficaz do que estudar muito de uma vez!',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
