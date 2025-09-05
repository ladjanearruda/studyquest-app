// lib/features/modos/models/modo_jogo.dart
// StudyQuest V6.2 - Modelo dos Modos de Jogo

enum ModoJogoType {
  missaoInteligente,
  focoTrilha,
  focoMateria,
}

enum TrilhaType {
  exatas,
  humanas,
  linguagens,
  natureza,
}

enum MateriaType {
  matematica,
  portugues,
  fisica,
  quimica,
  biologia,
  historia,
  geografia,
  filosofia,
  sociologia,
  literatura,
  redacao,
  ingles,
}

class ModoJogo {
  final ModoJogoType tipo;
  final String nome;
  final String descricao;
  final String icone;
  final String algoritmo;
  final List<String> caracteristicas;
  final String botaoTexto;
  final bool isRecomendado;
  final bool isSessaoExtra;
  final String corPrimaria;
  final String corSecundaria;

  const ModoJogo({
    required this.tipo,
    required this.nome,
    required this.descricao,
    required this.icone,
    required this.algoritmo,
    required this.caracteristicas,
    required this.botaoTexto,
    this.isRecomendado = false,
    this.isSessaoExtra = false,
    required this.corPrimaria,
    required this.corSecundaria,
  });

  // Factory constructors para cada modo
  static ModoJogo get missaoInteligente => const ModoJogo(
        tipo: ModoJogoType.missaoInteligente,
        nome: 'Missão Inteligente',
        descricao:
            'Jornada principal personalizada baseada no seu perfil completo. Algoritmo inteligente que combina seus objetivos e interesses.',
        icone: '🎯',
        algoritmo: 'Perfil completo do onboarding',
        caracteristicas: [
          'Progresso salvo',
          'Algoritmo inteligente',
          'Jornada principal',
          'Recomendado'
        ],
        botaoTexto: '🚀 Iniciar Missão',
        isRecomendado: true,
        corPrimaria: '#4CAF50',
        corSecundaria: '#66BB6A',
      );

  static ModoJogo get focoTrilha => const ModoJogo(
        tipo: ModoJogoType.focoTrilha,
        nome: 'Foco Trilha',
        descricao:
            'Sessão pontual focada em uma área específica do conhecimento. Explore Exatas, Humanas, Linguagens ou Natureza.',
        icone: '🛤️',
        algoritmo: 'Perfil + concentração na trilha',
        caracteristicas: [
          'Sessão extra',
          '4 trilhas disponíveis',
          'Não altera jornada',
          'Exploração focada'
        ],
        botaoTexto: '🗺️ Explorar Trilhas',
        isSessaoExtra: true,
        corPrimaria: '#2196F3',
        corSecundaria: '#64B5F6',
      );

  static ModoJogo get focoMateria => const ModoJogo(
        tipo: ModoJogoType.focoMateria,
        nome: 'Foco Matéria',
        descricao:
            'Aprofunde-se em uma disciplina específica. Ideal para reforçar conteúdos ou se preparar para provas pontuais.',
        icone: '🔍',
        algoritmo: 'Perfil + concentração na matéria',
        caracteristicas: [
          'Sessão extra',
          'Disciplina específica',
          'Não altera jornada',
          'Aprofundamento'
        ],
        botaoTexto: '🔍 Escolher Matéria',
        isSessaoExtra: true,
        corPrimaria: '#9C27B0',
        corSecundaria: '#BA68C8',
      );

  // Lista completa dos modos
  static List<ModoJogo> get todosModos => [
        missaoInteligente,
        focoTrilha,
        focoMateria,
      ];

  // Método para obter cor como Color object
  int get corPrimariaInt =>
      int.parse(corPrimaria.substring(1), radix: 16) + 0xFF000000;
  int get corSecundariaInt =>
      int.parse(corSecundaria.substring(1), radix: 16) + 0xFF000000;
}

// Extensões para TrilhaType
extension TrilhaTypeExtension on TrilhaType {
  String get nome {
    switch (this) {
      case TrilhaType.exatas:
        return 'Matemática e Exatas';
      case TrilhaType.humanas:
        return 'Ciências Humanas';
      case TrilhaType.linguagens:
        return 'Linguagens e Códigos';
      case TrilhaType.natureza:
        return 'Ciências da Natureza';
    }
  }

  String get icone {
    switch (this) {
      case TrilhaType.exatas:
        return '🧮';
      case TrilhaType.humanas:
        return '📚';
      case TrilhaType.linguagens:
        return '✍️';
      case TrilhaType.natureza:
        return '🔬';
    }
  }

  String get descricao {
    switch (this) {
      case TrilhaType.exatas:
        return 'Matemática, Física, Química, Tecnologia';
      case TrilhaType.humanas:
        return 'História, Geografia, Filosofia, Sociologia';
      case TrilhaType.linguagens:
        return 'Português, Literatura, Inglês, Redação';
      case TrilhaType.natureza:
        return 'Biologia, Química, Física, Meio Ambiente';
    }
  }
}

// Extensões para MateriaType
extension MateriaTypeExtension on MateriaType {
  String get nome {
    switch (this) {
      case MateriaType.matematica:
        return 'Matemática';
      case MateriaType.portugues:
        return 'Português';
      case MateriaType.fisica:
        return 'Física';
      case MateriaType.quimica:
        return 'Química';
      case MateriaType.biologia:
        return 'Biologia';
      case MateriaType.historia:
        return 'História';
      case MateriaType.geografia:
        return 'Geografia';
      case MateriaType.filosofia:
        return 'Filosofia';
      case MateriaType.sociologia:
        return 'Sociologia';
      case MateriaType.literatura:
        return 'Literatura';
      case MateriaType.redacao:
        return 'Redação';
      case MateriaType.ingles:
        return 'Inglês';
    }
  }

  String get icone {
    switch (this) {
      case MateriaType.matematica:
        return '📐';
      case MateriaType.portugues:
        return '📖';
      case MateriaType.fisica:
        return '⚡';
      case MateriaType.quimica:
        return '🧪';
      case MateriaType.biologia:
        return '🦠';
      case MateriaType.historia:
        return '🏛️';
      case MateriaType.geografia:
        return '🗺️';
      case MateriaType.filosofia:
        return '🤔';
      case MateriaType.sociologia:
        return '👥';
      case MateriaType.literatura:
        return '📜';
      case MateriaType.redacao:
        return '✍️';
      case MateriaType.ingles:
        return '🇺🇸';
    }
  }

  TrilhaType get trilha {
    switch (this) {
      case MateriaType.matematica:
      case MateriaType.fisica:
        return TrilhaType.exatas;
      case MateriaType.historia:
      case MateriaType.geografia:
      case MateriaType.filosofia:
      case MateriaType.sociologia:
        return TrilhaType.humanas;
      case MateriaType.portugues:
      case MateriaType.literatura:
      case MateriaType.redacao:
      case MateriaType.ingles:
        return TrilhaType.linguagens;
      case MateriaType.quimica:
      case MateriaType.biologia:
        return TrilhaType.natureza;
    }
  }
}
