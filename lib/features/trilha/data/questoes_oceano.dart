import '../models/questao_trilha.dart';

class QuestoesOceano {
  static List<QuestaoTrilha> get todasQuestoes => [
        // QUESTÃO 1 - Biologia Marinha
        QuestaoTrilha(
          id: 0,
          enunciado:
              "🐋 Você avista uma baleia-jubarte migratando pelo litoral brasileiro. Em que época do ano isso normalmente acontece?",
          opcoes: [
            "Janeiro a Março",
            "Junho a Novembro",
            "Abril a Maio",
            "Dezembro apenas"
          ],
          respostaCorreta: 1,
          explicacao:
              "As baleias-jubarte migram para águas brasileiras de junho a novembro para reprodução e cuidado dos filhotes.",
        ),

        // QUESTÃO 2 - Física (Pressão)
        QuestaoTrilha(
          id: 1,
          enunciado:
              "🤿 A 30 metros de profundidade, a pressão é aproximadamente 4 atmosferas. A cada 10 metros, a pressão aumenta 1 atmosfera. Qual a pressão a 50 metros?",
          opcoes: [
            "5 atmosferas",
            "6 atmosferas",
            "7 atmosferas",
            "8 atmosferas"
          ],
          respostaCorreta: 1,
          explicacao:
              "A 50m: pressão inicial (1 atm) + 5 blocos de 10m (5 atm) = 6 atmosferas",
        ),

        // QUESTÃO 3 - Ecossistema Marinho
        QuestaoTrilha(
          id: 2,
          enunciado:
              "🐠 Nos recifes de corais brasileiros, qual é a relação entre corais e zooxantelas?",
          opcoes: ["Competição", "Simbiose", "Predação", "Parasitismo"],
          respostaCorreta: 1,
          explicacao:
              "É uma relação de simbiose: corais oferecem proteção e as zooxantelas fazem fotossíntese fornecendo energia.",
        ),

        // QUESTÃO 4 - Geografia Marinha
        QuestaoTrilha(
          id: 3,
          enunciado:
              "🌊 A Corrente do Brasil flui em qual direção ao longo da costa brasileira?",
          opcoes: [
            "Norte para Sul",
            "Sul para Norte",
            "Leste para Oeste",
            "Oeste para Leste"
          ],
          respostaCorreta: 0,
          explicacao:
              "A Corrente do Brasil flui de norte para sul, trazendo águas quentes tropicais pela costa.",
        ),

        // QUESTÃO 5 - Química Oceânica
        QuestaoTrilha(
          id: 4,
          enunciado:
              "🧪 A salinidade média dos oceanos é cerca de 35‰ (por mil). Se você tem 2 litros de água do mar, quantos gramas de sal contém?",
          opcoes: ["35 gramas", "70 gramas", "105 gramas", "140 gramas"],
          respostaCorreta: 1,
          explicacao:
              "35‰ significa 35g de sal por 1000g de água. Em 2 litros (2000g): 35 × 2 = 70 gramas",
        ),

        // QUESTÃO 6 - Biodiversidade
        QuestaoTrilha(
          id: 5,
          enunciado:
              "🐢 As tartarugas marinhas brasileiras desovam principalmente em quais praias?",
          opcoes: [
            "Praias urbanas",
            "Praias desertas e preservadas",
            "Praias rochosas",
            "Qualquer praia"
          ],
          respostaCorreta: 1,
          explicacao:
              "Tartarugas preferem praias desertas e preservadas para desovar, longe de luzes artificiais e perturbações.",
        ),

        // QUESTÃO 7 - Zona Pelágica
        QuestaoTrilha(
          id: 6,
          enunciado:
              "🦑 Na zona abissal do oceano (4000m+), qual característica é mais comum nos peixes?",
          opcoes: [
            "Cores vibrantes",
            "Bioluminescência",
            "Grandes barbatanas",
            "Escamas grossas"
          ],
          respostaCorreta: 1,
          explicacao:
              "Na zona abissal, sem luz solar, muitos peixes desenvolveram bioluminescência para comunicação e caça.",
        ),

        // QUESTÃO 8 - Ondas e Marés
        QuestaoTrilha(
          id: 7,
          enunciado:
              "🌙 As marés são causadas principalmente pela atração gravitacional de:",
          opcoes: [
            "Apenas do Sol",
            "Apenas da Lua",
            "Lua e Sol juntos",
            "Rotação da Terra"
          ],
          respostaCorreta: 2,
          explicacao:
              "Marés resultam da atração gravitacional combinada da Lua (principal) e do Sol, criando marés sizígias e quadraturas.",
        ),

        // QUESTÃO 9 - Poluição Marinha
        QuestaoTrilha(
          id: 8,
          enunciado:
              "♻️ Quanto tempo leva para uma garrafa plástica se degradar no oceano?",
          opcoes: ["10 anos", "50 anos", "100 anos", "400+ anos"],
          respostaCorreta: 3,
          explicacao:
              "Garrafas plásticas podem levar 400+ anos para se degradar, causando danos prolongados à vida marinha.",
        ),

        // QUESTÃO 10 - Cadeia Alimentar
        QuestaoTrilha(
          id: 9,
          enunciado: "🦐 Na cadeia alimentar marinha, o fitoplâncton é:",
          opcoes: [
            "Consumidor primário",
            "Produtor primário",
            "Consumidor secundário",
            "Decompositor"
          ],
          respostaCorreta: 1,
          explicacao:
              "Fitoplâncton são produtores primários, fazendo fotossíntese e servindo de base para toda cadeia alimentar.",
        ),

        // QUESTÃO 11 - Temperatura Oceânica
        QuestaoTrilha(
          id: 10,
          enunciado:
              "🌡️ A temperatura da água do mar tropical brasileiro varia tipicamente entre:",
          opcoes: ["15-20°C", "20-25°C", "25-30°C", "30-35°C"],
          respostaCorreta: 2,
          explicacao:
              "Águas tropicais brasileiras mantêm temperatura entre 25-30°C, ideal para corais e vida marinha diversa.",
        ),

        // QUESTÃO 12 - Pressão e Mergulho
        QuestaoTrilha(
          id: 11,
          enunciado:
              "⚠️ Por que mergulhadores não podem subir rapidamente das profundezas?",
          opcoes: [
            "Frio extremo",
            "Embolia gasosa",
            "Falta de oxigênio",
            "Correntes fortes"
          ],
          respostaCorreta: 1,
          explicacao:
              "Subida rápida causa embolia gasosa: nitrogênio dissolvido forma bolhas no sangue, podendo ser fatal.",
        ),

        // QUESTÃO 13 - Zona Fótica
        QuestaoTrilha(
          id: 12,
          enunciado:
              "☀️ A zona fótica do oceano (onde há luz solar) estende-se até aproximadamente:",
          opcoes: ["50 metros", "100 metros", "200 metros", "500 metros"],
          respostaCorreta: 2,
          explicacao:
              "A zona fótica estende-se até ~200m, onde ainda há luz suficiente para fotossíntese do fitoplâncton.",
        ),

        // QUESTÃO 14 - Densidade da Água
        QuestaoTrilha(
          id: 13,
          enunciado: "🧊 Por que o gelo flutua na água do mar?",
          opcoes: [
            "É mais denso",
            "É menos denso",
            "Tem ar dentro",
            "É mais salgado"
          ],
          respostaCorreta: 1,
          explicacao:
              "Gelo é menos denso que água líquida (densidade ~0.92 g/cm³ vs 1.0 g/cm³), por isso flutua.",
        ),

        // QUESTÃO 15 - Manguezais
        QuestaoTrilha(
          id: 14,
          enunciado: "🌱 Os manguezais são importantes porque:",
          opcoes: [
            "Produzem sal",
            "São berçários marinhos",
            "Filtram petróleo",
            "Produzem corais"
          ],
          respostaCorreta: 1,
          explicacao:
              "Manguezais são berçários marinhos: protegem juvenis de peixes e crustáceos, sendo vitais para reprodução.",
        ),

        // QUESTÃO 16 - Correntes Oceânicas
        QuestaoTrilha(
          id: 15,
          enunciado: "🌀 O que causa as correntes oceânicas?",
          opcoes: [
            "Apenas ventos",
            "Apenas temperatura",
            "Ventos, temperatura e rotação da Terra",
            "Apenas marés"
          ],
          respostaCorreta: 2,
          explicacao:
              "Correntes resultam da combinação de ventos, diferenças de temperatura/densidade e rotação da Terra (Coriolis).",
        ),

        // QUESTÃO 17 - Plâncton
        QuestaoTrilha(
          id: 16,
          enunciado: "🔬 Zooplâncton se alimenta principalmente de:",
          opcoes: [
            "Peixes pequenos",
            "Fitoplâncton",
            "Algas grandes",
            "Corais"
          ],
          respostaCorreta: 1,
          explicacao:
              "Zooplâncton (animais microscópicos) alimenta-se principalmente de fitoplâncton (plantas microscópicas).",
        ),

        // QUESTÃO 18 - Acidificação
        QuestaoTrilha(
          id: 17,
          enunciado: "🏭 A acidificação dos oceanos é causada por:",
          opcoes: [
            "Excesso de sal",
            "CO2 atmosférico",
            "Poluição por óleo",
            "Aquecimento solar"
          ],
          respostaCorreta: 1,
          explicacao:
              "Oceanos absorvem CO2 atmosférico, formando ácido carbônico e diminuindo o pH da água.",
        ),

        // QUESTÃO 19 - Tsunami
        QuestaoTrilha(
          id: 18,
          enunciado: "🌊 Tsunamis são causados principalmente por:",
          opcoes: [
            "Ventos fortes",
            "Marés altas",
            "Terremotos submarinos",
            "Mudanças de temperatura"
          ],
          respostaCorreta: 2,
          explicacao:
              "Tsunamis são causados por terremotos submarinos que deslocam grandes volumes de água rapidamente.",
        ),

        // QUESTÃO 20 - Conservação
        QuestaoTrilha(
          id: 19,
          enunciado:
              "🏆 DESAFIO FINAL: Qual a principal ameaça aos recifes de coral brasileiros?",
          opcoes: [
            "Predadores naturais",
            "Aquecimento e acidificação",
            "Excesso de peixes",
            "Falta de luz"
          ],
          respostaCorreta: 1,
          explicacao:
              "Aquecimento global causa branqueamento dos corais, e acidificação dificulta formação do esqueleto calcário.",
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
