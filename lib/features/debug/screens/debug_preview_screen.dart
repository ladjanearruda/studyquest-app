// lib/features/debug/screens/debug_preview_screen.dart
// Tela de debug: busca e renderiza qualquer questão do Firebase pelo ID.
// Use para validar LaTeX, imagens, alternativas com imagem, etc.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../shared/widgets/fonte_tag_widget.dart';
import '../../../shared/widgets/math_or_text_widget.dart';
import '../../../shared/widgets/questao_imagem_widget.dart';
import '../../../shared/widgets/alternativa_imagem_modal.dart';

class DebugPreviewScreen extends StatefulWidget {
  const DebugPreviewScreen({super.key});

  @override
  State<DebugPreviewScreen> createState() => _DebugPreviewScreenState();
}

class _DebugPreviewScreenState extends State<DebugPreviewScreen> {
  final _controller = TextEditingController();
  _QuestaoPreview? _questao;
  bool _loading = false;
  String? _erro;

  static const _baseUrl =
      'https://firestore.googleapis.com/v1/projects/studyquest-app-banco/databases/(default)/documents';

  Future<void> _carregar() async {
    final id = _controller.text.trim();
    if (id.isEmpty) return;

    setState(() {
      _loading = true;
      _erro = null;
      _questao = null;
    });

    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/questions/$id'));

      if (response.statusCode == 404) {
        setState(() {
          _erro = 'Questão "$id" não encontrada.';
          _loading = false;
        });
        return;
      }

      if (response.statusCode != 200) {
        setState(() {
          _erro = 'Erro HTTP ${response.statusCode}';
          _loading = false;
        });
        return;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final fields = data['fields'] as Map<String, dynamic>? ?? {};

      setState(() {
        _questao = _QuestaoPreview.fromFields(id, fields);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro: $e';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Preview de Questão'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Barra de busca
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'ID da questão (ex: enem_2024_mat_180)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    onSubmitted: (_) => _carregar(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _loading ? null : _carregar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Carregar'),
                ),
              ],
            ),
          ),

          // IDs de exemplo
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                const Text('Exemplos: ',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey)),
                ...[
                  'enem_2024_mat_180',
                  'enem_2024_fis_109',
                  'enem_2024_bio_135',
                  'enem_2024_mat_139',
                  'enem_2024_bio_122',
                ].map((id) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        label: Text(id,
                            style: const TextStyle(fontSize: 11)),
                        onPressed: () {
                          _controller.text = id;
                          _carregar();
                        },
                      ),
                    )),
              ],
            ),
          ),

          const Divider(height: 1),

          // Conteúdo
          Expanded(
            child: _buildConteudo(),
          ),
        ],
      ),
    );
  }

  Widget _buildConteudo() {
    if (_erro != null) {
      return Center(
          child: Text(_erro!,
              style: const TextStyle(color: Colors.red, fontSize: 14)));
    }

    if (_questao == null) {
      return Center(
        child: Text(
          'Digite um ID e clique em Carregar',
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
      );
    }

    final q = _questao!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metadados
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _chip(q.id, Colors.grey),
              if (q.subject.isNotEmpty) _chip(q.subject, Colors.blue),
              if (q.difficulty.isNotEmpty) _chip(q.difficulty, Colors.orange),
              if (q.schoolLevel.isNotEmpty)
                _chip(q.schoolLevel, Colors.purple),
              if (q.alternativasTipo == 'imagem')
                _chip('imagens nas alternativas', Colors.teal),
            ],
          ),
          const SizedBox(height: 14),

          // Tag de fonte
          FonteTagWidget(fonte: q.fonte),

          // Enunciado (antes da imagem)
          if (q.enunciado.isNotEmpty)
            MathOrTextWidget(
              texto: q.enunciado,
              style: const TextStyle(
                  fontSize: 15, height: 1.55, color: Colors.black87),
            ),

          // Imagem do enunciado
          if (q.imagemUrl.isNotEmpty) ...[
            const SizedBox(height: 10),
            QuestaoImagemWidget(imagemUrl: q.imagemUrl),
          ],

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // Alternativas
          // Para questões com alternativas_tipo=imagem, alternativas[] pode
          // estar vazio — usar alternativasImagens.length como fallback.
          ...() {
            final altCount = q.alternativas.isNotEmpty
                ? q.alternativas.length
                : (q.alternativasImagens?.length ?? 0);

            return List.generate(altCount, (index) {
              final texto =
                  index < q.alternativas.length ? q.alternativas[index] : '';
              final letra = String.fromCharCode(65 + index);
              final imagemUrl = q.getImagemAlternativa(index);
              final isCorreta = index == q.respostaCorreta;
              final temTexto = texto.isNotEmpty;
              final temImagem = imagemUrl != null && imagemUrl.isNotEmpty;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isCorreta ? Colors.green[50] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCorreta
                        ? Colors.green.shade400
                        : Colors.grey.shade300,
                    width: isCorreta ? 2 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: isCorreta
                          ? Colors.green.shade600
                          : Colors.grey.shade200,
                      radius: 14,
                      child: Text(letra,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isCorreta
                                  ? Colors.white
                                  : Colors.grey.shade700)),
                    ),
                    const SizedBox(width: 12),
                    // Texto expandido só quando há texto; sem texto, botão fica junto da letra
                    if (temTexto)
                      Expanded(
                        child: MathOrTextWidget(
                          texto: texto,
                          style: const TextStyle(fontSize: 14),
                        ),
                      )
                    else
                      const SizedBox(width: 8),
                    // Botão "Ver" inline com a letra
                    if (temImagem) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => AlternativaImagemModal.show(context,
                            imagemUrl: imagemUrl, letra: letra),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.image_outlined,
                                  size: 14, color: Colors.blue.shade700),
                              const SizedBox(width: 4),
                              Text('Ver',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700)),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (isCorreta) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 20),
                    ],
                  ],
                ),
              );
            });
          }(),

          const SizedBox(height: 16),

          // Explicação
          if (q.explicacao.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 8),
            const Text('Explicação',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            MathOrTextWidget(
              texto: q.explicacao,
              style:
                  TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Model interno simplificado ──────────────────────────────────────────────

class _QuestaoPreview {
  final String id;
  final String enunciado;
  final String explicacao;
  final String subject;
  final String difficulty;
  final String schoolLevel;
  final String? fonte;
  final String imagemUrl;
  final List<String> alternativas;
  final int respostaCorreta;
  final String? alternativasTipo;
  final List<String>? alternativasImagens;

  _QuestaoPreview({
    required this.id,
    required this.enunciado,
    required this.explicacao,
    required this.subject,
    required this.difficulty,
    required this.schoolLevel,
    this.fonte,
    required this.imagemUrl,
    required this.alternativas,
    required this.respostaCorreta,
    this.alternativasTipo,
    this.alternativasImagens,
  });

  String? getImagemAlternativa(int index) {
    if (alternativasTipo != 'imagem') return null;
    if (alternativasImagens == null || index >= alternativasImagens!.length) {
      return null;
    }
    return alternativasImagens![index];
  }

  factory _QuestaoPreview.fromFields(
      String id, Map<String, dynamic> fields) {
    String str(String key) =>
        fields[key]?['stringValue'] as String? ?? '';

    String strFallback(List<String> keys) {
      for (final k in keys) {
        final v = fields[k]?['stringValue'] as String?;
        if (v != null && v.isNotEmpty) return v;
      }
      return '';
    }

    List<String> arr(String key) {
      final values = fields[key]?['arrayValue']?['values'] as List? ?? [];
      return values
          .map((v) => v['stringValue'] as String? ?? '')
          .toList();
    }

    int intVal(List<String> keys) {
      for (final k in keys) {
        final f = fields[k];
        if (f != null) {
          return int.tryParse(f['integerValue']?.toString() ?? '') ?? 0;
        }
      }
      return 0;
    }

    final imagens = fields['alternativas_imagens']?['arrayValue']
                ?['values'] !=
            null
        ? (fields['alternativas_imagens']['arrayValue']['values']
                as List<dynamic>)
            .map((v) => v['stringValue'] as String? ?? '')
            .toList()
        : null;

    return _QuestaoPreview(
      id: id,
      enunciado: strFallback(['enunciado', 'question']),
      explicacao: str('explicacao'),
      subject: str('subject'),
      difficulty: str('difficulty'),
      schoolLevel: str('school_level'),
      fonte: fields['fonte']?['stringValue'] as String?,
      imagemUrl: strFallback(['imagem_url', 'imagem_especifica']),
      alternativas: arr('alternativas').isNotEmpty
          ? arr('alternativas')
          : arr('options'),
      respostaCorreta: intVal(['resposta_correta', 'correct_answer']),
      alternativasTipo: fields['alternativas_tipo']?['stringValue'] as String?,
      alternativasImagens: imagens,
    );
  }
}
