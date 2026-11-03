import '../core/formatters.dart';

bool _bool(dynamic v) => v == true || v == 1 || v == '1';

/// Un produit avec son état de stock (réponse de GET /stock).
class StockProduit {
  final int produitId;
  final String nom;
  final bool actif;
  final int prixFcfa;
  final double? coutMoyenFcfa;
  final bool suivreStock;
  final int stockActuel;
  final int unitesParLot;
  final double? lotsRestants;
  final int? seuilAlerte;
  final int seuilEffectif;
  final String statutStock; // non_suivi | ok | bas | epuise
  final int vendus30j;
  final int? joursRestants;
  final int valeurStockFcfa;

  const StockProduit({
    required this.produitId,
    required this.nom,
    required this.actif,
    required this.prixFcfa,
    this.coutMoyenFcfa,
    required this.suivreStock,
    required this.stockActuel,
    required this.unitesParLot,
    this.lotsRestants,
    this.seuilAlerte,
    required this.seuilEffectif,
    required this.statutStock,
    required this.vendus30j,
    this.joursRestants,
    required this.valeurStockFcfa,
  });

  bool get epuise => statutStock == 'epuise';
  bool get bas => statutStock == 'bas';
  bool get alerte => suivreStock && (epuise || bas);

  factory StockProduit.fromJson(Map<String, dynamic> j) => StockProduit(
        produitId: versInt(j['produit_id']),
        nom: j['nom']?.toString() ?? '',
        actif: _bool(j['actif']),
        prixFcfa: versInt(j['prix_fcfa']),
        coutMoyenFcfa: versDoubleOuNul(j['cout_moyen_fcfa']),
        suivreStock: _bool(j['suivre_stock']),
        stockActuel: versInt(j['stock_actuel']),
        unitesParLot: versInt(j['unites_par_lot']) < 1 ? 1 : versInt(j['unites_par_lot']),
        lotsRestants: versDoubleOuNul(j['lots_restants']),
        seuilAlerte: versIntOuNul(j['seuil_alerte']),
        seuilEffectif: versInt(j['seuil_effectif']),
        statutStock: j['statut_stock']?.toString() ?? 'non_suivi',
        vendus30j: versInt(j['vendus_30j']),
        joursRestants: versIntOuNul(j['jours_restants']),
        valeurStockFcfa: versInt(j['valeur_stock_fcfa']),
      );
}

class ResumeStock {
  final int valeurStockFcfa;
  final int depenses30jFcfa;
  final int ca30jFcfa;
  final int benefice30jFcfa;
  final int lignesSansCout;
  final int nbBas;
  final int nbEpuises;

  const ResumeStock({
    required this.valeurStockFcfa,
    required this.depenses30jFcfa,
    required this.ca30jFcfa,
    required this.benefice30jFcfa,
    required this.lignesSansCout,
    required this.nbBas,
    required this.nbEpuises,
  });

  factory ResumeStock.fromJson(Map<String, dynamic> j) => ResumeStock(
        valeurStockFcfa: versInt(j['valeur_stock_fcfa']),
        depenses30jFcfa: versInt(j['depenses_30j_fcfa']),
        ca30jFcfa: versInt(j['ca_30j_fcfa']),
        benefice30jFcfa: versInt(j['benefice_30j_fcfa']),
        lignesSansCout: versInt(j['lignes_sans_cout']),
        nbBas: versInt(j['nb_bas']),
        nbEpuises: versInt(j['nb_epuises']),
      );
}

class StockDonnees {
  final ResumeStock resume;
  final List<StockProduit> produits;
  const StockDonnees({required this.resume, required this.produits});

  factory StockDonnees.fromJson(Map<String, dynamic> j) => StockDonnees(
        resume: ResumeStock.fromJson(Map<String, dynamic>.from(j['resume'] as Map)),
        produits: versListe(j['produits']).map(StockProduit.fromJson).toList(),
      );
}

