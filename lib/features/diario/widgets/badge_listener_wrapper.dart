// lib/features/diario/widgets/badge_listener_wrapper.dart
// ✅ V9.4 - Sprint 9 Fase 3: Listener para mostrar modal de badge automaticamente
// 📅 Atualizado: 25/02/2026
// 🎯 Envolve qualquer tela e escuta por badges desbloqueadas

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/diary_badges_provider.dart';
import '../models/diary_badge_model.dart';
import 'badge_unlock_modal.dart';

/// Widget que escuta por badges pendentes e mostra o modal automaticamente
///
/// USO: Envolva sua tela principal com este widget
///
/// ```dart
/// BadgeListenerWrapper(
///   child: Scaffold(...),
/// )
/// ```
class BadgeListenerWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const BadgeListenerWrapper({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<BadgeListenerWrapper> createState() =>
      _BadgeListenerWrapperState();
}

class _BadgeListenerWrapperState extends ConsumerState<BadgeListenerWrapper> {
  bool _isShowingModal = false;

  @override
  void initState() {
    super.initState();
    // Verificar badges pendentes após o build inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingBadges();
    });
  }

  void _checkPendingBadges() {
    if (!mounted || _isShowingModal) return;

    final badgesState = ref.read(diaryBadgesProvider);
    if (badgesState.pendingUnlock.isNotEmpty) {
      _showNextBadgeModal();
    }
  }

  Future<void> _showNextBadgeModal() async {
    if (!mounted || _isShowingModal) return;

    final notifier = ref.read(diaryBadgesProvider.notifier);
    final badge = notifier.getNextPendingBadge();

    if (badge == null) return;

    setState(() => _isShowingModal = true);

    try {
      await BadgeUnlockModal.show(
        context: context,
        badge: badge,
      );

      // Remover da lista de pendentes
      notifier.removePendingBadge(badge.id);

      // Verificar se há mais badges pendentes
      if (mounted) {
        setState(() => _isShowingModal = false);

        // Delay pequeno antes de mostrar próxima badge
        await Future.delayed(const Duration(milliseconds: 500));
        _checkPendingBadges();
      }
    } catch (e) {
      print('❌ Erro ao mostrar modal de badge: $e');
      if (mounted) {
        setState(() => _isShowingModal = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escutar mudanças nas badges pendentes
    ref.listen<DiaryBadgesState>(diaryBadgesProvider, (previous, next) {
      // Se havia 0 pendentes e agora tem mais, mostrar modal
      final hadPending = previous?.pendingUnlock.isNotEmpty ?? false;
      final hasPending = next.pendingUnlock.isNotEmpty;

      if (!hadPending && hasPending && !_isShowingModal) {
        // Nova badge desbloqueada!
        print('🏅 Nova badge detectada! Mostrando modal...');
        _showNextBadgeModal();
      }
    });

    return widget.child;
  }
}

/// Mixin alternativo para adicionar listener em qualquer StatefulWidget
///
/// USO:
/// ```dart
/// class _MyScreenState extends ConsumerState<MyScreen>
///     with BadgeListenerMixin {
///
///   @override
///   void initState() {
///     super.initState();
///     initBadgeListener(); // Chamar no initState
///   }
/// }
/// ```
mixin BadgeListenerMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool _badgeModalShowing = false;

  void initBadgeListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForPendingBadges();
    });
  }

  void _checkForPendingBadges() {
    if (!mounted || _badgeModalShowing) return;

    final state = ref.read(diaryBadgesProvider);
    if (state.pendingUnlock.isNotEmpty) {
      _showBadgeModal();
    }
  }

  Future<void> _showBadgeModal() async {
    if (!mounted || _badgeModalShowing) return;

    final notifier = ref.read(diaryBadgesProvider.notifier);
    final badge = notifier.getNextPendingBadge();

    if (badge == null) return;

    _badgeModalShowing = true;

    try {
      await BadgeUnlockModal.show(
        context: context,
        badge: badge,
      );

      notifier.removePendingBadge(badge.id);

      if (mounted) {
        _badgeModalShowing = false;
        await Future.delayed(const Duration(milliseconds: 500));
        _checkForPendingBadges();
      }
    } catch (e) {
      print('❌ Erro badge modal: $e');
      _badgeModalShowing = false;
    }
  }

  /// Chamar este método quando quiser verificar manualmente
  void checkBadges() {
    ref.read(diaryBadgesProvider.notifier).checkBadges();
    _checkForPendingBadges();
  }
}

/// Provider para facilitar a verificação de badges em qualquer lugar
final badgeListenerProvider = Provider<BadgeListenerService>((ref) {
  return BadgeListenerService(ref);
});

class BadgeListenerService {
  final Ref _ref;

  BadgeListenerService(this._ref);

  /// Verifica se há badges pendentes
  bool get hasPendingBadges {
    return _ref.read(diaryBadgesProvider).pendingUnlock.isNotEmpty;
  }

  /// Obtém próxima badge pendente
  DiaryBadge? get nextPendingBadge {
    return _ref.read(diaryBadgesProvider.notifier).getNextPendingBadge();
  }

  /// Força verificação de badges
  void checkBadges() {
    _ref.read(diaryBadgesProvider.notifier).checkBadges();
  }

  /// Remove badge da lista de pendentes
  void removePendingBadge(String badgeId) {
    _ref.read(diaryBadgesProvider.notifier).removePendingBadge(badgeId);
  }
}
