import 'package:flutter/material.dart';

// ✅ CLASSE PARA FEEDBACK INTELIGENTE DA FLORESTA
class FeedbackInteligenteFloresta {
  static String getFeedbackTexto(bool acertou, int energiaAntes, int aguaAntes,
      int saudeAntes, int energiaDepois, int aguaDepois, int saudeDepois) {
    if (acertou) {
      // Verificar se já estava em estado ótimo
      bool jaEstavaCheio =
          energiaAntes >= 95 && aguaAntes >= 95 && saudeAntes >= 95;
      bool ficouCheio =
          energiaDepois >= 100 && aguaDepois >= 100 && saudeDepois >= 100;

      if (jaEstavaCheio) {
        return "🌟 Excelente! Recursos mantidos em estado ótimo!";
      } else if (ficouCheio) {
        return "🎯 Fantástico! Recursos totalmente restaurados!";
      } else {
        return "✅ Ótimo! Recursos vitais recuperados!";
      }
    } else {
      // Verificar gravidade da perda
      int perdaTotal = (energiaAntes - energiaDepois) +
          (aguaAntes - aguaDepois) +
          (saudeAntes - saudeDepois);

      if (perdaTotal >= 30) {
        return "⚠️ Cuidado! Perda crítica de recursos vitais!";
      } else if (perdaTotal >= 20) {
        return "⚡ Atenção! Recursos vitais reduzidos!";
      } else {
        return "💧 Ops! Pequena perda nos recursos vitais.";
      }
    }
  }

  static String getFeedbackDetalhado(
      bool acertou,
      int energiaAntes,
      int aguaAntes,
      int saudeAntes,
      int energiaDepois,
      int aguaDepois,
      int saudeDepois) {
    if (acertou) {
      bool jaEstavaCheio =
          energiaAntes >= 95 && aguaAntes >= 95 && saudeAntes >= 95;

      if (jaEstavaCheio) {
        return "Seu domínio da natureza mantém você em perfeita harmonia com a floresta!";
      } else {
        return "Seu conhecimento fortalece sua conexão com a Amazônia!";
      }
    } else {
      int perdaTotal = (energiaAntes - energiaDepois) +
          (aguaAntes - aguaDepois) +
          (saudeAntes - saudeDepois);

      if (perdaTotal >= 30) {
        return "A floresta está testando seus limites. Concentre-se!";
      } else if (perdaTotal >= 20) {
        return "A natureza cobra por cada erro. Mantenha o foco!";
      } else {
        return "Um pequeno tropeço na trilha. Continue em frente!";
      }
    }
  }

  static IconData getFeedbackIcon(
      bool acertou, int energiaAntes, int aguaAntes, int saudeAntes) {
    if (acertou) {
      bool jaEstavaCheio =
          energiaAntes >= 95 && aguaAntes >= 95 && saudeAntes >= 95;
      return jaEstavaCheio ? Icons.emoji_events : Icons.trending_up;
    } else {
      return Icons.trending_down;
    }
  }

  static Color getFeedbackColor(
      bool acertou, int energiaAntes, int aguaAntes, int saudeAntes) {
    if (acertou) {
      bool jaEstavaCheio =
          energiaAntes >= 95 && aguaAntes >= 95 && saudeAntes >= 95;
      return jaEstavaCheio ? Colors.orange.shade600 : Colors.green.shade600;
    } else {
      return Colors.red.shade600;
    }
  }

  static String getRecursosTexto(
      bool acertou, int energiaAntes, int aguaAntes, int saudeAntes) {
    if (acertou) {
      bool jaEstavaCheio =
          energiaAntes >= 95 && aguaAntes >= 95 && saudeAntes >= 95;

      if (jaEstavaCheio) {
        return "Estado mantido - Você está em harmonia perfeita!";
      } else {
        return "+5% em todos os recursos vitais";
      }
    } else {
      return "-10% em todos os recursos vitais";
    }
  }

  static List<String> getDicasEstudo(bool acertou) {
    if (acertou) {
      return [
        "💡 Continue assim! Você está dominando o conteúdo.",
        "🎯 Excelente raciocínio lógico aplicado!",
        "🌟 Seu conhecimento está crescendo rapidamente!",
        "⚡ Perfeito! Você entendeu o conceito!",
      ];
    } else {
      return [
        "📚 Revise este tópico para fortalecer sua base.",
        "🤔 Analise novamente a questão com calma.",
        "💪 Não desista! Cada erro é uma oportunidade de aprender.",
        "🎯 Foque nos fundamentos deste conceito.",
      ];
    }
  }
}
