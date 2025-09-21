// lib/features/questoes/models/question_model.dart - V6.8 COMPATÍVEL
// Model unificado compatível com Firebase e algoritmo V6.8

class QuestionModel {
  final String id;
  final String subject; // 'matematica', 'portugues', 'fisica', etc.
  final String schoolLevel; // '6ano', '7ano', 'EM1', 'EM2', etc.
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

  // ===== FACTORY METHODS =====

  /// Criar a partir de dados do Firebase Firestore
  factory QuestionModel.fromFirestore(Map<String, dynamic> doc) {
    return QuestionModel(
      id: doc['id'] ?? '',
      subject: doc['subject'] ?? '',
      schoolLevel: doc['school_level'] ?? '',
      difficulty: doc['difficulty'] ?? 'medio',
      theme: doc['theme'] ?? 'floresta',
      enunciado: doc['enunciado'] ?? '',
      alternativas: List<String>.from(doc['alternativas'] ?? []),
      respostaCorreta: doc['resposta_correta'] ?? 0,
      explicacao: doc['explicacao'] ?? '',
      imagemEspecifica: doc['imagem_especifica'],
      tags: List<String>.from(doc['tags'] ?? []),
      metadata: Map<String, dynamic>.from(doc['metadata'] ?? {}),
      createdAt: doc['created_at'] != null
          ? DateTime.parse(doc['created_at'].toString())
          : DateTime.now(),
    );
  }

  /// Criar a partir de Map genérico (compatibilidade)
  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      id: map['id'] ?? '',
      subject: map['subject'] ?? '',
      schoolLevel: map['schoolLevel'] ?? '',
      difficulty: map['difficulty'] ?? 'medio',
      theme: map['theme'] ?? 'floresta',
      enunciado: map['enunciado'] ?? '',
      alternativas: List<String>.from(map['alternativas'] ?? []),
      respostaCorreta: map['respostaCorreta'] ?? 0,
      explicacao: map['explicacao'] ?? '',
      imagemEspecifica: map['imagemEspecifica'],
      tags: List<String>.from(map['tags'] ?? []),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is String
              ? DateTime.parse(map['createdAt'])
              : map['createdAt'] as DateTime)
          : DateTime.now(),
    );
  }

  /// Criar a partir de DocumentSnapshot (Firebase SDK)
  factory QuestionModel.fromDocumentSnapshot(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuestionModel(
      id: doc.id,
      subject: data['subject'] ?? '',
      schoolLevel: data['school_level'] ?? '',
      difficulty: data['difficulty'] ?? 'medio',
      theme: data['theme'] ?? 'floresta',
      enunciado: data['enunciado'] ?? '',
      alternativas: List<String>.from(data['alternativas'] ?? []),
      respostaCorreta: data['resposta_correta'] ?? 0,
      explicacao: data['explicacao'] ?? '',
      imagemEspecifica: data['imagem_especifica'],
      tags: List<String>.from(data['tags'] ?? []),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      createdAt: data['created_at']?.toDate() ?? DateTime.now(),
    );
  }

  // ===== CONVERSION METHODS =====

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'schoolLevel': schoolLevel,
      'difficulty': difficulty,
      'theme': theme,
      'enunciado': enunciado,
      'alternativas': alternativas,
      'respostaCorreta': respostaCorreta,
      'explicacao': explicacao,
      'imagemEspecifica': imagemEspecifica,
      'tags': tags,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
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
      'created_at': createdAt,
    };
  }

  // ===== UTILITY METHODS =====

  /// Verificar se é uma questão visual
  bool get isVisual => imagemEspecifica != null && imagemEspecifica!.isNotEmpty;

  /// Obter nível de dificuldade numérico (1-3)
  int get difficultyLevel {
    switch (difficulty.toLowerCase()) {
      case 'facil':
        return 1;
      case 'medio':
        return 2;
      case 'dificil':
        return 3;
      default:
        return 2;
    }
  }

  /// Verificar se está no nível escolar correto
  bool isForSchoolLevel(String targetLevel) {
    return schoolLevel.toLowerCase() == targetLevel.toLowerCase();
  }

  /// Verificar se é da matéria específica
  bool isSubject(String targetSubject) {
    return subject.toLowerCase().contains(targetSubject.toLowerCase()) ||
        targetSubject.toLowerCase().contains(subject.toLowerCase());
  }

  /// Verificar se tem tag específica
  bool hasTag(String tag) {
    return tags.any((t) => t.toLowerCase().contains(tag.toLowerCase()));
  }

  // ===== COPYWITH METHOD =====

  QuestionModel copyWith({
    String? id,
    String? subject,
    String? schoolLevel,
    String? difficulty,
    String? theme,
    String? enunciado,
    List<String>? alternativas,
    int? respostaCorreta,
    String? explicacao,
    String? imagemEspecifica,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      schoolLevel: schoolLevel ?? this.schoolLevel,
      difficulty: difficulty ?? this.difficulty,
      theme: theme ?? this.theme,
      enunciado: enunciado ?? this.enunciado,
      alternativas: alternativas ?? this.alternativas,
      respostaCorreta: respostaCorreta ?? this.respostaCorreta,
      explicacao: explicacao ?? this.explicacao,
      imagemEspecifica: imagemEspecifica ?? this.imagemEspecifica,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ===== EQUALITY AND HASH =====

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuestionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'QuestionModel(id: $id, subject: $subject, schoolLevel: $schoolLevel, difficulty: $difficulty)';
  }

  // ===== VALIDATION =====

  /// Validar se a questão tem dados obrigatórios
  bool get isValid {
    return id.isNotEmpty &&
        subject.isNotEmpty &&
        schoolLevel.isNotEmpty &&
        enunciado.isNotEmpty &&
        alternativas.isNotEmpty &&
        alternativas.length >= 2 &&
        respostaCorreta >= 0 &&
        respostaCorreta < alternativas.length &&
        explicacao.isNotEmpty;
  }

  /// Lista de problemas de validação
  List<String> get validationErrors {
    final errors = <String>[];

    if (id.isEmpty) errors.add('ID não pode estar vazio');
    if (subject.isEmpty) errors.add('Matéria não pode estar vazia');
    if (schoolLevel.isEmpty) errors.add('Nível escolar não pode estar vazio');
    if (enunciado.isEmpty) errors.add('Enunciado não pode estar vazio');
    if (alternativas.isEmpty) errors.add('Deve ter pelo menos uma alternativa');
    if (alternativas.length < 2)
      errors.add('Deve ter pelo menos 2 alternativas');
    if (respostaCorreta < 0 || respostaCorreta >= alternativas.length) {
      errors
          .add('Resposta correta deve estar dentro do range das alternativas');
    }
    if (explicacao.isEmpty) errors.add('Explicação não pode estar vazia');

    return errors;
  }
}
