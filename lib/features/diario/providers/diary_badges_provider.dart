// lib/features/diario/providers/diary_badges_provider.dart
// ✅ V9.3 - Sprint 9 Fase 3: Provider de Badges do Diário
// 📅 Criado: 24/02/2026
// 🎯 Verifica critérios e desbloqueia badges automaticamente

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/diary_badge_model.dart';
import '../models/diary_entry_model.dart';
import './diary_provider.dart';
import '../../../core/services/firebase_diary_service.dart';
import '../../../core/services/firebase_rest_auth.dart';

/// Estado das badges do usuário
class DiaryBadgesState {
  final List<UnlockedBadge> unlockedBadges;
  final List<DiaryBadge>
      pendingUnlock; // Badges recém-desbloqueadas (para mostrar modal)
  final bool isLoading;
  final String? error;
  final BadgeStats stats;

  DiaryBadgesState({
    this.unlockedBadges = const [],
    this.pendingUnlock = const [],
    this.isLoading = false,
    this.error,
    BadgeStats? stats,
  }) : stats = stats ?? BadgeStats();

  DiaryBadgesState copyWith({
    List<UnlockedBadge>? unlockedBadges,
    List<DiaryBadge>? pendingUnlock,
    bool? isLoading,
    String? error,
    BadgeStats? stats,
  }) {
    return DiaryBadgesState(
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      pendingUnlock: pendingUnlock ?? this.pendingUnlock,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      stats: stats ?? this.stats,
    );
  }

  /// Verificar se uma badge está desbloqueada
  bool isBadgeUnlocked(String badgeId) {
    return unlockedBadges.any((b) => b.badgeId == badgeId);
  }

  /// Obter badge desbloqueada
  UnlockedBadge? getUnlockedBadge(String badgeId) {
    try {
      return unlockedBadges.firstWhere((b) => b.badgeId == badgeId);
    } catch (e) {
      return null;
    }
  }

  /// Total de badges desbloqueadas
  int get totalUnlocked => unlockedBadges.length;

  /// Total de XP ganho com badges
  int get totalXpFromBadges =>
      unlockedBadges.fold(0, (sum, b) => sum + b.xpEarned);

  /// Progresso percentual
  double get progressPercentage => DiaryBadgeCatalog.totalBadges > 0
      ? totalUnlocked / DiaryBadgeCatalog.totalBadges
      : 0;
}

/// Estatísticas para verificação de badges
class BadgeStats {
  final int totalAnotacoes;
  final int totalTransformacoes;
  final int topicosDominados;
  final int streakDias;
  final int diasUsoTotal;
  final int sessoesfelizesConsecutivas;
  final int diasEmocaoPositiva;
  final int diasComEmocaoRegistrada;
  final int revisoesNoPrazo;
  final int diasSemAtraso;
  final int revisoesSemErro;
  final double melhoriaSemanolPercentual;
  final bool sessao100Precisao;

  BadgeStats({
    this.totalAnotacoes = 0,
    this.totalTransformacoes = 0,
    this.topicosDominados = 0,
    this.streakDias = 0,
    this.diasUsoTotal = 0,
    this.sessoesfelizesConsecutivas = 0,
    this.diasEmocaoPositiva = 0,
    this.diasComEmocaoRegistrada = 0,
    this.revisoesNoPrazo = 0,
    this.diasSemAtraso = 0,
    this.revisoesSemErro = 0,
    this.melhoriaSemanolPercentual = 0,
    this.sessao100Precisao = false,
  });

