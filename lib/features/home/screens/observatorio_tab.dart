// lib/features/home/screens/observatorio_tab.dart
// ✅ Sprint 10 - Rankings Reais do Firebase (REST API)
// 📅 Atualizado: 18/03/2026

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firebase_user_service.dart';
import '../../../core/services/firebase_rest_auth.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../niveis/providers/nivel_provider.dart';

class ObservatorioTab extends ConsumerStatefulWidget {
  const ObservatorioTab({super.key});

  @override
  ConsumerState<ObservatorioTab> createState() => _ObservatorioTabState();
}

class _ObservatorioTabState extends ConsumerState<ObservatorioTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _topRanking = [];
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) setState(() {});
    });
    _loadRanking();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRanking() async {
    setState(() => _isLoading = true);
    try {
      final user = await FirebaseRestAuth.getCurrentUser();
      final ranking = await FirebaseUserService.getTopByXp(limit: 30);
      if (mounted) {
        setState(() {
          _topRanking = ranking;
          _currentUserId = user?.uid;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  /// Path do avatar sem prefixo "assets/" (Flutter Web adiciona automaticamente)
  String _avatarPath(String type, String gender) {
    final t = type.isNotEmpty ? type : 'explorador';
    final g = gender.isNotEmpty ? gender : 'masculino';
    return 'images/avatars/$t/$g/${t}_${g}_neutro.png';
  }

  String _levelLabel(String level) {
    const labels = {
      'fundamental6': '6º Ano',
      'fundamental7': '7º Ano',
      'fundamental8': '8º Ano',
      'fundamental9': '9º Ano',
      'medio1': '1º EM',
      'medio2': '2º EM',
      'medio3': '3º EM',
      'completed': 'Formado',
    };
    return labels[level] ?? '';
  }

  /// Filtra o top 30 por nível escolar e renumera posições
  List<Map<String, dynamic>> _rankingBySerie(String educationLevel) {
    if (educationLevel.isEmpty) return _topRanking;
    final filtered = _topRanking
        .where((r) => r['education_level'] == educationLevel)
        .toList();
    for (int i = 0; i < filtered.length; i++) {
      filtered[i] = {...filtered[i], 'position': i + 1};
    }
    return filtered;
  }

  Map<String, String> _cardDataByTab(
      OnboardingData onboarding, int xp, int? position) {
    final posStr = position != null ? '#$position no Geral' : 'Fora do Top 30';
    final level = onboarding.educationLevel?.name ?? '';
    final levelLabel = _levelLabel(level);
    final serieRanking = _rankingBySerie(level);
    final mySerieEntry =
        serieRanking.where((r) => r['userId'] == _currentUserId).firstOrNull;
    final seriePos = mySerieEntry != null
        ? '#${mySerieEntry['position']} na Série'
        : 'Ranking da Série';
    final univ = onboarding.dreamUniversity;

    switch (_tabController.index) {
      case 0:
        return {'info1': '$xp XP', 'info2': posStr};
      case 1:
        return {
          'info1': levelLabel.isNotEmpty ? levelLabel : 'Série',
          'info2': seriePos,
        };
      case 2:
        return {'info1': 'Estado', 'info2': 'Em Breve'};
      case 3:
        return {
          'info1':
              (univ != null && univ.isNotEmpty) ? 'Meta: $univ' : 'Meta: —',
          'info2': 'Em Breve',
        };
      default:
        return {'info1': '$xp XP', 'info2': posStr};
    }
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);
    final nivel = ref.watch(nivelProvider);
    final xp = nivel.xpTotal;

    int? myPosition;
    if (_currentUserId != null) {
      final myEntry =
          _topRanking.where((r) => r['userId'] == _currentUserId).firstOrNull;
      myPosition = myEntry?['position'] as int?;
    }

    final avatarType = onboarding.selectedAvatarType?.name ?? 'explorador';
    final avatarGender = onboarding.selectedAvatarGender?.name ?? 'masculino';
    final userName =
        (onboarding.name != null && onboarding.name!.isNotEmpty)
            ? onboarding.name!
            : 'Você';

    final serieRanking =
        _rankingBySerie(onboarding.educationLevel?.name ?? '');

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
              _buildUserCard(
                name: userName,
                avatarType: avatarType,
                avatarGender: avatarGender,
                cardData: _cardDataByTab(onboarding, xp, myPosition),
              ),
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
                      _buildRankingList(_topRanking),
                      _buildRankingList(
                        serieRanking,
                        emptyMsg:
                            'Nenhum estudante da sua série no ranking ainda!\nContinue jogando para aparecer aqui.',
                      ),
                      _buildEmBreve(
                        'Estado',
                        Icons.location_on,
                        'Em breve você poderá competir com estudantes do seu estado!',
                      ),
                      _buildEmBreve(
                        'Universidade',
                        Icons.school,
                        'Em breve você poderá competir com quem tem a mesma meta universitária!',
                      ),
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

  // ── Widgets ──────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
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
                Text(
                  'Observatório',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5),
                ),
                Text(
                  'Rankings Educacionais',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _showInfoDialog,
            icon:
                const Icon(Icons.info_outline, color: Colors.white, size: 24),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : IconButton(
                    onPressed: _loadRanking,
                    icon: const Icon(Icons.refresh,
                        color: Colors.white, size: 24),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard({
    required String name,
    required String avatarType,
    required String avatarGender,
    required Map<String, String> cardData,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 2),
      tween: Tween(begin: 0.96, end: 1.0),
      curve: Curves.easeInOut,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 100,
        child: Row(
          children: [
            // Avatar real do usuário
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFe361ff).withValues(alpha: 0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  _avatarPath(avatarType, avatarGender),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFe361ff),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'V',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Card dinâmico por tab
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: Container(
                  key: ValueKey(_tabController.index),
                  height: 72,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFe361ff), Color(0xFFa855f7)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFe361ff).withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(cardData['info1']!,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white70)),
                          const SizedBox(width: 10),
                          Text(cardData['info2']!,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ],
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
        color: Colors.white.withValues(alpha: 0.2),
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
        labelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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

  Widget _buildRankingList(
    List<Map<String, dynamic>> ranking, {
    String emptyMsg =
        'Nenhum usuário no ranking ainda.\nJogue questões para aparecer aqui!',
  }) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (ranking.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              Text(
                emptyMsg,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15, color: Colors.grey.shade600, height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRanking,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ranking.length,
        itemBuilder: (context, index) => _buildRankingCard(ranking[index]),
      ),
    );
  }

  Widget _buildRankingCard(Map<String, dynamic> user) {
    final isMe = user['userId'] == _currentUserId;
    final position = user['position'] as int;
    final avatarType = user['avatar_type'] as String? ?? 'explorador';
    final avatarGender = user['avatar_gender'] as String? ?? 'masculino';
    final xp = user['xp_total'] as int? ?? 0;
    final name = user['name'] as String? ?? 'Explorador';
    final level = user['education_level'] as String? ?? '';

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
        gradient: isMe
            ? const LinearGradient(
                colors: [Color(0xFFe361ff), Color(0xFFa855f7)])
            : null,
        color: isMe ? null : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe ? const Color(0xFFe361ff) : Colors.grey.shade300,
          width: isMe ? 2 : 1,
        ),
        boxShadow: isMe
            ? [
                BoxShadow(
                    color: const Color(0xFFe361ff).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4))
              ]
            : null,
      ),
      child: Row(
        children: [
          // Posição / medalha
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isMe
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: medalIcon != null
                  ? Icon(medalIcon, color: medalColor, size: 24)
                  : Text(
                      '#$position',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isMe ? Colors.white : Colors.grey.shade700),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar real
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isMe
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.grey.shade300,
              shape: BoxShape.circle,
              border: Border.all(
                  color: isMe ? Colors.white : Colors.grey.shade400, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                _avatarPath(avatarType, avatarGender),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                        color: isMe ? Colors.white : Colors.grey.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Nome + série + badge "Você"
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isMe ? Colors.white : Colors.grey.shade800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Você',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                if (level.isNotEmpty)
                  Text(
                    _levelLabel(level),
                    style: TextStyle(
                        fontSize: 12,
                        color: isMe ? Colors.white70 : Colors.grey.shade600),
                  ),
              ],
            ),
          ),
          // XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$xp',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isMe ? Colors.white : const Color(0xFF667eea),
                ),
              ),
              Text(
                'XP',
                style: TextStyle(
                  fontSize: 11,
                  color: isMe ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmBreve(String title, IconData icon, String message) {
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
            child: Icon(icon, color: Colors.amber.shade700, size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            'Ranking $title',
            style: const TextStyle(
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
            child: Row(
              children: [
                Icon(Icons.construction,
                    color: Colors.amber.shade700, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.amber.shade900,
                        height: 1.3),
                    textAlign: TextAlign.center,
                  ),
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
                fontStyle: FontStyle.italic),
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
              Text('⭐ Pontuação',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 4),
              Text(
                  'O ranking é baseado no XP total acumulado jogando questões.',
                  style: TextStyle(fontSize: 13)),
              SizedBox(height: 16),
              Text('🏆 Rankings',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 4),
              Text('Compare seu desempenho:',
                  style: TextStyle(fontSize: 13)),
              SizedBox(height: 8),
              Text('• Geral: Todos os estudantes',
                  style: TextStyle(fontSize: 12)),
              Text('• Série: Mesma série escolar (filtra o Top 30)',
                  style: TextStyle(fontSize: 12)),
              Text('• Estado: Em breve', style: TextStyle(fontSize: 12)),
              Text('• Univ: Em breve', style: TextStyle(fontSize: 12)),
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
