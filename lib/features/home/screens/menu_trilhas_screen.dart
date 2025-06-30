import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../trilha/providers/recursos_provider.dart';
import '../../trilha/providers/recursos_oceano_provider.dart';
import '../../trilha/providers/xp_floresta_provider.dart';
import '../../trilha/providers/xp_oceano_provider.dart';

class MenuTrilhasScreen extends ConsumerWidget {
  const MenuTrilhasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xpFloresta = ref.watch(xpFlorestaProvider);
    final xpOceano = ref.watch(xpOceanoProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade200,
              Colors.blue.shade200,
              Colors.purple.shade200,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ✅ HEADER DO STUDYQUEST
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.school,
                              size: 40, color: Colors.blue.shade600),
                          const SizedBox(width: 12),
                          const Text(
                            'StudyQuest',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Escolha sua próxima aventura educacional!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ✅ TRILHAS DISPONÍVEIS
                const Text(
                  'Trilhas Disponíveis',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // ✅ TRILHA FLORESTA
                _buildTrilhaCard(
                  context: context,
                  titulo: 'Floresta Amazônica',
                  subtitulo: 'Sobrevivência na selva brasileira',
                  descricao:
                      'Use matemática para sobreviver na maior floresta tropical do mundo',
                  icone: Icons.forest,
                  cor: Colors.green,
                  xpState: xpFloresta,
                  onTap: () => context.go('/trilha-mapa'),
                  onReset: () => _resetTrilhaFloresta(context, ref),
                ),

                const SizedBox(height: 20),

                // ✅ TRILHA OCEANO
                _buildTrilhaCard(
                  context: context,
                  titulo: 'Oceano Profundo',
                  subtitulo: 'Exploração marinha submarina',
                  descricao:
                      'Mergulhe nas profundezas e use a ciência para sobreviver',
                  icone: Icons.waves,
                  cor: Colors.blue,
                  xpState: xpOceano,
                  onTap: () => context.go('/trilha-oceano-mapa'),
                  onReset: () => _resetTrilhaOceano(context, ref),
                ),

                const SizedBox(height: 20),

                // ✅ TRILHAS FUTURAS (EM BREVE)
                _buildTrilhaCardBloqueada(
                  titulo: 'Estação Espacial',
                  subtitulo: 'Missão interplanetária',
                  descricao: 'Em breve: Aventura no espaço sideral',
                  icone: Icons.rocket_launch,
                  cor: Colors.purple,
                ),

                const SizedBox(height: 30),

                // ✅ BOTÃO DE RESET GERAL
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton.icon(
                    onPressed: () => _mostrarDialogoResetGeral(context, ref),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset Geral de Progresso'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ CARD DE TRILHA ATIVA
  Widget _buildTrilhaCard({
    required BuildContext context,
    required String titulo,
    required String subtitulo,
    required String descricao,
    required IconData icone,
    required Color cor,
    required dynamic xpState,
    required VoidCallback onTap,
    required VoidCallback onReset,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(25, cor.value >> 16 & 0xFF, cor.value >> 8 & 0xFF,
                  cor.value & 0xFF),
              Color.fromARGB(51, cor.value >> 16 & 0xFF, cor.value >> 8 & 0xFF,
                  cor.value & 0xFF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header da trilha
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(204, cor.value >> 16 & 0xFF,
                          cor.value >> 8 & 0xFF, cor.value & 0xFF),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(icone, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(230, cor.value >> 16 & 0xFF,
                                cor.value >> 8 & 0xFF, cor.value & 0xFF),
                          ),
                        ),
                        Text(
                          subtitulo,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(179, cor.value >> 16 & 0xFF,
                                cor.value >> 8 & 0xFF, cor.value & 0xFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Descrição
              Text(
                descricao,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Progresso
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nível ${xpState.nivel}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(204, cor.value >> 16 & 0xFF,
                                cor.value >> 8 & 0xFF, cor.value & 0xFF),
                          ),
                        ),
                        Text(
                          '${xpState.xpTotal} XP',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(204, cor.value >> 16 & 0xFF,
                                cor.value >> 8 & 0xFF, cor.value & 0xFF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: xpState.progressoNivel,
                      backgroundColor: Color.fromARGB(
                          51,
                          cor.value >> 16 & 0xFF,
                          cor.value >> 8 & 0xFF,
                          cor.value & 0xFF),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(179, cor.value >> 16 & 0xFF,
                            cor.value >> 8 & 0xFF, cor.value & 0xFF),
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Precisão: ${(xpState.porcentagemAcerto * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: cor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Botões
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Continuar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(
                            204,
                            cor.value >> 16 & 0xFF,
                            cor.value >> 8 & 0xFF,
                            cor.value & 0xFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: onReset,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color.fromARGB(
                            204,
                            cor.value >> 16 & 0xFF,
                            cor.value >> 8 & 0xFF,
                            cor.value & 0xFF),
                        side: BorderSide(
                            color: Color.fromARGB(204, cor.value >> 16 & 0xFF,
                                cor.value >> 8 & 0xFF, cor.value & 0xFF)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Icon(Icons.refresh, size: 18),
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

  // ✅ CARD DE TRILHA BLOQUEADA
  Widget _buildTrilhaCardBloqueada({
    required String titulo,
    required String subtitulo,
    required String descricao,
    required IconData icone,
    required Color cor,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.grey.shade100, Colors.grey.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header da trilha
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(icone, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          subtitulo,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      'EM BREVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Descrição
              Text(
                descricao,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== FUNÇÕES DE RESET =====

  /// ✅ RESET TRILHA FLORESTA
  void _resetTrilhaFloresta(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Trilha Floresta'),
        content: const Text(
            'Tem certeza que deseja resetar todo o progresso da Trilha da Floresta Amazônica?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(recursosProvider.notifier).reset();
              ref.read(xpFlorestaProvider.notifier).reset();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Trilha Floresta resetada com sucesso!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// ✅ RESET TRILHA OCEANO
  void _resetTrilhaOceano(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Trilha Oceano'),
        content: const Text(
            'Tem certeza que deseja resetar todo o progresso da Trilha do Oceano Profundo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(recursosOceanoProvider.notifier).reset();
              ref.read(xpOceanoProvider.notifier).reset();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Trilha Oceano resetada com sucesso!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// ✅ RESET GERAL DE TODAS AS TRILHAS
  void _mostrarDialogoResetGeral(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Reset Geral'),
        content: const Text(
          'ATENÇÃO: Isso irá resetar TODO o progresso de TODAS as trilhas!\n\n'
          '• Trilha Floresta Amazônica\n'
          '• Trilha Oceano Profundo\n\n'
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Reset de todas as trilhas
              ref.read(recursosProvider.notifier).reset();
              ref.read(xpFlorestaProvider.notifier).reset();
              ref.read(recursosOceanoProvider.notifier).reset();
              ref.read(xpOceanoProvider.notifier).reset();

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      '🔄 Reset geral realizado! Todas as trilhas foram resetadas.'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('RESETAR TUDO',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
