import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';

/// Champ de texte arrondi, avec icône et œil pour les mots de passe.
class ChampTexte extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool motDePasse;
  final TextInputType? clavier;
  final String? Function(String?)? validator;
  final IconData? icone;
  final int lignes;
  final String? suffixe;
  final ValueChanged<String>? onChanged;
  final bool actif;
  final TextInputAction? action;
  final List<TextInputFormatter>? formatteurs;

  const ChampTexte({
    super.key,
    required this.controller,
    required this.label,
    this.motDePasse = false,
    this.clavier,
    this.validator,
    this.icone,
    this.lignes = 1,
    this.suffixe,
    this.onChanged,
    this.actif = true,
    this.action,
    this.formatteurs,
  });

  @override
  State<ChampTexte> createState() => _ChampTexteState();
}

class _ChampTexteState extends State<ChampTexte> {
  bool _cache = true;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: widget.controller,
        obscureText: widget.motDePasse && _cache,
        keyboardType: widget.clavier,
        validator: widget.validator,
        maxLines: widget.motDePasse ? 1 : widget.lignes,
        onChanged: widget.onChanged,
        enabled: widget.actif,
        textInputAction: widget.action,
        inputFormatters: widget.formatteurs,
        style: Typo.corps.copyWith(fontSize: 15),
        decoration: InputDecoration(
          labelText: widget.label,
          suffixText: widget.suffixe,
          prefixIcon: widget.icone == null
              ? null
              : Icon(widget.icone, color: Couleurs.texteDoux, size: 20),
          suffixIcon: widget.motDePasse
              ? IconButton(
                  icon: Icon(
                    _cache
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Couleurs.texteDoux,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _cache = !_cache),
                )
              : null,
        ),
      );
}