  BadgeStats copyWith({
    int? totalAnotacoes,
    int? totalTransformacoes,
    int? topicosDominados,
    int? streakDias,
    int? diasUsoTotal,
    int? sessoesfelizesConsecutivas,
    int? diasEmocaoPositiva,
    int? diasComEmocaoRegistrada,
    int? revisoesNoPrazo,
    int? diasSemAtraso,
    int? revisoesSemErro,
    double? melhoriaSemanolPercentual,
    bool? sessao100Precisao,
  }) {
    return BadgeStats(
      totalAnotacoes: totalAnotacoes ?? this.totalAnotacoes,
      totalTransformacoes: totalTransformacoes ?? this.totalTransformacoes,
      topicosDominados: topicosDominados ?? this.topicosDominados,
      streakDias: streakDias ?? this.streakDias,
      diasUsoTotal: diasUsoTotal ?? this.diasUsoTotal,
      sessoesfelizesConsecutivas:
          sessoesfelizesConsecutivas ?? this.sessoesfelizesConsecutivas,
      diasEmocaoPositiva: diasEmocaoPositiva ?? this.diasEmocaoPositiva,
      diasComEmocaoRegistrada:
          diasComEmocaoRegistrada ?? this.diasComEmocaoRegistrada,
      revisoesNoPrazo: revisoesNoPrazo ?? this.revisoesNoPrazo,
      diasSemAtraso: diasSemAtraso ?? this.diasSemAtraso,
      revisoesSemErro: revisoesSemErro ?? this.revisoesSemErro,
      melhoriaSemanolPercentual:
          melhoriaSemanolPercentual ?? this.melhoriaSemanolPercentual,
      sessao100Precisao: sessao100Precisao ?? this.sessao100Precisao,
    );
  }
}

/// Notifier das badges
class DiaryBadgesNotifier extends StateNotifier<DiaryBadgesState> {
  final Ref _ref;

  DiaryBadgesNotifier(this._ref) : super(DiaryBadgesState()) {
    // Observar mudanças no diário para verificar badges
    _ref.listen<DiaryState>(diaryProvider, (previous, next) {
      if (previous?.entries.length != next.entries.length ||
          previous?.stats.totalTransformations !=
              next.stats.totalTransformations) {
        _updateStatsAndCheckBadges(next);
      }
    });

    // Carregar badges do Firebase PRIMEIRO, depois verificar critérios.
    // Isso evita re-desbloquear badges já conquistadas após login.
    _loadBadgesAndCheck();
  }

  /// Carrega badges persistidas no Firebase e depois verifica novas
  Future<void> _loadBadgesAndCheck() async {
    try {
      final user = await FirebaseRestAuth.getCurrentUser();
      if (user != null && !user.isAnonymous && mounted) {
        final badges =
            await FirebaseDiaryService.getUnlockedBadges(user.uid);
        if (badges.isNotEmpty && mounted) {
          state = state.copyWith(unlockedBadges: badges);
          print('🏅 ${badges.length} badges restauradas do Firebase');
        }
      }
    } catch (e) {
      print('❌ Erro ao carregar badges do Firebase: $e');
    }

    // Verificar estado atual do diário (agora sabendo quais já estão desbloqueadas)
    if (!mounted) return;
    final current = _ref.read(diaryProvider);
    if (current.entries.isNotEmpty ||
        current.stats.totalTransformations > 0) {
      _updateStatsAndCheckBadges(current);
    }
  }

  /// Atualizar estatísticas baseado no estado do diário
  void _updateStatsAndCheckBadges(DiaryState diaryState) {
    // Calcular estatísticas
    final entries = diaryState.entries;

    final totalAnotacoes = entries.length;
    final totalTransformacoes = entries.where((e) => e.mastered).length;

    // Contar tópicos (matérias) dominados
    final materiasDominadas = <String>{};
    for (final entry in entries.where((e) => e.mastered)) {
      materiasDominadas.add(entry.subject);
    }
    final topicosDominados = materiasDominadas.length;

    // Calcular streak de dias
    final streakDias = _calcularStreak(entries);

    // Atualizar stats
    final newStats = state.stats.copyWith(
      totalAnotacoes: totalAnotacoes,
      totalTransformacoes: totalTransformacoes,
      topicosDominados: topicosDominados,
      streakDias: streakDias,
    );

    state = state.copyWith(stats: newStats);

    // Verificar todas as badges
    _checkAllBadges();
  }

  /// Calcular streak de dias consecutivos com anotações
  int _calcularStreak(List<DiaryEntry> entries) {
    if (entries.isEmpty) return 0;

    // Agrupar por data
    final datasComAnotacao = <DateTime>{};
    for (final entry in entries) {
      final data = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );
      datasComAnotacao.add(data);
    }

