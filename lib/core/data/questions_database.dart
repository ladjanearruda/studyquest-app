// lib/core/data/questions_database.dart
// Banco de questões locais para Sprint 6 MVP - CORRIGIDO

import '../models/question_model.dart';

class QuestionsDatabase {
  /// Buscar questões por filtros (MVP local)
  static List<QuestionModel> getQuestionsByLevel(String schoolLevel,
      {int limit = 20}) {
    return _allQuestions
        .where((q) => q['school_level'] == schoolLevel)
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
              imagemEspecifica: data['imagem_especifica'] as String?,
              tags: List<String>.from(data['tags'] ?? []),
              metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
            ))
        .toList();
  }

  /// Buscar questões por matéria
  static List<QuestionModel> getQuestionsBySubject(String subject,
      {int limit = 10}) {
    return _allQuestions
        .where((q) => q['subject'] == subject)
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
              imagemEspecifica: data['imagem_especifica'] as String?,
              tags: List<String>.from(data['tags'] ?? []),
              metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
            ))
        .toList();
  }

  /// Estatísticas das questões disponíveis
  static Map<String, dynamic> getStats() {
    final stats = {
      'total': _allQuestions.length,
      'por_materia': <String, int>{},
      'por_nivel': <String, int>{},
      'por_dificuldade': <String, int>{},
    };

    for (final question in _allQuestions) {
      final subject = question['subject'] as String;
      final level = question['school_level'] as String;
      final difficulty = question['difficulty'] as String;

      stats['por_materia'][subject] = (stats['por_materia'][subject] ?? 0) + 1;
      stats['por_nivel'][level] = (stats['por_nivel'][level] ?? 0) + 1;
      stats['por_dificuldade'][difficulty] =
          (stats['por_dificuldade'][difficulty] ?? 0) + 1;
    }

    return stats;
  }

  // Base de questões contextualizadas tema Floresta Amazônica
  static final List<Map<String, dynamic>> _allQuestions = [
    // ===== MATEMÁTICA =====
    {
      'id': 'mat_fundamental9_001',
      'subject': 'matematica',
      'school_level': 'fundamental9',
      'difficulty': 'medio',
      'enunciado':
          'Uma área de floresta amazônica foi desmatada em formato retangular, medindo 150 metros de comprimento por 80 metros de largura. Qual é a área total desmatada em hectares? (1 hectare = 10.000 m²)',
      'alternativas': [
        '1,2 hectares',
        '1,5 hectares',
        '2,3 hectares',
        '3,0 hectares'
      ],
      'resposta_correta': 0,
      'explicacao':
          'Área = 150m × 80m = 12.000 m². Convertendo: 12.000 ÷ 10.000 = 1,2 hectares.',
      'imagem_especifica': null,
      'tags': ['area', 'retangulo', 'conversao_unidades'],
      'metadata': {'tempo_estimado': 120},
    },

    {
      'id': 'mat_fundamental8_002',
      'subject': 'matematica',
      'school_level': 'fundamental8',
      'difficulty': 'facil',
      'enunciado':
          'A Amazônia abriga cerca de 10% de todas as espécies conhecidas do planeta. Se existem aproximadamente 1,2 milhão de espécies catalogadas, quantas espécies vivem na Amazônia?',
      'alternativas': ['100.000', '120.000', '150.000', '200.000'],
      'resposta_correta': 1,
      'explicacao': '10% de 1.200.000 = 0,10 × 1.200.000 = 120.000 espécies.',
      'imagem_especifica': null,
      'tags': ['porcentagem', 'multiplicacao'],
      'metadata': {'tempo_estimado': 90},
    },

    {
      'id': 'mat_medio1_003',
      'subject': 'matematica',
      'school_level': 'medio1',
      'difficulty': 'dificil',
      'enunciado':
          'O crescimento de uma árvore da Amazônia pode ser modelado pela função h(t) = 2t + 0,5, onde h é a altura em metros e t é o tempo em anos. Após quantos anos a árvore terá 12,5 metros?',
      'alternativas': ['5 anos', '6 anos', '7 anos', '8 anos'],
      'resposta_correta': 1,
      'explicacao': '12,5 = 2t + 0,5 → 12 = 2t → t = 6 anos.',
      'imagem_especifica': null,
      'tags': ['funcao_linear', 'equacao'],
      'metadata': {'tempo_estimado': 180},
    },

    // ===== PORTUGUÊS =====
    {
      'id': 'port_fundamental9_004',
      'subject': 'portugues',
      'school_level': 'fundamental9',
      'difficulty': 'medio',
      'enunciado':
          'No trecho: "O Curupira, protetor da floresta, tinha os pés virados para trás para confundir os caçadores." A principal função do Curupira na narrativa é:',
      'alternativas': [
        'Assustar as crianças',
        'Proteger a biodiversidade',
        'Ensinar sobre direções',
        'Contar histórias antigas'
      ],
      'resposta_correta': 1,
      'explicacao':
          'O texto deixa claro que o Curupira protege os animais da caça predatória, sendo um guardião da biodiversidade.',
      'imagem_especifica': null,
      'tags': ['interpretacao_textual', 'folclore'],
      'metadata': {'tempo_estimado': 180},
    },

    {
      'id': 'port_fundamental7_005',
      'subject': 'portugues',
      'school_level': 'fundamental7',
      'difficulty': 'facil',
      'enunciado':
          'Na frase "Um bando de macacos-prego brincava entre as árvores da floresta", a palavra "bando" é um substantivo coletivo que se refere a:',
      'alternativas': [
        'Conjunto de árvores',
        'Grupo de animais',
        'Tipo de macaco',
        'Parte da floresta'
      ],
      'resposta_correta': 1,
      'explicacao':
          '"Bando" é um substantivo coletivo que indica um grupo ou conjunto de animais.',
      'imagem_especifica': null,
      'tags': ['substantivos', 'coletivos'],
      'metadata': {'tempo_estimado': 90},
    },

    {
      'id': 'port_medio2_006',
      'subject': 'portugues',
      'school_level': 'medio2',
      'difficulty': 'medio',
      'enunciado':
          'No verso "A floresta é o pulmão do mundo", temos uma figura de linguagem chamada:',
      'alternativas': ['Hipérbole', 'Metáfora', 'Metonímia', 'Personificação'],
      'resposta_correta': 1,
      'explicacao':
          'A metáfora compara a floresta com um pulmão, estabelecendo uma comparação implícita baseada na função de purificar o ar.',
      'imagem_especifica': null,
      'tags': ['figuras_linguagem', 'metafora'],
      'metadata': {'tempo_estimado': 150},
    },

    // ===== FÍSICA =====
    {
      'id': 'fis_fundamental9_007',
      'subject': 'fisica',
      'school_level': 'fundamental9',
      'difficulty': 'dificil',
      'enunciado':
          'Na floresta, o som viaja aproximadamente 340 m/s. Se você ouvir o eco de um grito após 3 segundos, qual a distância aproximada até a árvore que refletiu o som?',
      'alternativas': [
        '340 metros',
        '510 metros',
        '680 metros',
        '1.020 metros'
      ],
      'resposta_correta': 1,
      'explicacao':
          'O som percorre a distância ida e volta em 3s. Logo: d = (340 × 3) ÷ 2 = 510 metros.',
      'imagem_especifica': null,
      'tags': ['ondas_sonoras', 'velocidade', 'eco'],
      'metadata': {'tempo_estimado': 180},
    },

    {
      'id': 'fis_medio2_008',
      'subject': 'fisica',
      'school_level': 'medio2',
      'difficulty': 'dificil',
      'enunciado':
          'A radiação solar que atinge o dossel da floresta amazônica é de aproximadamente 1000 W/m². Se apenas 2% dessa energia é convertida em energia química pelas plantas via fotossíntese, qual a potência convertida por metro quadrado?',
      'alternativas': ['10 W/m²', '20 W/m²', '50 W/m²', '100 W/m²'],
      'resposta_correta': 1,
      'explicacao': '2% de 1000 W/m² = 0,02 × 1000 = 20 W/m².',
      'imagem_especifica': null,
      'tags': ['energia', 'potencia', 'fotossintese'],
      'metadata': {'tempo_estimado': 180},
    },

    // ===== QUÍMICA =====
    {
      'id': 'qui_fundamental9_009',
      'subject': 'quimica',
      'school_level': 'fundamental9',
      'difficulty': 'medio',
      'enunciado':
          'O solo da floresta amazônica tem pH entre 4,0 e 5,5, sendo considerado ácido. Isso significa que há maior concentração de:',
      'alternativas': [
        'Íons OH⁻ (hidroxila)',
        'Íons H⁺ (hidrogênio)',
        'Água neutra',
        'Sais minerais'
      ],
      'resposta_correta': 1,
      'explicacao':
          'pH abaixo de 7 indica meio ácido, caracterizado pela maior concentração de íons H⁺.',
      'imagem_especifica': null,
      'tags': ['ph', 'acidez', 'ions'],
      'metadata': {'tempo_estimado': 150},
    },

    {
      'id': 'qui_fundamental6_010',
      'subject': 'quimica',
      'school_level': 'fundamental6',
      'difficulty': 'facil',
      'enunciado':
          'Na floresta amazônica, a água dos rios pode evaporar e formar nuvens. Esse processo de mudança do estado líquido para gasoso é chamado de:',
      'alternativas': [
        'Condensação',
        'Solidificação',
        'Evaporação',
        'Sublimação'
      ],
      'resposta_correta': 2,
      'explicacao':
          'Evaporação é a passagem da água do estado líquido para o gasoso.',
      'imagem_especifica': null,
      'tags': ['estados_fisicos', 'agua'],
      'metadata': {'tempo_estimado': 80},
    },

    // ===== BIOLOGIA =====
    {
      'id': 'bio_fundamental9_011',
      'subject': 'biologia',
      'school_level': 'fundamental9',
      'difficulty': 'medio',
      'enunciado':
          'Na cadeia alimentar amazônica: Frutos → Macaco → Onça-pintada → Decompositores. O macaco representa qual nível trófico?',
      'alternativas': [
        'Produtor',
        'Consumidor primário',
        'Consumidor secundário',
        'Decompositor'
      ],
      'resposta_correta': 1,
      'explicacao':
          'O macaco se alimenta diretamente dos frutos (produtores), sendo um consumidor primário ou herbívoro.',
      'imagem_especifica': null,
      'tags': ['cadeia_alimentar', 'niveis_troficos'],
      'metadata': {'tempo_estimado': 120},
    },

    {
      'id': 'bio_fundamental6_012',
      'subject': 'biologia',
      'school_level': 'fundamental6',
      'difficulty': 'facil',
      'enunciado':
          'A parte da árvore responsável por transportar água e nutrientes das raízes até as folhas é:',
      'alternativas': ['Casca', 'Xilema', 'Floema', 'Câmbio'],
      'resposta_correta': 1,
      'explicacao':
          'O xilema é o tecido vegetal que transporta água e sais minerais das raízes para as folhas.',
      'imagem_especifica': null,
      'tags': ['anatomia_vegetal', 'transporte'],
      'metadata': {'tempo_estimado': 100},
    },

    // ===== HISTÓRIA =====
    {
      'id': 'his_fundamental9_013',
      'subject': 'historia',
      'school_level': 'fundamental9',
      'difficulty': 'medio',
      'enunciado':
          'Durante o Ciclo da Borracha (1879-1912), a Amazônia viveu um período de grande prosperidade econômica. A principal cidade que se beneficiou foi:',
      'alternativas': ['Belém', 'Manaus', 'Porto Velho', 'Rio Branco'],
      'resposta_correta': 1,
      'explicacao':
          'Manaus se tornou uma das cidades mais ricas do Brasil durante o Ciclo da Borracha, chegando a ter luz elétrica antes do Rio de Janeiro.',
      'imagem_especifica': null,
      'tags': ['ciclo_borracha', 'amazonia', 'economia'],
      'metadata': {'tempo_estimado': 150},
    },

    // ===== GEOGRAFIA =====
    {
      'id': 'geo_fundamental8_014',
      'subject': 'geografia',
      'school_level': 'fundamental8',
      'difficulty': 'medio',
      'enunciado':
          'O clima predominante na Amazônia é o equatorial, caracterizado por:',
      'alternativas': [
        'Baixa umidade e grandes variações de temperatura',
        'Alta umidade e temperaturas elevadas o ano todo',
        'Estações secas e chuvosas bem definidas',
        'Temperaturas baixas e chuvas escassas'
      ],
      'resposta_correta': 1,
      'explicacao':
          'O clima equatorial apresenta alta umidade (80-90%) e temperaturas elevadas (24-26°C) com pequena variação anual.',
      'imagem_especifica': null,
      'tags': ['clima', 'equatorial'],
      'metadata': {'tempo_estimado': 120},
    },

    // ===== INGLÊS =====
    {
      'id': 'ing_fundamental9_015',
      'subject': 'ingles',
      'school_level': 'fundamental9',
      'difficulty': 'medio',
      'enunciado':
          'Complete the sentence: "The Amazon rainforest is home to many _____ species, including jaguars, sloths, and toucans."',
      'alternativas': ['endanger', 'endangered', 'endangering', 'endanagered'],
      'resposta_correta': 1,
      'explicacao':
          '"Endangered" (em perigo de extinção) é o adjetivo correto para descrever espécies ameaçadas.',
      'imagem_especifica': null,
      'tags': ['vocabulary', 'adjectives'],
      'metadata': {'tempo_estimado': 90},
    },
  ];

  /// Validar se todas as questões estão corretas
  static bool validateAllQuestions() {
    print('🔍 Validando ${_allQuestions.length} questões...');

    int valid = 0;
    int invalid = 0;

    for (final question in _allQuestions) {
      if (_validateQuestion(question)) {
        valid++;
      } else {
        invalid++;
      }
    }

    print('✅ $valid questões válidas');
    if (invalid > 0) {
      print('❌ $invalid questões inválidas');
    }

    return invalid == 0;
  }

  static bool _validateQuestion(Map<String, dynamic> question) {
    // Validar campos obrigatórios
    final required = [
      'id',
      'subject',
      'school_level',
      'difficulty',
      'enunciado',
      'alternativas',
      'resposta_correta'
    ];

    for (final field in required) {
      if (!question.containsKey(field) || question[field] == null) {
        print(
            '❌ Questão ${question['id'] ?? 'sem ID'} inválida: campo $field ausente');
        return false;
      }
    }

    // Validar alternativas
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
}
