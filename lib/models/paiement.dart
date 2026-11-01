import '../core/formatters.dart';

class Paiement {
  final int id;
  final int venteId;
  final String methode; // especes | lightning | wave | orange_money | free_money
  final int montantFcfa;
  final int? montantSats;
  final double? tauxBtcFcfa;
  final String statut; // en_attente | paye | expire | echoue
  final DateTime? expireLe;
  final DateTime? payeLe;
  final String? factureLightning;
  final String? lienPaiement;

  const Paiement({
    required this.id,
    required this.venteId,
    required this.methode,
    required this.montantFcfa,
    this.montantSats,
    this.tauxBtcFcfa,
    required this.statut,
    this.expireLe,
    this.payeLe,
    this.factureLightning,
    this.lienPaiement,
  });

  bool get estPaye => statut == 'paye';
  bool get estLightning => methode == 'lightning';
  bool get estMobile =>
      methode == 'wave' || methode == 'orange_money' || methode == 'free_money';

  factory Paiement.fromJson(Map<String, dynamic> j) => Paiement(
        id: versInt(j['id']),
        venteId: versInt(j['vente_id']),
        methode: j['methode']?.toString() ?? '',
        montantFcfa: versInt(j['montant_fcfa']),
        montantSats: versIntOuNul(j['montant_sats']),
        tauxBtcFcfa: versDoubleOuNul(j['taux_btc_fcfa']),
        statut: j['statut']?.toString() ?? 'en_attente',
        expireLe: versDate(j['expire_le']),
        payeLe: versDate(j['paye_le']),
        factureLightning: j['facture_lightning']?.toString(),
    lienPaiement: (j['url_paiement'] ?? j['lien_paiement'])?.toString(),      );

  /// Quand le serveur renvoie une réponse partielle (simple statut),
  /// on garde les informations déjà connues (facture, lien, sats...).
  Paiement completeAvec(Paiement a) => Paiement(
        id: id,
        venteId: venteId == 0 ? a.venteId : venteId,
        methode: methode.isEmpty ? a.methode : methode,
        montantFcfa: montantFcfa == 0 ? a.montantFcfa : montantFcfa,
        montantSats: montantSats ?? a.montantSats,
        tauxBtcFcfa: tauxBtcFcfa ?? a.tauxBtcFcfa,
        statut: statut,
        expireLe: expireLe ?? a.expireLe,
        payeLe: payeLe ?? a.payeLe,
        factureLightning: factureLightning ?? a.factureLightning,
        lienPaiement: lienPaiement ?? a.lienPaiement,
      );
}
