import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/paiement.dart';
import '../../models/vente.dart';
import '../../providers/paiement_provider.dart';
import '../ventes/recu_screen.dart';

/// Suivi d'un paiement en cours :
/// - compte à rebours chaque seconde (si le paiement expire) ;
/// - demande au serveur le statut toutes les 3 secondes ;
/// - ouvre le reçu dès que le serveur confirme le paiement.
/// Le serveur est la seule source fiable : on ne marque jamais « payé » nous-mêmes.
mixin SuiviPaiement<T extends StatefulWidget> on State<T> {
  Timer? _minuteur;
  int _ticks = 0;
  bool _fini = false;

  /// Temps restant avant expiration (null si le paiement n'expire pas).
  Duration? restant;

  Vente get venteSuivie;

  void demarrerSuivi() {
    _minuteur?.cancel();
    _fini = false;
    _ticks = 0;
    _minuteur = Timer.periodic(const Duration(seconds: 1), (_) => _tic());
  }

  void arreterSuivi() {
    _minuteur?.cancel();
    _minuteur = null;
  }

  /// À appeler après la création d'un nouveau paiement (nouveau code).
  void reinitialiserDecompte() {
    if (mounted) setState(() => restant = null);
  }

  bool paiementExpire(Paiement p) =>
      p.statut == 'expire' ||
      (p.statut == 'en_attente' && restant != null && restant!.isNegative);

  bool paiementEchoue(Paiement p) => p.statut == 'echoue';

  Future<void> _tic() async {
    if (!mounted || _fini) return;
    final provider = context.read<PaiementProvider>();
    final p = provider.paiement;
    if (p == null) return;

    _ticks++;
    if (p.expireLe != null) {
      setState(() => restant = p.expireLe!.difference(DateTime.now()));
    }

    // On interroge le serveur toutes les 3 secondes tant que le paiement est en attente.
    if (_ticks % 3 == 0 && p.statut == 'en_attente') {
      await provider.rafraichir();
      if (!mounted || _fini) return;
    }

    final maj = provider.paiement;
    if (maj != null && maj.estPaye) {
      _fini = true;
      arreterSuivi();
      allerAuRecu(context, venteSuivie.id);
    }
  }
}
