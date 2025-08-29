// lib/core/models/question_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String id;
  final String subject; // 'matematica', 'portugues', 'fisica', etc.
  final String schoolLevel; // 'fundamental6', 'fundamental7', etc.
  final String difficulty; // 'facil', 'medio', 'dificil'
  final String theme; // 'floresta' (Amazônia)
  final String enunciado;
  final List<String> alternativas;
  final int respostaCorreta; // index da resposta correta
  final String explicacao;
  final String? imagemEspecifica; // para questões visuais
  final List<String> tags; // ['matematica_basica', 'area', 'geometria']
  final Map<String, dynamic> metadata; // dados para personalização
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
    this.imagemEspecifica,
    required this.tags,
    required this.metadata,
    required this.createdAt,
  });

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuestionModel(
      id: doc.id,
      subject: data['subject'] ?? '',
      schoolLevel: data['school_level'] ?? 'fundamental9',
      difficulty: data['difficulty'] ?? 'medio',
      theme: data['theme'] ?? 'floresta',
      enunciado: data['enunciado'] ?? '',
      alternativas: List<String>.from(data['alternativas'] ?? []),
      respostaCorreta: data['resposta_correta'] ?? 0,
      explicacao: data['explicacao'] ?? '',
      imagemEspecifica: data['imagem_especifica'],
      tags: List<String>.from(data['tags'] ?? []),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  // Factory para criar questões localmente (para testes)
  factory QuestionModel.createLocal({
    required String id,
    required String subject,
    required String schoolLevel,
    required String difficulty,
    required String enunciado,
    required List<String> alternativas,
    required int respostaCorreta,
    required String explicacao,
    String? imagemEspecifica,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return QuestionModel(
      id: id,
      subject: subject,
      schoolLevel: schoolLevel,
      difficulty: difficulty,
      theme: 'floresta',
      enunciado: enunciado,
      alternativas: alternativas,
      respostaCorreta: respostaCorreta,
      explicacao: explicacao,
      imagemEspecifica: imagemEspecifica,
      tags: tags ?? [],
      metadata: metadata ?? {},
      createdAt: DateTime.now(),
    );
  }

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
      'imagem_especifica': imagemEspecifica,
      'tags': tags,
      'metadata': metadata,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  // Helper para verificar se questão é adequada para usuário
  bool isAppropriateForUser(String userSchoolLevel, String userInterestArea) {
    // Verificar nível escolar
    if (schoolLevel != userSchoolLevel) {
      return false;
    }

    // Verificar se matéria está nas áreas de interesse
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

  // Helper para obter cor da matéria
  String getSubjectColor() {
    const Map<String, String> subjectColors = {
      'matematica': '#F44336', // Vermelho
      'portugues': '#9C27B0', // Roxo
      'fisica': '#2196F3', // Azul
      'quimica': '#FF9800', // Laranja
      'biologia': '#4CAF50', // Verde
      'historia': '#FFC107', // Amarelo
      'geografia': '#795548', // Marrom
      'ingles': '#3F51B5', // Índigo
    };
    return subjectColors[subject] ?? '#9E9E9E';
  }

  // Helper para obter emoji da matéria
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
    return 'QuestionModel(id: $id, subject: $subject, difficulty: $difficulty)';
  }
}
