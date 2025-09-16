// lib/core/data/questions_database.dart - FALLBACK INTELIGENTE
import '../models/question_model.dart';

class QuestionsDatabase {
  /// Buscar questões por nível escolar - MÉTODO PRINCIPAL DE FALLBACK
  static List<QuestionModel> getQuestionsByLevel(String schoolLevel,
      {int limit = 20}) {
    print('📦 Usando fallback local para nível: $schoolLevel');

    // Filtrar por nível exato primeiro
    var exactMatches = _allQuestions
        .where((data) => data['school_level'] == schoolLevel)
        .toList();

    // Se não tiver questões suficientes para o nível exato, usar níveis próximos
    if (exactMatches.length < limit) {
      print(
          '⚠️ Apenas ${exactMatches.length} questões para $schoolLevel - expandindo busca...');

      final nearbyLevels = _getNearbyLevels(schoolLevel);
      for (final nearbyLevel in nearbyLevels) {
        final additional = _allQuestions
            .where((data) => data['school_level'] == nearbyLevel)
            .where((data) => !exactMatches.contains(data))
            .toList();

        exactMatches.addAll(additional);

        if (exactMatches.length >= limit) break;
      }
    }

    final questions = exactMatches
        .take(limit)
        .map((data) => QuestionModel.createLocal(
              id: data['id'] as String,
              subject: data['subject'] as String,
              schoolLevel: data['school_level'] as String,
              difficulty: data['difficulty'] as String,
              enunciado: data['enunciado'] as String,
              alternativas: List<String>.from(data['alternativas'] as List),
              respostaCorreta: data['resposta_correta'] as int,
              explicacao: data['explicacao'] as String,
              aventuraContexto: data['aventura_contexto'] as String,
              personagemSituacao: data['personagem_situacao'] as String,
              localFloresta: data['local_floresta'] as String,
              aspectoComportamental: data['aspecto_comportamental'] as String,
              estiloAprendizado: data['estilo_aprendizado'] as String,
              imagemEspecifica: data['imagem_especifica'] as String?,
              tags: List<String>.from(data['tags'] ?? []),
              metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
            ))
        .toList();

    print('✅ ${questions.length} questões de fallback carregadas');
    return questions;
  }

  /// Determinar níveis próximos para fallback inteligente
  static List<String> _getNearbyLevels(String schoolLevel) {
    const Map<String, List<String>> nearbyMap = {
      // Ensino Fundamental
      '6ano': ['7ano', '8ano'],
      '7ano': ['6ano', '8ano', '9ano'],
      '8ano': ['7ano', '9ano', '6ano'],
      '9ano': ['8ano', '7ano', 'EM1'],

      // Ensino Médio - fallback para fundamental quando necessário
      'EM1': ['9ano', '8ano', 'EM2'],
      'EM2': ['EM1', '9ano', 'EM3', '8ano'],
      'EM3': ['EM2', 'EM1', '9ano'],
    };

    return nearbyMap[schoolLevel] ?? ['8ano', '9ano']; // Fallback padrão
  }

  /// Buscar questões por matéria - MANTIDO
  static List<QuestionModel> getQuestionsBySubject(String subject,
      {int limit = 10}) {
    return _allQuestions
        .where((data) => data['subject'] == subject)
        .take(limit)
        .map((data) => QuestionModel.createLocal(
              id: data['id'] as String,
              subject: data['subject'] as String,
              schoolLevel: data['school_level'] as String,
              difficulty: data['difficulty'] as String,
              enunciado: data['enunciado'] as String,
              alternativas: List<String>.from(data['alternativas'] as List),
              respostaCorreta: data['resposta_correta'] as int,
              explicacao: data['explicacao'] as String,
              aventuraContexto: data['aventura_contexto'] as String,
              personagemSituacao: data['personagem_situacao'] as String,
              localFloresta: data['local_floresta'] as String,
              aspectoComportamental: data['aspecto_comportamental'] as String,
              estiloAprendizado: data['estilo_aprendizado'] as String,
              imagemEspecifica: data['imagem_especifica'] as String?,
              tags: List<String>.from(data['tags'] ?? []),
              metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
            ))
        .toList();
  }

  /// Estatísticas das questões disponíveis - CORRIGIDA
  static Map<String, dynamic> getStats() {
    final stats = {
      'total': _allQuestions.length,
      'por_materia': <String, int>{},
      'por_nivel': <String, int>{},
      'por_dificuldade': <String, int>{},
      'status': 'fallback_local',
      'recomendacao': 'Conecte Firebase para mais questões',
    };

    for (final question in _allQuestions) {
      final subject = question['subject'] as String;
      final level = question['school_level'] as String;
      final difficulty = question['difficulty'] as String;

      final porMateria = stats['por_materia'] as Map<String, int>;
      final porNivel = stats['por_nivel'] as Map<String, int>;
      final porDificuldade = stats['por_dificuldade'] as Map<String, int>;

      porMateria[subject] = (porMateria[subject] ?? 0) + 1;
      porNivel[level] = (porNivel[level] ?? 0) + 1;
      porDificuldade[difficulty] = (porDificuldade[difficulty] ?? 0) + 1;
    }

    return stats;
  }

