import '../core/formatters.dart';

class Produit {
  final int id;
  final String nom;
  final int prixFcfa;
  final int? coutFcfa;
  final bool actif;
  final String? imageUrl;

  const Produit({
    required this.id,
    required this.nom,
    required this.prixFcfa,
    this.coutFcfa,
    this.actif = true,
    this.imageUrl,
  });

  factory Produit.fromJson(Map<String, dynamic> j) => Produit(
        id: versInt(j['id']),
        nom: j['nom']?.toString() ?? '',
        prixFcfa: versInt(j['prix_fcfa']),
        coutFcfa: versIntOuNul(j['cout_fcfa']),
        actif: versBool(j['actif'], defaut: true),
        imageUrl: (j['image_url'] == null || j['image_url'].toString().isEmpty)
            ? null
            : j['image_url'].toString(),
      );
}
