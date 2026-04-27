// lib/shared/widgets/alternativa_imagem_modal.dart
// Modal para exibir a imagem de uma alternativa em tela cheia com zoom.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AlternativaImagemModal extends StatelessWidget {
  final String imagemUrl;
  final String letra; // "A", "B", "C"...

  const AlternativaImagemModal({
    super.key,
    required this.imagemUrl,
    required this.letra,
  });

  /// Abre o modal como bottom sheet.
  static void show(BuildContext context,
      {required String imagemUrl, required String letra}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AlternativaImagemModal(imagemUrl: imagemUrl, letra: letra),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
            child: Row(
              children: [
                Text(
                  'Alternativa $letra',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Imagem com zoom
          Expanded(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CachedNetworkImage(
                  imageUrl: imagemUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (_, __, ___) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('Erro ao carregar imagem',
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Dica de zoom
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              '👆 Pinça para ampliar',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }
}