    // Ordenar datas (mais recente primeiro)
    final datasOrdenadas = datasComAnotacao.toList()
      ..sort((a, b) => b.compareTo(a));

    // Contar streak a partir de hoje
    int streak = 0;
    final hoje = DateTime.now();
    var dataAtual = DateTime(hoje.year, hoje.month, hoje.day);

    for (final data in datasOrdenadas) {
      if (data == dataAtual ||
          data == dataAtual.subtract(const Duration(days: 1))) {
        streak++;
        dataAtual = data.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Verificar todas as badges e desbloquear se necessário
  void _checkAllBadges() {
    final novasDesbloqueadas = <DiaryBadge>[];

    for (final badge in DiaryBadgeCatalog.todas) {
      // Pular se já desbloqueada
      if (state.isBadgeUnlocked(badge.id)) continue;

      // Verificar critérios
      if (_verificarCriterios(badge)) {
        novasDesbloqueadas.add(badge);
        _desbloquearBadge(badge);
      }
    }

    // Adicionar às pendentes (para mostrar modal)
    if (novasDesbloqueadas.isNotEmpty) {
      state = state.copyWith(
        pendingUnlock: [...state.pendingUnlock, ...novasDesbloqueadas],
      );
      print('🏅 ${novasDesbloqueadas.length} badge(s) desbloqueada(s)!');
    }
  }

  /// Verificar se os critérios de uma badge foram atingidos
  bool _verificarCriterios(DiaryBadge badge) {
    final stats = state.stats;
    final criterios = badge.criterios;

    // Verificar cada critério
    if (criterios.containsKey('total_anotacoes')) {
      if (stats.totalAnotacoes < (criterios['total_anotacoes'] as int)) {
        return false;
      }
    }

    if (criterios.containsKey('total_transformacoes')) {
      if (stats.totalTransformacoes <
          (criterios['total_transformacoes'] as int)) {
        return false;
      }
    }

    if (criterios.containsKey('topicos_dominados')) {
      if (stats.topicosDominados < (criterios['topicos_dominados'] as int)) {
        return false;
      }
    }

    if (criterios.containsKey('streak_dias')) {
      if (stats.streakDias < (criterios['streak_dias'] as int)) {
        return false;
      }
    }

    if (criterios.containsKey('dias_uso_total')) {
      if (stats.diasUsoTotal < (criterios['dias_uso_total'] as int)) {
        return false;
      }
    }

    if (criterios.containsKey('sessoes_felizes_consecutivas')) {
      if (stats.sessoesfelizesConsecutivas <
          (criterios['sessoes_felizes_consecutivas'] as int)) {
        return false;
      }
    }

    if (criterios.containsKey('dias_emocao_positiva')) {
      if (stats.diasEmocaoPositiva <
          (criterios['dias_emocao_positiva'] as int)) {
        return false;
      }
    }

    if (criterios.containsKey('dias_com_emocao_registrada')) {
      if (stats.diasComEmocaoRegistrada <
          (criterios['dias_com_emocao_registrada'] as int)) {
        return false;
      }
    }

    if (criterios.containsKey('revisoes_no_prazo')) {
      if (stats.revisoesNoPrazo < (criterios['revisoes_no_prazo'] as int)) {
        return false;
      }
    }

    if (criterios.containsKey('dias_sem_atraso')) {
      if (stats.diasSemAtraso < (criterios['dias_sem_atraso'] as int)) {
        return false;
      }
    }

    if (criterios.containsKey('revisoes_sem_erro')) {
      if (stats.revisoesSemErro < (criterios['revisoes_sem_erro'] as int)) {
        return false;
      }
    }

    if (criterios.containsKey('melhoria_semanal_percentual')) {
      if (stats.melhoriaSemanolPercentual <
          (criterios['melhoria_semanal_percentual'] as int)) {
        return false;
      }
    }

    if (criterios.containsKey('sessao_100_precisao')) {
      if (!stats.sessao100Precisao) {
        return false;
      }
    }

    if (criterios.containsKey('todas_badges')) {
      // Verificar se todas as outras badges estão desbloqueadas
      final outrasDesbloqueadas = state.unlockedBadges.length;
      final totalOutras = DiaryBadgeCatalog.totalBadges - 1; // Menos a própria
      if (outrasDesbloqueadas < totalOutras) {
        return false;
      }
    }

    return true;
  }

  /// Desbloquear uma badge e persistir no Firebase
  void _desbloquearBadge(DiaryBadge badge) {
    final unlocked = UnlockedBadge(
      badgeId: badge.id,
      odId: '',
      unlockedAt: DateTime.now(),
      xpEarned: badge.xpRecompensa,
    );

    state = state.copyWith(
      unlockedBadges: [...state.unlockedBadges, unlocked],
    );

    // Persistir no Firebase (fire-and-forget)
    _saveBadgeToFirebase(badge);

    print(
        '🏅 Badge desbloqueada: ${badge.emoji} ${badge.nome} (+${badge.xpRecompensa} XP)');
  }

  /// Salvar badge no Firebase
  Future<void> _saveBadgeToFirebase(DiaryBadge badge) async {
    try {
      final user = await FirebaseRestAuth.getCurrentUser();
      if (user == null || user.isAnonymous) return;
      await FirebaseDiaryService.saveUnlockedBadge(
        userId: user.uid,
        badgeId: badge.id,
        xpEarned: badge.xpRecompensa,
      );
    } catch (e) {
      print('❌ Erro ao persistir badge: $e');
    }
  }

  /// Limpar badges pendentes (após mostrar modal)
  void clearPendingBadges() {
    state = state.copyWith(pendingUnlock: []);
  }

  /// Obter próxima badge pendente para mostrar
  DiaryBadge? getNextPendingBadge() {
    if (state.pendingUnlock.isEmpty) return null;
    return state.pendingUnlock.first;
  }

  /// Remover badge da lista de pendentes
  void removePendingBadge(String badgeId) {
    final updated = state.pendingUnlock.where((b) => b.id != badgeId).toList();
    state = state.copyWith(pendingUnlock: updated);
  }

  /// Atualizar stats manualmente (chamado de outros providers)
  void updateStats({
    bool? sessao100Precisao,
    int? sessoesfelizesConsecutivas,
  }) {
    final newStats = state.stats.copyWith(
      sessao100Precisao: sessao100Precisao,
      sessoesfelizesConsecutivas: sessoesfelizesConsecutivas,
    );
    state = state.copyWith(stats: newStats);
    _checkAllBadges();
  }

  /// Forçar verificação de badges
  void checkBadges() {
    _checkAllBadges();
  }

  /// Obter badges por categoria
  List<DiaryBadge> getBadgesByCategory(BadgeCategory categoria) {
    return DiaryBadgeCatalog.getBadgesByCategory(categoria);
  }

  /// Obter todas as badges com status de desbloqueio
  List<({DiaryBadge badge, bool unlocked, DateTime? unlockedAt})>
      getAllBadgesWithStatus() {
    return DiaryBadgeCatalog.todas.map((badge) {
      final unlocked = state.getUnlockedBadge(badge.id);
      return (
        badge: badge,
        unlocked: unlocked != null,
        unlockedAt: unlocked?.unlockedAt,
      );
    }).toList();
  }
}

// ═══════════════════════════════════════════
// 📦 PROVIDERS
// ═══════════════════════════════════════════

final diaryBadgesProvider =
    StateNotifierProvider<DiaryBadgesNotifier, DiaryBadgesState>((ref) {
  return DiaryBadgesNotifier(ref);
});

/// Provider para verificar se há badges pendentes
final hasPendingBadgesProvider = Provider<bool>((ref) {
  final state = ref.watch(diaryBadgesProvider);
  return state.pendingUnlock.isNotEmpty;
});

/// Provider para obter contagem de badges
final badgeCountProvider = Provider<({int unlocked, int total})>((ref) {
  final state = ref.watch(diaryBadgesProvider);
  return (
    unlocked: state.totalUnlocked,
    total: DiaryBadgeCatalog.totalBadges,
  );
});
