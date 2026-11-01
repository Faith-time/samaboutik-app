import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Bandeau d'erreur doux, avec bouton « Réessayer » facultatif.
class MessageErreur extends StatelessWidget {
  final String message;
  final VoidCallback? onReessayer;

  const MessageErreur({super.key, required this.message, this.onReessayer});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Couleurs.erreurClair,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Couleurs.erreur),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message,
                  style: Typo.corps.copyWith(color: Couleurs.erreur)),
            ),
            if (onReessayer != null)
              TextButton(
                onPressed: onReessayer,
                child: const Text('Réessayer'),
              ),
          ],
        ),
      );
}
