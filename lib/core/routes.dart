import 'package:flutter/material.dart';

// ---------- Navigation entre écrans ----------

/// Ouvre un écran par-dessus l'écran actuel.
Future<T?> aller<T>(BuildContext c, Widget w) =>
    Navigator.of(c).push<T>(MaterialPageRoute<T>(builder: (_) => w));

/// Remplace l'écran actuel par un autre.
Future<void> remplacerPar(BuildContext c, Widget w) =>
    Navigator.of(c).pushReplacement(MaterialPageRoute(builder: (_) => w));

/// Revient à l'écran racine (l'accueil).
void retourAccueil(BuildContext c) =>
    Navigator.of(c).popUntil((r) => r.isFirst);

// ---------- Routes de l'API Laravel (routes/api.php) ----------
// Les webhooks (/webhooks/lightning, /webhooks/paydunya) ne figurent pas ici :
// ils sont appelés par les prestataires, jamais par l'application.

class ApiRoutes {
  // Public
  static const inscription = '/inscription';
  static const connexion = '/connexion';

  // Protégé par le jeton Sanctum
  static const moi = '/moi';
  static const deconnexion = '/deconnexion';

  // Produits (Route::apiResource)
  static const produits = '/produits';
  static String produit(int id) => '/produits/$id';

  // Ventes
  static const ventes = '/ventes';
  static String vente(int id) => '/ventes/$id';
  static String annulerVente(int id) => '/ventes/$id/annuler';

  // Paiements : une route de création par moyen de paiement
  static String paiementVente(int venteId, String methode) {
    switch (methode) {
      case 'especes':
        return '/ventes/$venteId/paiements/especes'; // existe déjà
      case 'lightning':
        return '/ventes/$venteId/paiements/lightning'; // à créer
      default: // wave, orange_money, free_money
        return '/ventes/$venteId/paiements/mobile'; // à créer
    }
  }

  static String paiement(int id) => '/paiements/$id';

  // Retraits
  static const retraits = '/retraits';

  // Conseils IA
  static const rapportIa = '/rapport-ia'; // le rapport courant (utilisé par l'app)
  static const rapportsIa = '/rapports-ia';
  static String rapportIaParId(int id) => '/rapports-ia/$id';

  // Taux de change et statistiques
  static const tauxChange = '/taux-change';
  static const tableauDeBord = '/tableau-de-bord';
}