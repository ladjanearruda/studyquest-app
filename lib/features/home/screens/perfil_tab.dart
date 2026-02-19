// lib/features/home/screens/perfil_tab.dart
// ✅ V8.2 - Sprint 8: Redesign com Avatar real + Nome do onboarding
// 📅 Atualizado: 17/02/2026

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/avatar.dart';
import '../../../core/services/firebase_rest_auth.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../niveis/providers/nivel_provider.dart';
import '../../niveis/models/nivel_model.dart';

class PerfilTab extends ConsumerWidget {
  const PerfilTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final nivelUsuario = ref.watch(nivelProvider);
    final authState = ref.watch(authProvider);
    final userName = onboarding.name ?? 'Explorador';

    // ✅ CORRIGIDO: Acessar isAnonymous via user
    final isAnonymous = authState.user?.isAnonymous ?? true;

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
          // Header com Avatar grande
          SliverToBoxAdapter(
            child: _buildHeader(
                context, userName, avatar, nivelUsuario, isAnonymous, ref),
          ),

          // Aviso conta temporária
          if (isAnonymous)
            SliverToBoxAdapter(
              child: _buildAvisoContaTemporaria(context),
            ),

          // Estatísticas
          SliverToBoxAdapter(
            child: _buildEstatisticas(),
          ),

          // Menu de opções
          SliverToBoxAdapter(
            child: _buildMenuOpcoes(context, ref),
          ),

          // Espaço no final
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName, Avatar? avatar,
      NivelUsuario nivelUsuario, bool isAnonymous, WidgetRef ref) {
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
              // Linha superior
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  const Text(
                    'Meu Perfil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Configurações
                    },
                    icon: const Icon(Icons.settings, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Avatar grande
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(55),
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(51),
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

              const SizedBox(height: 16),

              // Nome
              Text(
                userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Badge de conta
              if (isAnonymous)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_outline,
                          color: Colors.white.withOpacity(0.9), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Conta temporária',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              // Nível e XP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        // ✅ CORRIGIDO: Acessar emoji via extension
                        Text(
                          nivelUsuario.tier.emoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Nível ${nivelUsuario.nivel}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '${nivelUsuario.xpTotal} XP',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildAvisoContaTemporaria(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.warning_amber,
                color: Colors.orange.shade700, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seu progresso pode ser perdido!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Crie uma conta para salvar seus dados',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.go('/register');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Criar',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEstatisticas() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
          const Text(
            'Estatísticas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatItem(
                  Icons.check_circle, '45', 'Questões', Colors.green),
              _buildStatItem(Icons.local_fire_department, '7 dias', 'Sequência',
                  Colors.orange),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                  Icons.trending_up, '85%', 'Taxa Acerto', Colors.blue),
              _buildStatItem(Icons.emoji_events, '8', 'Badges', Colors.amber),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
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
        ],
      ),
    );
  }

  Widget _buildMenuOpcoes(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(20),
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
        children: [
          _buildMenuItem(
            icon: Icons.edit,
            iconColor: Colors.green,
            title: 'Editar Perfil',
            subtitle: 'Alterar dados pessoais',
            onTap: () {
              // TODO: Editar perfil
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.refresh,
            iconColor: Colors.orange,
            title: 'Refazer Onboarding',
            subtitle: 'Atualizar preferências',
            titleColor: Colors.orange,
            onTap: () {
              context.go('/onboarding/1');
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.notifications,
            iconColor: Colors.blue,
            title: 'Notificações',
            subtitle: 'Gerenciar alertas',
            onTap: () {
              // TODO: Notificações
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help_outline,
            iconColor: Colors.purple,
            title: 'Ajuda e Suporte',
            subtitle: 'Central de ajuda',
            onTap: () {
              // TODO: Ajuda
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info_outline,
            iconColor: Colors.teal,
            title: 'Sobre o StudyQuest',
            subtitle: 'Versão 1.0.0',
            onTap: () {
              // TODO: Sobre
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.logout,
            iconColor: Colors.red,
            title: 'Sair e Limpar Dados',
            subtitle: 'Seu progresso será perdido',
            titleColor: Colors.red,
            onTap: () => _showLogoutConfirmation(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 68,
      endIndent: 20,
      color: Colors.grey.shade200,
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.logout, color: Colors.red.shade700, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Sair da conta?'),
          ],
        ),
        content: const Text(
          'Se você sair, todo o seu progresso será perdido permanentemente.\n\nTem certeza?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/welcome');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