  /// Validar questões - MANTIDO
  static bool validateAllQuestions() {
    print('🔍 Validando ${_allQuestions.length} questões de fallback...');

    int valid = 0;
    int invalid = 0;

    for (final question in _allQuestions) {
      if (_validateQuestion(question)) {
        valid++;
      } else {
        invalid++;
      }
    }

    print('✅ $valid questões válidas de fallback');
    if (invalid > 0) {
      print('❌ $invalid questões inválidas');
    }

    return invalid == 0;
  }

  static bool _validateQuestion(Map<String, dynamic> question) {
    final required = [
      'id',
      'subject',
      'school_level',
      'difficulty',
      'enunciado',
      'alternativas',
      'resposta_correta',
      'aventura_contexto',
      'personagem_situacao',
      'local_floresta'
    ];

    for (final field in required) {
      if (!question.containsKey(field) || question[field] == null) {
        print(
            '❌ Questão ${question['id'] ?? 'sem ID'} inválida: campo $field ausente');
        return false;
      }
    }

    final alternativas = question['alternativas'] as List;
    final resposta = question['resposta_correta'] as int;

    if (alternativas.length != 4) {
      print('❌ Questão ${question['id']} deve ter exatamente 4 alternativas');
      return false;
    }

    if (resposta < 0 || resposta >= alternativas.length) {
      print(
          '❌ Questão ${question['id']} tem resposta_correta inválida: $resposta');
      return false;
    }

    return true;
  }

  /// Questões para teste rápido
  static List<QuestionModel> getTestQuestions({int limit = 5}) {
    return getQuestionsByLevel('8ano', limit: limit);
  }

  /// NOVO: Verificar disponibilidade por nível
  static Map<String, int> getAvailabilityByLevel() {
    final availability = <String, int>{};

    for (final question in _allQuestions) {
      final level = question['school_level'] as String;
      availability[level] = (availability[level] ?? 0) + 1;
    }

    return availability;
  }

  /// NOVO: Recomendar população de dados
  static Map<String, dynamic> getDataRecommendations() {
    final availability = getAvailabilityByLevel();
    final recommendations = <String, String>{};

    const targetLevels = ['6ano', '7ano', '8ano', '9ano', 'EM1', 'EM2', 'EM3'];

    for (final level in targetLevels) {
      final count = availability[level] ?? 0;
      if (count < 10) {
        recommendations[level] = 'Adicionar ${10 - count}+ questões';
      } else if (count < 20) {
        recommendations[level] = 'Expandir com ${20 - count} questões';
      }
    }

    return {
      'availability': availability,
      'recommendations': recommendations,
      'priority_levels': recommendations.keys.toList(),
      'total_needed': recommendations.values.length,
    };
  }

