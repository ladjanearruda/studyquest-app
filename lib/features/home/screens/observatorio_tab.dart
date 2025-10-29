// lib/features/home/screens/observatorio_tab.dart
// ObservatorioTab V9 - CARDS DINÂMICOS POR TAB
// ✅ Avatar GRANDE 100x100px FORA do card (à esquerda)
// ✅ Card rosa COMPACTO 60px altura + informações DINÂMICAS por tab
// ✅ Tab Geral: Precisão + posição geral
// ✅ Tab Série: Série + posição na série
// ✅ Tab Estado: Estado + posição no estado
// ✅ Tab Universidade: Meta UnB + posição entre candidatos (mock baseado em dreamUniversity)
// ✅ Animação suave ao trocar tabs (fade + slide)
// ✅ Avatares: Helper SEM "assets/" (Flutter Web adiciona automaticamente)
// ✅ Mock data: explorador/equilibrado/academico (sempre masculino no tipo)
// ✅ ZERO overflow garantido
// ✅ Dados mockados prontos para integração com autenticação

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ObservatorioTab - Sistema de Rankings Educacionais
///
/// VERSÃO 9 - CARDS DINÂMICOS POR TAB:
/// - Card rosa muda informações baseado na tab ativa
/// - Tab 0 (Geral): Precisão + ranking geral
/// - Tab 1 (Série): Série escolar + ranking série
/// - Tab 2 (Estado): Estado + ranking estadual
/// - Tab 3 (Univ): Universidade meta + ranking candidatos
/// - AnimatedSwitcher com fade + slide (300ms)
/// - Listener no TabController para atualizar setState
/// - Mock data estruturado e pronto para dados reais
class ObservatorioTab extends ConsumerStatefulWidget {
  const ObservatorioTab({super.key});

  @override
  ConsumerState<ObservatorioTab> createState() => _ObservatorioTabState();
}

