import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Barre de navigation du bas : Accueil, Ventes, Analyse, Profil.
class BarreNavigation extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const BarreNavigation({super.key, required this.index, required this.onChanged});

  static const _items = [
    (Icons.home_rounded, 'Accueil'),
    (Icons.receipt_long_rounded, 'Ventes'),
    (Icons.insights_rounded, 'Analyse'),
    (Icons.person_rounded, 'Profil'),
  ];

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
                color: Color(0x1A2A55B8), blurRadius: 24, offset: Offset(0, -6)),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(
              children: [
                for (var i = 0; i < _items.length; i++)
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => onChanged(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _items[i].$1,
                              size: 25,
                              color: i == index
                                  ? Couleurs.bleu
                                  : Couleurs.texteDoux,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _items[i].$2,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: i == index
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: i == index
                                    ? Couleurs.bleu
                                    : Couleurs.texteDoux,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}
