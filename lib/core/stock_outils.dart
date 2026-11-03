import 'package:flutter/material.dart';
import 'theme.dart';

// Textes et couleurs liés au stock

String libelleStatutStock(String s) {
  switch (s) {
    case 'ok':
      return 'En stock';
    case 'bas':
      return 'Stock bas';
    case 'epuise':
      return 'Épuisé';
    default:
      return 'Non suivi';
  }
}

Color couleurStatutStock(String s) {
  switch (s) {
    case 'ok':
      return Couleurs.succes;
    case 'bas':
      return Couleurs.bitcoin;
    case 'epuise':
      return Couleurs.erreur;
    default:
      return Couleurs.texteDoux;
  }
}

Color fondStatutStock(String s) {
  switch (s) {
    case 'ok':
      return Couleurs.succesClair;
    case 'bas':
      return Couleurs.bitcoinClair;
    case 'epuise':
      return Couleurs.erreurClair;
    default:
      return Couleurs.champ;
  }
}

String texteUnites(int n) => '$n unité${n > 1 ? 's' : ''}';

String texteLots(double lots) {
  final t = lots == lots.roundToDouble()
      ? lots.toStringAsFixed(0)
      : lots.toStringAsFixed(1).replaceAll('.', ',');
  return '$t paquet${lots > 1 ? 's' : ''}';
}

String texteJours(int jours) =>
    jours <= 0 ? "moins d'un jour" : '$jours jour${jours > 1 ? 's' : ''}';