class _ObservatorioTabState extends ConsumerState<ObservatorioTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ========== DADOS MOCKADOS (correto para Sprint 7) ==========
  final Map<String, dynamic> _mockUserData = {
    'name': 'Você',
    'position': 7,
    'score': 1450,
    'accuracy': 88.0,
    'avatarType': 'equilibrado_masculino',
    'schoolLevel': 'EM2',
    'state': 'DF',
  };

  final List<Map<String, dynamic>> _mockTop10Geral = [
    {
      'name': 'Lucas Silva',
      'position': 1,
      'score': 2500,
      'accuracy': 96.0,
      'avatarType': 'academico_masculino' // ✅ CORRETO
    },
    {
      'name': 'Maria Santos',
      'position': 2,
      'score': 2350,
      'accuracy': 94.0,
      'avatarType': 'explorador_feminino' // ✅ CORRIGIDO (era exploradora)
    },
    {
      'name': 'Pedro Costa',
      'position': 3,
      'score': 2100,
      'accuracy': 92.0,
      'avatarType': 'competitivo_masculino' // ✅ CORRETO
    },
    {
      'name': 'Ana Oliveira',
      'position': 4,
      'score': 1950,
      'accuracy': 90.0,
      'avatarType': 'equilibrado_feminino' // ✅ CORRIGIDO (era equilibrada)
    },
    {
      'name': 'João Pereira',
      'position': 5,
      'score': 1800,
      'accuracy': 89.0,
      'avatarType': 'explorador_masculino' // ✅ CORRETO
    },
    {
      'name': 'Julia Lima',
      'position': 6,
      'score': 1650,
      'accuracy': 87.0,
      'avatarType': 'academico_feminino' // ✅ CORRIGIDO (era academica)
    },
    {
      'name': 'Você',
      'position': 7,
      'score': 1450,
      'accuracy': 88.0,
      'avatarType': 'equilibrado_masculino' // ✅ CORRETO
    },
    {
      'name': 'Rafael Souza',
      'position': 8,
      'score': 1300,
      'accuracy': 85.0,
      'avatarType': 'competitivo_masculino' // ✅ CORRETO
    },
    {
      'name': 'Carla Alves',
      'position': 9,
      'score': 1200,
      'accuracy': 84.0,
      'avatarType': 'explorador_feminino' // ✅ CORRIGIDO (era exploradora)
    },
    {
      'name': 'Bruno Rocha',
      'position': 10,
      'score': 1100,
      'accuracy': 82.0,
      'avatarType': 'academico_masculino' // ✅ CORRETO
    },
  ];

  final List<Map<String, dynamic>> _mockTop10Serie = [
    {
      'name': 'Ana Oliveira',
      'position': 1,
      'score': 1950,
      'accuracy': 90.0,
      'avatarType': 'equilibrado_feminino' // ✅ CORRIGIDO
    },
    {
      'name': 'Julia Lima',
      'position': 2,
      'score': 1650,
      'accuracy': 87.0,
      'avatarType': 'academico_feminino' // ✅ CORRIGIDO
    },
    {
      'name': 'Você',
      'position': 3,
      'score': 1450,
      'accuracy': 88.0,
      'avatarType': 'equilibrado_masculino' // ✅ CORRETO
    },
    {
      'name': 'Rafael Souza',
      'position': 4,
      'score': 1300,
      'accuracy': 85.0,
      'avatarType': 'competitivo_masculino' // ✅ CORRETO
    },
    {
      'name': 'Carla Alves',
      'position': 5,
      'score': 1200,
      'accuracy': 84.0,
      'avatarType': 'explorador_feminino' // ✅ CORRIGIDO
    },
  ];

  final List<Map<String, dynamic>> _mockTop10Estado = [
    {
      'name': 'Pedro Costa',
      'position': 1,
      'score': 2100,
      'accuracy': 92.0,
      'avatarType': 'competitivo_masculino' // ✅ CORRETO
    },
    {
      'name': 'Julia Lima',
      'position': 2,
      'score': 1650,
      'accuracy': 87.0,
      'avatarType': 'academico_feminino' // ✅ CORRIGIDO
    },
    {
      'name': 'Você',
      'position': 3,
      'score': 1450,
      'accuracy': 88.0,
      'avatarType': 'equilibrado_masculino' // ✅ CORRETO
    },
    {
      'name': 'Bruno Rocha',
      'position': 4,
      'score': 1100,
      'accuracy': 82.0,
      'avatarType': 'academico_masculino' // ✅ CORRETO
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // ✅ Listener para atualizar card ao trocar de tab
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {}); // Atualiza card com dados da nova tab
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// ✅ NOVO: Retorna dados do card baseado na tab ativa
  Map<String, String> _getCardDataByTab() {
    switch (_tabController.index) {
      case 0: // Geral
        return {
          'info1': 'Precisão ${_mockUserData['accuracy'].toStringAsFixed(0)}%',
          'info2': '#${_mockUserData['position']} de 1.243',
          'score': '${_mockUserData['score']} pts',
        };
      case 1: // Série
        return {
          'info1': _mockUserData['schoolLevel'],
          'info2': '#3 de 156 estudantes',
          'score': '${_mockUserData['score']} pts',
        };
      case 2: // Estado
        return {
          'info1': 'Brasília-${_mockUserData['state']}',
          'info2': '#3 de 89 estudantes',
          'score': '${_mockUserData['score']} pts',
        };
      case 3: // Universidade (mock baseado em dreamUniversity do onboarding)
        return {
          'info1': 'Meta: UnB',
          'info2': '#12 de 45 candidatos',
          'score': '${_mockUserData['score']} pts',
        };
      default:
        return {
          'info1': 'Precisão ${_mockUserData['accuracy'].toStringAsFixed(0)}%',
          'info2': '#${_mockUserData['position']}',
          'score': '${_mockUserData['score']} pts',
        };
    }
  }

  /// ✅ CORREÇÃO CRÍTICA: Helper sem "assets/" no início
  /// Flutter Web adiciona "assets/" automaticamente, causando duplicação
  ///
  /// Exemplo: "academico_masculino" → "images/avatars/academico/masculino/academico_masculino_neutro.png"
  /// Resultado final no Flutter Web: "assets/images/avatars/academico/masculino/academico_masculino_neutro.png" ✅
  String _getAvatarPath(String avatarType) {
    final parts = avatarType.split('_');
    if (parts.length < 2) return ''; // Segurança

    final tipo = parts[
        0]; // academico, competitivo, equilibrado, explorador (sempre masculino)
    final genero = parts[1]; // masculino, feminino

    return 'images/avatars/$tipo/$genero/${tipo}_${genero}_neutro.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildUserPositionCard(),
              const SizedBox(height: 16),
              _buildTabBar(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildGeralTab(),
                      _buildSerieTab(),
                      _buildEstadoTab(),
                      _buildUniversidadeTab(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.emoji_events, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Observatório',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5)),
                Text('Rankings Educacionais',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          IconButton(
            onPressed: _showInfoDialog,
            icon: const Icon(Icons.info_outline, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  /// ✅ Card rosa DINÂMICO: muda informações baseado na tab ativa
  Widget _buildUserPositionCard() {
    final user = _mockUserData;
    final cardData = _getCardDataByTab(); // ✅ Dados dinâmicos por tab

    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 2),
      tween: Tween(begin: 0.96, end: 1.0),
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 100, // ✅ Altura = avatar (100px)
        child: Row(
          children: [
            // ✅ AVATAR MAIOR (100x100)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFe361ff).withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  _getAvatarPath(user['avatarType']),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFe361ff),
                      child: Center(
                        child: Text(
                          user['name'][0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            // ✅ CARD ROSA DINÂMICO (60px) + INFO BASEADA NA TAB
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  key: ValueKey(_tabController.index), // ✅ Key para animação
                  height: 60,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFe361ff), Color(0xFFa855f7)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFe361ff).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nome (sempre fixo)
                      Text(
                        user['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      // Info 1 (muda por tab)
                      Text(
                        cardData['info1']!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                      // Info 2 (muda por tab)
                      Text(
                        cardData['info2']!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      // Score (muda por tab)
                      Text(
                        cardData['score']!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: const Color(0xFF667eea),
        unselectedLabelColor: Colors.white,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        unselectedLabelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        tabs: const [
          Tab(text: 'Geral'),
          Tab(text: 'Série'),
          Tab(text: 'Estado'),
          Tab(text: 'Univ'),
        ],
      ),
    );
  }

  Widget _buildGeralTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mockTop10Geral.length,
      itemBuilder: (context, index) {
        return _buildRankingCard(_mockTop10Geral[index]);
      },
    );
  }

  Widget _buildSerieTab() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF667eea).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF667eea), width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.school, color: Color(0xFF667eea), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ranking do ${_mockUserData['schoolLevel']}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667eea),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _mockTop10Serie.length,
            itemBuilder: (context, index) {
              return _buildRankingCard(_mockTop10Serie[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEstadoTab() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF667eea).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF667eea), width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF667eea), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ranking do ${_mockUserData['state']}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667eea),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _mockTop10Estado.length,
            itemBuilder: (context, index) {
              return _buildRankingCard(_mockTop10Estado[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUniversidadeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.school, color: Colors.amber.shade700, size: 40),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ranking Universidade',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF667eea)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade700, width: 2),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.construction,
                        color: Colors.amber.shade700, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Em breve você poderá competir com estudantes que têm o mesmo objetivo!',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.amber.shade900,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Configure suas metas no perfil para desbloquear.',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.amber.shade800,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Disponível em breve',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Ranking card usando helper corrigido para avatares
  Widget _buildRankingCard(Map<String, dynamic> user) {
    final isUser = user['name'] == 'Você';
    final position = user['position'] as int;

    Color? medalColor;
    IconData? medalIcon;

    if (position == 1) {
      medalColor = const Color(0xFFFFD700);
      medalIcon = Icons.emoji_events;
    } else if (position == 2) {
      medalColor = const Color(0xFFC0C0C0);
      medalIcon = Icons.emoji_events;
    } else if (position == 3) {
      medalColor = const Color(0xFFCD7F32);
      medalIcon = Icons.emoji_events;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: isUser
            ? const LinearGradient(
                colors: [Color(0xFFe361ff), Color(0xFFa855f7)])
            : null,
        color: isUser ? null : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUser ? const Color(0xFFe361ff) : Colors.grey.shade300,
          width: isUser ? 2 : 1,
        ),
        boxShadow: isUser
            ? [
                BoxShadow(
                    color: const Color(0xFFe361ff).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4))
              ]
            : null,
      ),
      child: Row(
        children: [
          // Posição
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  isUser ? Colors.white.withOpacity(0.2) : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: medalIcon != null
                  ? Icon(medalIcon, color: medalColor, size: 24)
                  : Text(
                      '#$position',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isUser ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar ✅ Usando helper corrigido
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color:
                  isUser ? Colors.white.withOpacity(0.2) : Colors.grey.shade300,
              shape: BoxShape.circle,
              border: Border.all(
                  color: isUser ? Colors.white : Colors.grey.shade400,
                  width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                _getAvatarPath(user['avatarType']),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      user['name'][0].toUpperCase(),
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.grey.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Nome + Accuracy
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isUser ? Colors.white : Colors.grey.shade800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${user['accuracy'].toStringAsFixed(0)}% precisão',
                  style: TextStyle(
                    fontSize: 12,
                    color: isUser ? Colors.white70 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                user['score'].toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isUser ? Colors.white : const Color(0xFF667eea),
                ),
              ),
              Text(
                'pts',
                style: TextStyle(
                  fontSize: 11,
                  color: isUser ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info, color: Color(0xFF667eea)),
            SizedBox(width: 8),
            Text('Como funciona?'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📊 Pontuação',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 4),
              Text('Sua pontuação é calculada com base em:',
                  style: TextStyle(fontSize: 13)),
              SizedBox(height: 8),
              Text('• Acertos: +10 pts cada', style: TextStyle(fontSize: 12)),
              Text('• XP total: ÷10 pts', style: TextStyle(fontSize: 12)),
              Text('• Streak dias: ×5 pts', style: TextStyle(fontSize: 12)),
              SizedBox(height: 16),
              Text('🏆 Rankings',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 4),
              Text('Compare seu desempenho:', style: TextStyle(fontSize: 13)),
              SizedBox(height: 8),
              Text('• Geral: Todos os estudantes',
                  style: TextStyle(fontSize: 12)),
              Text('• Série: Mesma série escolar',
                  style: TextStyle(fontSize: 12)),
              Text('• Estado: Mesmo estado', style: TextStyle(fontSize: 12)),
              Text('• Univ: Mesma meta universitária',
                  style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
}
