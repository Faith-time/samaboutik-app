import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Onglets en pilule (ex. « 7 jours · 30 jours · 3 mois »).
class OngletsPilule extends StatelessWidget {
  final List<String> libelles;
  final int index;
  final ValueChanged<int> onChanged;

  const OngletsPilule({
    super.key,
    required this.libelles,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Couleurs.bleuClair,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          children: [
            for (var i = 0; i < libelles.length; i++)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == index ? Couleurs.bleu : Colors.transparent,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Text(
                      libelles[i],
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: i == index ? Colors.white : Couleurs.texteDoux,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}