/// Une ligne du classement (GET /classement).
class LigneClassement {
  final int rang;
  final int produitId;
  final String nom;
  final int quantite;
  final int caFcfa;
  final int? beneficeFcfa; // null = prix d'achat inconnu
  final double partPct;
  final bool suivreStock;
  final int stockActuel;
  final double? lotsRestants;
  final String statutStock;
  final double? niveauStock; // 0 à 1

  const LigneClassement({
    required this.rang,
    required this.produitId,
    required this.nom,
    required this.quantite,
    required this.caFcfa,
    this.beneficeFcfa,
    required this.partPct,
    required this.suivreStock,
    required this.stockActuel,
    this.lotsRestants,
    required this.statutStock,
    this.niveauStock,
  });

  factory LigneClassement.fromJson(Map<String, dynamic> j) => LigneClassement(
        rang: versInt(j['rang']),
        produitId: versInt(j['produit_id']),
        nom: j['nom']?.toString() ?? '',
        quantite: versInt(j['quantite']),
        caFcfa: versInt(j['ca_fcfa']),
        beneficeFcfa: versIntOuNul(j['benefice_fcfa']),
        partPct: versDoubleOuNul(j['part_pct']) ?? 0,
        suivreStock: _bool(j['suivre_stock']),
        stockActuel: versInt(j['stock_actuel']),
        lotsRestants: versDoubleOuNul(j['lots_restants']),
        statutStock: j['statut_stock']?.toString() ?? 'non_suivi',
        niveauStock: versDoubleOuNul(j['niveau_stock']),
      );
}

class Classement {
  final String periode;
  final String tri;
  final int totalQuantite;
  final int totalCaFcfa;
  final int totalBeneficeFcfa;
  final List<LigneClassement> lignes;

  const Classement({
    required this.periode,
    required this.tri,
    required this.totalQuantite,
    required this.totalCaFcfa,
    required this.totalBeneficeFcfa,
    required this.lignes,
  });

  factory Classement.fromJson(Map<String, dynamic> j) => Classement(
        periode: j['periode']?.toString() ?? 'semaine',
        tri: j['tri']?.toString() ?? 'quantite',
        totalQuantite: versInt(j['total_quantite']),
        totalCaFcfa: versInt(j['total_ca_fcfa']),
        totalBeneficeFcfa: versInt(j['total_benefice_fcfa']),
        lignes: versListe(j['produits']).map(LigneClassement.fromJson).toList(),
      );
}

/// Achat chez le fournisseur.
class LigneAppro {
  final String nomProduit;
  final int nbLots;
  final int unitesParLot;
  final int prixLotFcfa;
  final double coutUnitaireFcfa;

  const LigneAppro({
    required this.nomProduit,
    required this.nbLots,
    required this.unitesParLot,
    required this.prixLotFcfa,
    required this.coutUnitaireFcfa,
  });

  int get unites => nbLots * unitesParLot;

  factory LigneAppro.fromJson(Map<String, dynamic> j) => LigneAppro(
        nomProduit: j['nom_produit']?.toString() ?? '',
        nbLots: versInt(j['nb_lots']),
        unitesParLot: versInt(j['unites_par_lot']),
        prixLotFcfa: versInt(j['prix_lot_fcfa']),
        coutUnitaireFcfa: versDoubleOuNul(j['cout_unitaire_fcfa']) ?? 0,
      );
}

class Approvisionnement {
  final int id;
  final String? fournisseur;
  final int depenseFcfa;
  final DateTime? creeLe;
  final List<LigneAppro> lignes;

  const Approvisionnement({
    required this.id,
    this.fournisseur,
    required this.depenseFcfa,
    this.creeLe,
    this.lignes = const [],
  });

  factory Approvisionnement.fromJson(Map<String, dynamic> j) => Approvisionnement(
        id: versInt(j['id']),
        fournisseur: j['fournisseur']?.toString(),
        depenseFcfa: versInt(j['depense_fcfa']),
        creeLe: versDate(j['cree_le']),
        lignes: versListe(j['lignes']).map(LigneAppro.fromJson).toList(),
      );
}
