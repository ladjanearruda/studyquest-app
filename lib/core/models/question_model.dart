// lib/core/models/question_model.dart - CORRIGIDO PARA AVENTURA FLORESTA
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String id;
  final String subject; // 'matematica', 'portugues', 'fisica', etc.
  final String schoolLevel; // '6ano', '7ano', '8ano', '9ano'
  final String difficulty; // 'facil', 'medio', 'dificil'
  final String theme; // 'floresta_amazonica'

  // 🎮 CONTEXTO AVENTURA (ADICIONADO)
  final String enunciado; // "Para atravessar o rio Amazonas..."
  final List<String> alternativas;
  final int respostaCorreta;
  final String explicacao;

  // 🧭 ELEMENTOS NARRATIVOS AVENTURA (NOVOS)
  final String
      aventuraContexto; // "navegacao_rio", "sobrevivencia", "exploracao"
  final String
      personagemSituacao; // "explorador_perdido", "biologa_pesquisando"
  final String localFloresta; // "margem_rio", "copa_arvores", "trilha_mata"

  // 📊 PERSONALIZAÇÃO ALGORITMO 70/30 (NOVOS)
  final String
      aspectoComportamental; // 'foco_concentracao', 'organizacao_planejamento'
  final String estiloAprendizado; // 'visual', 'pratico', 'teorico'

  // 🎯 CAMPOS EXISTENTES MANTIDOS
  final String? imagemEspecifica;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const QuestionModel({
    required this.id,
    required this.subject,
    required this.schoolLevel,
    required this.difficulty,
    required this.theme,
    required this.enunciado,
    required this.alternativas,
    required this.respostaCorreta,
    required this.explicacao,
    // NOVOS CAMPOS AVENTURA
    required this.aventuraContexto,
    required this.personagemSituacao,
    required this.localFloresta,
    required this.aspectoComportamental,
    required this.estiloAprendizado,
    // CAMPOS EXISTENTES
    this.imagemEspecifica,
    required this.tags,
    required this.metadata,
    required this.createdAt,
  });

  // 🔥 FROM FIRESTORE ATUALIZADO
  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuestionModel(
      id: doc.id,
      subject: data['subject'] ?? '',
      schoolLevel: data['school_level'] ?? '9ano',
      difficulty: data['difficulty'] ?? 'medio',
      theme: data['theme'] ?? 'floresta_amazonica',
      enunciado: data['enunciado'] ?? '',
      alternativas: List<String>.from(data['alternativas'] ?? []),
      respostaCorreta: data['resposta_correta'] ?? 0,
      explicacao: data['explicacao'] ?? '',
      // NOVOS CAMPOS
      aventuraContexto: data['aventura_contexto'] ?? 'exploracao',
      personagemSituacao: data['personagem_situacao'] ?? 'explorador_perdido',
      localFloresta: data['local_floresta'] ?? 'trilha_mata',
      aspectoComportamental:
          data['aspecto_comportamental'] ?? 'foco_concentracao',
      estiloAprendizado: data['estilo_aprendizado'] ?? 'pratico',
      // CAMPOS EXISTENTES
      imagemEspecifica: data['imagem_especifica'],
      tags: List<String>.from(data['tags'] ?? []),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // 🔥 TO FIRESTORE ATUALIZADO
  Map<String, dynamic> toFirestore() {
    return {
      'subject': subject,
      'school_level': schoolLevel,
      'difficulty': difficulty,
      'theme': theme,
      'enunciado': enunciado,
      'alternativas': alternativas,
      'resposta_correta': respostaCorreta,
      'explicacao': explicacao,
      // NOVOS CAMPOS
      'aventura_contexto': aventuraContexto,
      'personagem_situacao': personagemSituacao,
      'local_floresta': localFloresta,
      'aspecto_comportamental': aspectoComportamental,
      'estilo_aprendizado': estiloAprendizado,
      // CAMPOS EXISTENTES
      'imagem_especifica': imagemEspecifica,
      'tags': tags,
      'metadata': metadata,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  // 🔥 CREATE LOCAL ATUALIZADO (para manter compatibilidade)
  factory QuestionModel.createLocal({
    required String id,
    required String subject,
    required String schoolLevel,
    required String difficulty,
    required String enunciado,
    required List<String> alternativas,
    required int respostaCorreta,
    required String explicacao,
    // NOVOS PARÂMETROS OPCIONAIS COM DEFAULTS
    String aventuraContexto = 'exploracao',
    String personagemSituacao = 'explorador_perdido',
    String localFloresta = 'trilha_mata',
    String aspectoComportamental = 'foco_concentracao',
    String estiloAprendizado = 'pratico',
    // EXISTENTES
    String? imagemEspecifica,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return QuestionModel(
      id: id,
      subject: subject,
      schoolLevel: schoolLevel,
      difficulty: difficulty,
      theme: 'floresta_amazonica',
      enunciado: enunciado,
      alternativas: alternativas,
      respostaCorreta: respostaCorreta,
      explicacao: explicacao,
      // NOVOS CAMPOS COM DEFAULTS
      aventuraContexto: aventuraContexto,
      personagemSituacao: personagemSituacao,
      localFloresta: localFloresta,
      aspectoComportamental: aspectoComportamental,
      estiloAprendizado: estiloAprendizado,
      // EXISTENTES
      imagemEspecifica: imagemEspecifica,
      tags: tags ?? [],
      metadata: metadata ?? {},
      createdAt: DateTime.now(),
    );
  }

  // 🎯 MÉTODOS EXISTENTES MANTIDOS
  bool isAppropriateForUser(String userSchoolLevel, String userInterestArea) {
    if (schoolLevel != userSchoolLevel) {
      return false;
    }
    return _subjectMatchesInterestArea(subject, userInterestArea);
  }

  bool _subjectMatchesInterestArea(String subject, String interestArea) {
    const Map<String, List<String>> interestMapping = {
      'linguagens': ['portugues', 'ingles'],
      'cienciasNatureza': ['matematica', 'fisica', 'quimica', 'biologia'],
      'matematicaTecnologia': ['matematica', 'fisica'],
      'humanas': ['historia', 'geografia', 'portugues'],
      'negocios': ['matematica', 'portugues', 'historia'],
      'descobrindo': [
        'matematica',
        'portugues',
        'fisica',
        'quimica',
        'biologia',
        'historia',
        'geografia',
        'ingles'
      ],
    };
    return interestMapping[interestArea]?.contains(subject) ?? true;
  }

  String getSubjectColor() {
    const Map<String, String> subjectColors = {
      'matematica': '#F44336',
      'portugues': '#9C27B0',
      'fisica': '#2196F3',
      'quimica': '#FF9800',
      'biologia': '#4CAF50',
      'historia': '#FFC107',
      'geografia': '#795548',
      'ingles': '#3F51B5',
    };
    return subjectColors[subject] ?? '#9E9E9E';
  }

  String getSubjectEmoji() {
    const Map<String, String> subjectEmojis = {
      'matematica': '🔢',
      'portugues': '📖',
      'fisica': '⚛️',
      'quimica': '⚗️',
      'biologia': '🧬',
      'historia': '📚',
      'geografia': '🌍',
      'ingles': '🇺🇸',
    };
    return subjectEmojis[subject] ?? '📝';
  }

  @override
  String toString() {
    return 'QuestionModel(id: $id, subject: $subject, difficulty: $difficulty, context: $aventuraContexto)';
  }
}
