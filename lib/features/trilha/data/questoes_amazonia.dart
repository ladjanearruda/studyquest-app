// lib/features/trilha/data/questoes_amazonia.dart
import '../models/questao_trilha.dart';

class QuestoesAmazonia {
  static List<QuestaoTrilha> get todasQuestoes => [
        // QUESTÃO 1 - Frações (Árvores)
        QuestaoTrilha(
          id: 0,
          enunciado:
              "🌳 Você encontra uma árvore gigante de 45 metros de altura. Uma árvore menor ao lado tem 2/3 da altura da primeira. Qual a altura da árvore menor?",
          opcoes: ["25 metros", "30 metros", "35 metros", "40 metros"],
          respostaCorreta: 1,
          explicacao: "2/3 de 45 = (2 × 45) ÷ 3 = 90 ÷ 3 = 30 metros",
        ),

        // QUESTÃO 2 - Porcentagem (Água)
        QuestaoTrilha(
          id: 1,
          enunciado:
              "💧 Seu cantil tinha 800ml de água. Você bebeu 35% durante a caminhada. Quantos ml de água restaram?",
          opcoes: ["480ml", "520ml", "280ml", "320ml"],
          respostaCorreta: 1,
          explicacao: "35% de 800 = 280ml bebidos. Restaram: 800 - 280 = 520ml",
        ),

        // QUESTÃO 3 - Geometria (Rio)
        QuestaoTrilha(
          id: 2,
          enunciado:
              "🏞️ Você precisa atravessar um rio. A margem tem formato retangular de 12m × 8m. Qual a área total da margem?",
          opcoes: ["96 m²", "40 m²", "20 m²", "48 m²"],
          respostaCorreta: 0,
          explicacao: "Área do retângulo = base × altura = 12 × 8 = 96 m²",
        ),

        // QUESTÃO 4 - Proporção (Animais)
        QuestaoTrilha(
          id: 3,
          enunciado:
              "🐒 Em cada árvore há 3 macacos. Se você encontrou 7 árvores, quantos macacos viu no total?",
          opcoes: ["18", "21", "24", "15"],
          respostaCorreta: 1,
          explicacao: "7 árvores × 3 macacos por árvore = 21 macacos",
        ),

        // QUESTÃO 5 - Equação (Tempo)
        QuestaoTrilha(
          id: 4,
          enunciado:
              "⏰ Para chegar ao acampamento, você andou 2 horas pela manhã e x horas à tarde. Total: 5 horas. Quanto tempo andou à tarde?",
          opcoes: ["2 horas", "3 horas", "4 horas", "1 hora"],
          respostaCorreta: 1,
          explicacao: "2 + x = 5, então x = 5 - 2 = 3 horas",
        ),

        // QUESTÃO 6 - Média (Temperatura)
        QuestaoTrilha(
          id: 5,
          enunciado:
              "🌡️ As temperaturas registradas foram: 28°C, 32°C, 30°C e 26°C. Qual a temperatura média?",
          opcoes: ["28°C", "29°C", "30°C", "31°C"],
          respostaCorreta: 1,
          explicacao: "Média = (28 + 32 + 30 + 26) ÷ 4 = 116 ÷ 4 = 29°C",
        ),

        // QUESTÃO 7 - Velocidade (Caminhada)
        QuestaoTrilha(
          id: 6,
          enunciado:
              "🚶‍♀️ Você caminha 4 km em 50 minutos. Mantendo esse ritmo, quantos km andará em 75 minutos?",
          opcoes: ["5 km", "6 km", "7 km", "8 km"],
          respostaCorreta: 1,
          explicacao:
              "Regra de três: 4km/50min = x/75min → x = (4 × 75) ÷ 50 = 6 km",
        ),

        // QUESTÃO 8 - Volume (Chuva)
        QuestaoTrilha(
          id: 7,
          enunciado:
              "🌧️ Choveu 15mm por hora durante 4 horas. Quantos mm de chuva caíram no total?",
          opcoes: ["45mm", "60mm", "75mm", "50mm"],
          respostaCorreta: 1,
          explicacao: "15mm/hora × 4 horas = 60mm de chuva",
        ),

        // QUESTÃO 9 - Fração (Comida)
        QuestaoTrilha(
          id: 8,
          enunciado:
              "🍎 Você tinha 24 frutas. Comeu 1/4 no café e 1/3 do restante no almoço. Quantas frutas sobraram?",
          opcoes: ["12", "14", "16", "18"],
          respostaCorreta: 0,
          explicacao:
              "Café: 24 ÷ 4 = 6 frutas. Restaram 18. Almoço: 18 ÷ 3 = 6 frutas. Sobraram: 18 - 6 = 12",
        ),

        // QUESTÃO 10 - Perímetro (Acampamento)
        QuestaoTrilha(
          id: 9,
          enunciado:
              "⛺ Seu acampamento é quadrado com lado de 8 metros. Quantos metros de corda precisa para cercá-lo?",
          opcoes: ["24m", "32m", "16m", "40m"],
          respostaCorreta: 1,
          explicacao: "Perímetro do quadrado = 4 × lado = 4 × 8 = 32 metros",
        ),

        // QUESTÃO 11 - Regra de Três (Energia)
        QuestaoTrilha(
          id: 10,
          enunciado:
              "⚡ Caminhando 5 km você gasta 20% de energia. Para 12 km, quantos % de energia gastará?",
          opcoes: ["40%", "48%", "35%", "50%"],
          respostaCorreta: 1,
          explicacao:
              "5km → 20%, então 12km → x. Regra de três: x = (12 × 20) ÷ 5 = 48%",
        ),

        // QUESTÃO 12 - Estatística (Pegadas)
        QuestaoTrilha(
          id: 11,
          enunciado:
              "🐾 Encontrou pegadas: 8 de onça, 12 de anta, 6 de macaco e 10 de capivara. Qual animal teve mais pegadas?",
          opcoes: ["Onça", "Anta", "Macaco", "Capivara"],
          respostaCorreta: 1,
          explicacao: "Comparando: 8, 12, 6, 10. O maior número é 12 (anta)",
        ),

        // QUESTÃO 13 - Álgebra (Distância)
        QuestaoTrilha(
          id: 12,
          enunciado:
              "📏 A distância total é 3x + 5 km. Se x = 4, qual a distância em km?",
          opcoes: ["15km", "17km", "20km", "12km"],
          respostaCorreta: 1,
          explicacao: "3x + 5 = 3(4) + 5 = 12 + 5 = 17 km",
        ),

        // QUESTÃO 14 - Probabilidade (Frutas)
        QuestaoTrilha(
          id: 13,
          enunciado:
              "🥭 Na mochila há 6 mangas, 4 bananas e 2 cajus. Qual a probabilidade de pegar uma manga?",
          opcoes: ["1/2", "1/3", "1/4", "2/3"],
          respostaCorreta: 0,
          explicacao:
              "Total de frutas: 6 + 4 + 2 = 12. Probabilidade = 6/12 = 1/2",
        ),

        // QUESTÃO 15 - Sequência (Árvores)
        QuestaoTrilha(
          id: 14,
          enunciado:
              "🌲 As árvores estão em sequência: 2, 5, 8, 11, ... Qual o próximo número?",
          opcoes: ["13", "14", "15", "16"],
          respostaCorreta: 1,
          explicacao:
              "A sequência aumenta +3 a cada termo: 2, 5(+3), 8(+3), 11(+3), 14",
        ),

        // QUESTÃO 16 - Área (Círculo/Lago)
        QuestaoTrilha(
          id: 15,
          enunciado:
              "🏊‍♀️ Um lago circular tem raio de 5m. Qual sua área aproximada? (π ≈ 3,14)",
          opcoes: ["78,5 m²", "31,4 m²", "15,7 m²", "62,8 m²"],
          respostaCorreta: 0,
          explicacao: "Área = π × r² = 3,14 × 5² = 3,14 × 25 = 78,5 m²",
        ),

        // QUESTÃO 17 - Conversão (Unidades)
        QuestaoTrilha(
          id: 16,
          enunciado: "📐 A trilha tem 2,5 quilômetros. Quantos metros são?",
          opcoes: ["250m", "2500m", "25000m", "25m"],
          respostaCorreta: 1,
          explicacao: "1 km = 1000m, então 2,5 km = 2,5 × 1000 = 2500 metros",
        ),

        // QUESTÃO 18 - Sistema (Equações)
        QuestaoTrilha(
          id: 17,
          enunciado:
              "🎒 2 mochilas + 1 cantil = 15 kg. 1 mochila = 6 kg. Quanto pesa o cantil?",
          opcoes: ["2 kg", "3 kg", "4 kg", "5 kg"],
          respostaCorreta: 1,
          explicacao: "2 mochilas = 2 × 6 = 12 kg. Cantil = 15 - 12 = 3 kg",
        ),

        // QUESTÃO 19 - Razão (Velocidade)
        QuestaoTrilha(
          id: 18,
          enunciado:
              "🏃‍♂️ Correndo você faz 8 km/h, caminhando 4 km/h. A razão entre correr e caminhar é:",
          opcoes: ["1:2", "2:1", "1:1", "3:1"],
          respostaCorreta: 1,
          explicacao:
              "Razão = 8:4 = 2:1 (correndo é 2 vezes mais rápido que caminhando)",
        ),

        // QUESTÃO 20 - Combinação (Final)
        QuestaoTrilha(
          id: 19,
          enunciado: "🏆 DESAFIO FINAL: 15% de 80 + 1/4 de 20 = ?",
          opcoes: ["15", "17", "19", "21"],
          respostaCorreta: 1,
          explicacao: "15% de 80 = 12; 1/4 de 20 = 5; Total = 12 + 5 = 17",
        ),
      ];

  static QuestaoTrilha? getQuestao(int id) {
    try {
      return todasQuestoes.firstWhere((q) => q.id == id);
    } catch (e) {
      return null;
    }
  }

  static int get totalQuestoes => todasQuestoes.length;
}
