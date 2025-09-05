// lib/features/modos/providers/modo_provider.dart
// StudyQuest V6.2 - Provider para Gestão dos Modos de Jogo

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/modo_jogo.dart';

// ===== ESTADO DOS MODOS =====
class ModoState {
  final ModoJogo? modoSelecionado;
  final TrilhaType? trilhaSelecionada;
  final MateriaType? materiaSelecionada;
  final bool isLoading;
  final String? error;
  final bool isModalTrilhaAberto;
  final bool isModalMateriaAberto;

  const ModoState({
    this.modoSelecionado,
    this.trilhaSelecionada,
    this.materiaSelecionada,
    this.isLoading = false,
    this.error,
    this.isModalTrilhaAberto = false,
    this.isModalMateriaAberto = false,
  });

  ModoState copyWith({
    ModoJogo? modoSelecionado,
    TrilhaType? trilhaSelecionada,
    MateriaType? materiaSelecionada,
    bool? isLoading,
    String? error,
    bool? isModalTrilhaAberto,
    bool? isModalMateriaAberto,
  }) {
    return ModoState(
      modoSelecionado: modoSelecionado ?? this.modoSelecionado,
      trilhaSelecionada: trilhaSelecionada ?? this.trilhaSelecionada,
      materiaSelecionada: materiaSelecionada ?? this.materiaSelecionada,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isModalTrilhaAberto: isModalTrilhaAberto ?? this.isModalTrilhaAberto,
      isModalMateriaAberto: isModalMateriaAberto ?? this.isModalMateriaAberto,
    );
  }

  // Método para limpar seleções
  ModoState cleared() {
    return const ModoState();
  }

  // Verificar se pode navegar
  bool get canNavigate {
    if (modoSelecionado == null) return false;

    switch (modoSelecionado!.tipo) {
      case ModoJogoType.missaoInteligente:
        return true; // Pode navegar diretamente
      case ModoJogoType.focoTrilha:
        return trilhaSelecionada != null; // Precisa selecionar trilha
      case ModoJogoType.focoMateria:
        return materiaSelecionada != null; // Precisa selecionar matéria
    }
  }

  // Obter contexto completo para algoritmo
  Map<String, dynamic> get contextoAlgoritmo {
    return {
      'modo': modoSelecionado?.tipo.name,
      'trilha': trilhaSelecionada?.name,
      'materia': materiaSelecionada?.name,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
}

// ===== NOTIFIER DOS MODOS =====
class ModoNotifier extends StateNotifier<ModoState> {
  ModoNotifier() : super(const ModoState());

  // Selecionar modo principal
  void selecionarModo(ModoJogo modo) {
    state = state.copyWith(
      modoSelecionado: modo,
      trilhaSelecionada: null, // Limpar seleções anteriores
      materiaSelecionada: null,
      isModalTrilhaAberto: false,
      isModalMateriaAberto: false,
      error: null,
    );

    // Auto-abrir modais se necessário
    if (modo.tipo == ModoJogoType.focoTrilha) {
      abrirModalTrilha();
    } else if (modo.tipo == ModoJogoType.focoMateria) {
      abrirModalMateria();
    }
  }

  // Selecionar trilha
  void selecionarTrilha(TrilhaType trilha) {
    state = state.copyWith(
      trilhaSelecionada: trilha,
      isModalTrilhaAberto: false,
      error: null,
    );
  }

  // Selecionar matéria
  void selecionarMateria(MateriaType materia) {
    state = state.copyWith(
      materiaSelecionada: materia,
      isModalMateriaAberto: false,
      error: null,
    );
  }

  // Abrir/fechar modais
  void abrirModalTrilha() {
    state = state.copyWith(
      isModalTrilhaAberto: true,
      isModalMateriaAberto: false,
    );
  }

  void fecharModalTrilha() {
    state = state.copyWith(isModalTrilhaAberto: false);
  }

  void abrirModalMateria() {
    state = state.copyWith(
      isModalMateriaAberto: true,
      isModalTrilhaAberto: false,
    );
  }

  void fecharModalMateria() {
    state = state.copyWith(isModalMateriaAberto: false);
  }

  // Voltar à seleção de modo
  void voltarParaModos() {
    state = state.copyWith(
      modoSelecionado: null,
      trilhaSelecionada: null,
      materiaSelecionada: null,
      isModalTrilhaAberto: false,
      isModalMateriaAberto: false,
      error: null,
    );
  }

  // Confirmar seleção e preparar navegação
  Map<String, dynamic> confirmarSelecao() {
    if (!state.canNavigate) {
      state = state.copyWith(
        error: 'Seleção incompleta. Verifique os campos obrigatórios.',
      );
      return {};
    }

    final contexto = state.contextoAlgoritmo;

    // Log para debug
    print('🎯 Modo selecionado: ${state.modoSelecionado?.nome}');
    if (state.trilhaSelecionada != null) {
      print('🛤️ Trilha: ${state.trilhaSelecionada?.nome}');
    }
    if (state.materiaSelecionada != null) {
      print('🔍 Matéria: ${state.materiaSelecionada?.nome}');
    }

    return contexto;
  }

  // Reset completo
  void reset() {
    state = const ModoState();
  }

  // Setar loading state
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  // Setar erro
  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  // Limpar erro
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ===== PROVIDERS =====

// Provider principal dos modos
final modoProvider = StateNotifierProvider<ModoNotifier, ModoState>((ref) {
  return ModoNotifier();
});

// Provider para lista de modos disponíveis
final modosDisponiveis = Provider<List<ModoJogo>>((ref) {
  return ModoJogo.todosModos;
});

// Provider para trilhas disponíveis
final trilhasDisponiveis = Provider<List<TrilhaType>>((ref) {
  return TrilhaType.values;
});

// Provider para matérias por trilha
final materiasPorTrilha =
    Provider.family<List<MateriaType>, TrilhaType?>((ref, trilha) {
  if (trilha == null) return MateriaType.values;

  return MateriaType.values
      .where((materia) => materia.trilha == trilha)
      .toList();
});

// Provider para matérias disponíveis (todas)
final materiasDisponiveis = Provider<List<MateriaType>>((ref) {
  return MateriaType.values;
});

// Providers computed para UI
final modoSelecionado = Provider<ModoJogo?>((ref) {
  return ref.watch(modoProvider).modoSelecionado;
});

final canNavigate = Provider<bool>((ref) {
  return ref.watch(modoProvider).canNavigate;
});

final isModalTrilhaAberto = Provider<bool>((ref) {
  return ref.watch(modoProvider).isModalTrilhaAberto;
});

final isModalMateriaAberto = Provider<bool>((ref) {
  return ref.watch(modoProvider).isModalMateriaAberto;
});

final modoError = Provider<String?>((ref) {
  return ref.watch(modoProvider).error;
});

// Provider para próxima rota baseada na seleção
final proximaRota = Provider<String?>((ref) {
  final state = ref.watch(modoProvider);

  if (!state.canNavigate) return null;

  switch (state.modoSelecionado!.tipo) {
    case ModoJogoType.missaoInteligente:
      return '/questoes'; // Rota principal das questões
    case ModoJogoType.focoTrilha:
      return '/questoes/trilha/${state.trilhaSelecionada!.name}';
    case ModoJogoType.focoMateria:
      return '/questoes/materia/${state.materiaSelecionada!.name}';
  }
});
