import '../core/formatters.dart';

class LigneVente {
  final int? produitId;
  final String nomProduit;
  final int prixUnitaireFcfa;
  final int quantite;

  const LigneVente({
    this.produitId,
    required this.nomProduit,
    required this.prixUnitaireFcfa,
    required this.quantite,
  });

  int get sousTotal => prixUnitaireFcfa * quantite;

  factory LigneVente.fromJson(Map<String, dynamic> j) => LigneVente(
        produitId: versIntOuNul(j['produit_id']),
        nomProduit: j['nom_produit']?.toString() ?? '',
        prixUnitaireFcfa: versInt(j['prix_unitaire_fcfa']),
        quantite: versInt(j['quantite']),
      );
}
