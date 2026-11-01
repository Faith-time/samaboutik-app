import 'package:flutter/material.dart';

/// Palette SamaBoutik (bleu doux, fond clair, accents Bitcoin orange).
class Couleurs {
  static const fondHaut = Color(0xFFE8F0FF);
  static const fondBas = Color(0xFFF7FAFF);
  static const bleu = Color(0xFF2358D8);
  static const bleuMoyen = Color(0xFF1747B8);
  static const bleuFonce = Color(0xFF0B2A6F);
  static const bleuClair = Color(0xFFE4EDFD);
  static const champ = Color(0xFFF5F8FE);
  static const texte = Color(0xFF10204B);
  static const texteDoux = Color(0xFF6B7A99);
  static const bitcoin = Color(0xFFF7931A);
  static const bitcoinClair = Color(0xFFFFF1DE);
  static const succes = Color(0xFF22A55B);
  static const succesClair = Color(0xFFE2F6EA);
  static const erreur = Color(0xFFD64545);
  static const erreurClair = Color(0xFFFDE8E8);
  static const ligne = Color(0xFFDDE6F7);
}

/// Styles de texte réutilisables.
class Typo {
  static const titreEcran = TextStyle(
      fontSize: 24, fontWeight: FontWeight.w800, color: Couleurs.texte, height: 1.2);
  static const titre = TextStyle(
      fontSize: 18, fontWeight: FontWeight.w700, color: Couleurs.texte);
  static const sousTitre = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, color: Couleurs.texte);
  static const corps =
      TextStyle(fontSize: 14, color: Couleurs.texte, height: 1.45);
  static const doux =
      TextStyle(fontSize: 13, color: Couleurs.texteDoux, height: 1.45);
  static const petit = TextStyle(fontSize: 12, color: Couleurs.texteDoux);
  static const montantGeant = TextStyle(
      fontSize: 34, fontWeight: FontWeight.w800, color: Couleurs.texte);
  static const montant = TextStyle(
      fontSize: 18, fontWeight: FontWeight.w700, color: Couleurs.texte);
}

/// Ombres néomorphiques : une ombre bleutée en bas à droite et une lumière en haut à gauche.
const List<BoxShadow> ombresNeo = [
  BoxShadow(color: Color(0x1F2A55B8), blurRadius: 24, offset: Offset(8, 10)),
  BoxShadow(color: Color(0xCCFFFFFF), blurRadius: 18, offset: Offset(-6, -6)),
];

const List<BoxShadow> ombresDouces = [
  BoxShadow(color: Color(0x142A55B8), blurRadius: 14, offset: Offset(4, 6)),
  BoxShadow(color: Color(0xCCFFFFFF), blurRadius: 10, offset: Offset(-4, -4)),
];

final ThemeData themeSamaBoutik = _construireTheme();

ThemeData _construireTheme() {
  final schema = ColorScheme.fromSeed(
    seedColor: Couleurs.bleu,
    brightness: Brightness.light,
  ).copyWith(
    primary: Couleurs.bleu,
    onPrimary: Colors.white,
    secondary: Couleurs.bitcoin,
    error: Couleurs.erreur,
    surface: Colors.white,
    onSurface: Couleurs.texte,
  );

  OutlineInputBorder bordure(Color c, [double largeur = 0]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: largeur == 0
            ? BorderSide.none
            : BorderSide(color: c, width: largeur),
      );

  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    colorScheme: schema,
    scaffoldBackgroundColor: Couleurs.fondHaut,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Couleurs.champ,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: bordure(Couleurs.ligne, 1),
      enabledBorder: bordure(Couleurs.ligne, 1),
      focusedBorder: bordure(Couleurs.bleu, 1.5),
      errorBorder: bordure(Couleurs.erreur, 1.2),
      focusedErrorBorder: bordure(Couleurs.erreur, 1.5),
      labelStyle: const TextStyle(color: Couleurs.texteDoux, fontSize: 14.5),
      floatingLabelStyle: const TextStyle(color: Couleurs.bleu),
      hintStyle: const TextStyle(color: Couleurs.texteDoux),
      errorStyle: const TextStyle(color: Couleurs.erreur, fontSize: 12),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: const StadiumBorder(),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Couleurs.bleu,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Couleurs.bleuFonce,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    progressIndicatorTheme:
        const ProgressIndicatorThemeData(color: Couleurs.bleu),
    dividerTheme: const DividerThemeData(color: Couleurs.ligne, thickness: 1),
  );
}
