import '../core/formatters.dart';
import 'vente.dart';

class TableauBord {
  final int ventesJourFcfa;
  final int ventesSemaineFcfa;
  final int nbVentesJour;
  final int panierMoyenFcfa;
  final int total30jFcfa;
  final int bitcoin30jFcfa;
  final int? bitcoin30jSats;
  final double? variationPct;
  final int? beneficeEstimeFcfa;
  final List<PointSerie> serie;
  final List<TotalMethode> parMethode;

  const TableauBord({
    this.ventesJourFcfa = 0,
    this.ventesSemaineFcfa = 0,
    this.nbVentesJour = 0,
    this.panierMoyenFcfa = 0,
    this.total30jFcfa = 0,
    this.bitcoin30jFcfa = 0,
    this.bitcoin30jSats,
    this.variationPct,
    this.beneficeEstimeFcfa,
    this.serie = const [],
    this.parMethode = const [],
  });

  factory TableauBord.fromJson(Map<String, dynamic> j) => TableauBord(
        ventesJourFcfa: versInt(j['ventes_jour_fcfa']),
        ventesSemaineFcfa: versInt(j['ventes_semaine_fcfa']),
        nbVentesJour: versInt(j['nb_ventes_jour']),
        panierMoyenFcfa: versInt(j['panier_moyen_fcfa']),
        total30jFcfa: versInt(j['total_30j_fcfa']),
        bitcoin30jFcfa: versInt(j['bitcoin_30j_fcfa']),
        bitcoin30jSats: versIntOuNul(j['bitcoin_30j_sats']),
        variationPct: versDoubleOuNul(j['variation_pct']),
        beneficeEstimeFcfa: versIntOuNul(j['benefice_estime_fcfa']),
        serie: versListe(j['serie']).map(PointSerie.fromJson).toList(),
        parMethode:
            versListe(j['par_methode']).map(TotalMethode.fromJson).toList(),
      );
}
