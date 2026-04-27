// lib/shared/widgets/math_or_text_widget.dart
// Renderiza texto simples com Text() ou LaTeX com flutter_math_fork,
// detectando automaticamente pelo delimitador $.
// Suporta textos mistos: "A área é $\frac{bh}{2}$ cm²".

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class MathOrTextWidget extends StatelessWidget {
  final String texto;
  final TextStyle? style;

  const MathOrTextWidget({
    super.key,
    required this.texto,
    this.style,
  });

  /// Detecta se o texto contém LaTeX (delimitador $ ou comandos \).
  static bool _temLatex(String texto) {
    return texto.contains(r'$') || texto.contains(r'\');
  }

  @override
  Widget build(BuildContext context) {
    if (!_temLatex(texto)) {
      return Text(texto, style: style);
    }

    // Quebra o texto em segmentos: texto normal e blocos $...$
    final segments = _parsearSegmentos(texto);

    // Garante fontSize mínimo de 16 para legibilidade dos índices LaTeX
    final mathStyle = (style?.fontSize != null && style!.fontSize! >= 16)
        ? style
        : (style ?? const TextStyle()).copyWith(fontSize: 16);

    if (segments.length == 1) {
      final seg = segments.first;
      if (seg.isMath) {
        return Math.tex(
          seg.content,
          textStyle: mathStyle,
          onErrorFallback: (_) => Text(texto, style: style),
        );
      }
      return Text(seg.content, style: style);
    }

    // Texto misto: combina Text e Math.tex em RichText via WidgetSpan
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: segments.map((seg) {
        if (seg.isMath) {
          return Math.tex(
            seg.content,
            textStyle: mathStyle,
            onErrorFallback: (_) => Text(seg.content, style: style),
          );
        }
        return Text(seg.content, style: style);
      }).toList(),
    );
  }

  /// Divide o texto em segmentos alternando entre texto normal e LaTeX ($...$).
  static List<_Segment> _parsearSegmentos(String texto) {
    final segments = <_Segment>[];
    final regex = RegExp(r'\$(.+?)\$');
    int lastEnd = 0;

    for (final match in regex.allMatches(texto)) {
      // Texto antes do $
      if (match.start > lastEnd) {
        segments.add(_Segment(texto.substring(lastEnd, match.start), false));
      }
      // Conteúdo LaTeX (sem os delimitadores $)
      segments.add(_Segment(match.group(1)!, true));
      lastEnd = match.end;
    }

    // Texto restante após o último $
    if (lastEnd < texto.length) {
      segments.add(_Segment(texto.substring(lastEnd), false));
    }

    // Se não encontrou nenhum $, retorna o texto como LaTeX puro
    // (caso o texto comece com \ mas sem delimitadores)
    if (segments.isEmpty) {
      segments.add(_Segment(texto, texto.contains(r'\')));
    }

    return segments;
  }
}

class _Segment {
  final String content;
  final bool isMath;
  const _Segment(this.content, this.isMath);
}