  // ===== BANCO DE QUESTÕES FALLBACK (MANTIDO) =====
  static final List<Map<String, dynamic>> _allQuestions = [
    // Questões 8ano - MATEMÁTICA
    {
      'id': 'fallback_mat_8ano_001',
      'subject': 'matematica',
      'school_level': '8ano',
      'difficulty': 'medio',
      'enunciado':
          '🧭 Atravessando a floresta, você precisa calcular a menor distância para atravessar um rio retangular de 150m × 80m. Qual é a menor distância que você deve nadar?',
      'alternativas': [
        'A) 150 metros (comprimento)',
        'B) 80 metros (largura)',
        'C) 115 metros (diagonal)',
        'D) 230 metros (perímetro)'
      ],
      'resposta_correta': 1,
      'explicacao':
          'A menor distância é sempre a largura (80m), nadando perpendicularmente às margens.',
      'aventura_contexto': 'navegacao_rio',
      'personagem_situacao': 'explorador_perdido',
      'local_floresta': 'margem_rio',
      'aspecto_comportamental': 'foco_concentracao',
      'estilo_aprendizado': 'visual',
      'imagem_especifica': null,
      'tags': ['geometria', 'area_perimetro'],
      'metadata': {'duracao_estimada': 90, 'dificuldade_numerica': 6},
    },

    // Questões 7ano - MATEMÁTICA
    {
      'id': 'fallback_mat_7ano_001',
      'subject': 'matematica',
      'school_level': '7ano',
      'difficulty': 'facil',
      'enunciado':
          '🐦 Você conta 15 tucanos em uma árvore e o dobro em outra. Quantos tucanos no total?',
      'alternativas': [
        'A) 30 tucanos',
        'B) 45 tucanos',
        'C) 25 tucanos',
        'D) 35 tucanos'
      ],
      'resposta_correta': 1,
      'explicacao': '15 + (15 × 2) = 15 + 30 = 45 tucanos no total.',
      'aventura_contexto': 'observacao_fauna',
      'personagem_situacao': 'biologa_pesquisando',
      'local_floresta': 'copa_arvores',
      'aspecto_comportamental': 'atencao_detalhes',
      'estilo_aprendizado': 'visual',
      'imagem_especifica': null,
      'tags': ['multiplicacao', 'adicao'],
      'metadata': {'duracao_estimada': 45, 'dificuldade_numerica': 3},
    },

    // Questões 9ano - BIOLOGIA
    {
      'id': 'fallback_bio_9ano_001',
      'subject': 'biologia',
      'school_level': '9ano',
      'difficulty': 'medio',
      'enunciado':
          '🌱 Uma planta da floresta faz fotossíntese. Qual gás ela absorve neste processo?',
      'alternativas': [
        'A) Oxigênio (O₂)',
        'B) Nitrogênio (N₂)',
        'C) Gás carbônico (CO₂)',
        'D) Vapor de água (H₂O)'
      ],
      'resposta_correta': 2,
      'explicacao': 'Na fotossíntese, as plantas absorvem CO₂ e liberam O₂.',
      'aventura_contexto': 'sobrevivencia',
      'personagem_situacao': 'biologa_pesquisando',
      'local_floresta': 'trilha_mata',
      'aspecto_comportamental': 'curiosidade_investigacao',
      'estilo_aprendizado': 'pratico',
      'imagem_especifica': null,
      'tags': ['fotossintese', 'plantas', 'gases'],
      'metadata': {'duracao_estimada': 60, 'dificuldade_numerica': 3},
    },

    // Questões EM2 - FÍSICA (EXPANSÃO PARA ENSINO MÉDIO)
    {
      'id': 'fallback_fis_EM2_001',
      'subject': 'fisica',
      'school_level': 'EM2',
      'difficulty': 'dificil',
      'enunciado':
          '🔊 Na floresta, o som viaja a 340 m/s. Se você ouve o eco após 3 segundos, qual a distância até o obstáculo?',
      'alternativas': [
        'A) 340 metros',
        'B) 510 metros',
        'C) 680 metros',
        'D) 1020 metros'
      ],
      'resposta_correta': 1,
      'explicacao': 'Distância = (340 × 3) ÷ 2 = 510m. O som faz ida e volta.',
      'aventura_contexto': 'navegacao_orientacao',
      'personagem_situacao': 'explorador_perdido',
      'local_floresta': 'floresta_densa',
      'aspecto_comportamental': 'raciocinio_logico',
      'estilo_aprendizado': 'pratico',
      'imagem_especifica': null,
      'tags': ['ondas_sonoras', 'velocidade', 'eco'],
      'metadata': {'duracao_estimada': 180, 'dificuldade_numerica': 7},
    },

    // Questões EM1 - GEOGRAFIA
    {
      'id': 'fallback_geo_EM1_001',
      'subject': 'geografia',
      'school_level': 'EM1',
      'difficulty': 'medio',
      'enunciado':
          '🌍 Suas coordenadas GPS mostram 3°S, 60°W. Em qual hemisfério você está?',
      'alternativas': [
        'A) Norte e Leste',
        'B) Sul e Oeste',
        'C) Norte e Oeste',
        'D) Sul e Leste'
      ],
      'resposta_correta': 1,
      'explicacao': '3°S = Hemisfério Sul, 60°W = Oeste de Greenwich.',
      'aventura_contexto': 'navegacao_orientacao',
      'personagem_situacao': 'explorador_experiente',
      'local_floresta': 'centro_floresta',
      'aspecto_comportamental': 'raciocinio_logico',
      'estilo_aprendizado': 'teorico',
      'imagem_especifica': null,
      'tags': ['coordenadas_geograficas', 'hemisferios'],
      'metadata': {'duracao_estimada': 120, 'dificuldade_numerica': 6},
    },

    // Questões 6ano - PORTUGUÊS
    {
      'id': 'fallback_port_6ano_001',
      'subject': 'portugues',
      'school_level': '6ano',
      'difficulty': 'facil',
      'enunciado':
          '📝 Na frase "Um bando de macacos brincava", a palavra "bando" é:',
      'alternativas': [
        'A) Substantivo comum',
        'B) Substantivo coletivo',
        'C) Adjetivo',
        'D) Verbo'
      ],
      'resposta_correta': 1,
      'explicacao':
          '"Bando" é substantivo coletivo - indica conjunto de animais.',
      'aventura_contexto': 'observacao_fauna',
      'personagem_situacao': 'biologa_pesquisando',
      'local_floresta': 'copa_arvores',
      'aspecto_comportamental': 'atencao_detalhes',
      'estilo_aprendizado': 'visual',
      'imagem_especifica': null,
      'tags': ['substantivos', 'coletivos'],
      'metadata': {'duracao_estimada': 70, 'dificuldade_numerica': 2},
    },

    // Questões EM3 - QUÍMICA
    {
      'id': 'fallback_qui_EM3_001',
      'subject': 'quimica',
      'school_level': 'EM3',
      'difficulty': 'dificil',
      'enunciado':
          '🧪 A água do igarapé tem pH 4,5. Isso indica maior concentração de:',
      'alternativas': [
        'A) Íons OH⁻ (hidroxila)',
        'B) Íons H⁺ (hidrogênio)',
        'C) Água neutra',
        'D) Sais minerais'
      ],
      'resposta_correta': 1,
      'explicacao':
          'pH < 7 = ácido = mais íons H⁺. Solo amazônico é naturalmente ácido.',
      'aventura_contexto': 'analise_agua',
      'personagem_situacao': 'biologa_pesquisando',
      'local_floresta': 'igarape',
      'aspecto_comportamental': 'observacao_cientifica',
      'estilo_aprendizado': 'pratico',
      'imagem_especifica': null,
      'tags': ['ph', 'acidez', 'ions'],
      'metadata': {'duracao_estimada': 150, 'dificuldade_numerica': 6},
    },

    // Questões adicionais para cobertura melhor...
    {
      'id': 'fallback_hist_8ano_001',
      'subject': 'historia',
      'school_level': '8ano',
      'difficulty': 'medio',
      'enunciado':
          '🏺 Vestígios de cerâmica encontrados na Amazônia comprovam que antes dos europeus:',
      'alternativas': [
        'A) A região era desabitada',
        'B) Existiam sociedades complexas',
        'C) Só havia grupos nômades',
        'D) A cerâmica veio dos portugueses'
      ],
      'resposta_correta': 1,
      'explicacao':
          'Sítios arqueológicos mostram civilizações amazônicas milenares.',
      'aventura_contexto': 'descoberta_arqueologica',
      'personagem_situacao': 'arqueologo_explorador',
      'local_floresta': 'sitio_arqueologico',
      'aspecto_comportamental': 'curiosidade_investigacao',
      'estilo_aprendizado': 'visual',
      'imagem_especifica': null,
      'tags': ['historia_brasil', 'povos_indigenas'],
      'metadata': {'duracao_estimada': 90, 'dificuldade_numerica': 5},
    },

    {
      'id': 'fallback_mat_9ano_001',
      'subject': 'matematica',
      'school_level': '9ano',
      'difficulty': 'medio',
      'enunciado':
          '📐 Para construir uma ponte sobre o rio, você precisa calcular a hipotenusa de um triângulo com catetos de 3m e 4m.',
      'alternativas': [
        'A) 5 metros',
        'B) 7 metros',
        'C) 12 metros',
        'D) 25 metros'
      ],
      'resposta_correta': 0,
      'explicacao': 'Teorema de Pitágoras: 3² + 4² = 9 + 16 = 25, √25 = 5m.',
      'aventura_contexto': 'construcao_ponte',
      'personagem_situacao': 'engenheiro_explorador',
      'local_floresta': 'margem_rio',
      'aspecto_comportamental': 'raciocinio_logico',
      'estilo_aprendizado': 'pratico',
      'imagem_especifica': null,
      'tags': ['teorema_pitagoras', 'geometria'],
      'metadata': {'duracao_estimada': 120, 'dificuldade_numerica': 5},
    },

    {
      'id': 'fallback_bio_EM2_001',
      'subject': 'biologia',
      'school_level': 'EM2',
      'difficulty': 'dificil',
      'enunciado':
          '🐆 A onça-pintada controla populações de herbívoros na floresta. Ela é um:',
      'alternativas': [
        'A) Produtor primário',
        'B) Consumidor primário',
        'C) Consumidor secundário/terciário',
        'D) Decompositor'
      ],
      'resposta_correta': 2,
      'explicacao':
          'A onça é predador de topo, consumindo outros carnívoros e herbívoros.',
      'aventura_contexto': 'observacao_fauna',
      'personagem_situacao': 'biologa_pesquisando',
      'local_floresta': 'trilha_mata',
      'aspecto_comportamental': 'curiosidade_investigacao',
      'estilo_aprendizado': 'visual',
      'imagem_especifica': null,
      'tags': ['cadeia_alimentar', 'ecologia'],
      'metadata': {'duracao_estimada': 90, 'dificuldade_numerica': 4},
    },
  ];
}
