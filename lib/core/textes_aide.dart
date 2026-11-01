/// Tous les textes d'explication de l'application (chapitre 9 du guide).
/// Un seul endroit à modifier : la durée de validité, le wolof plus tard, etc.
class TextesAide {
  static const int dureeMinutes = 5;

  // ----- Écrans de bienvenue -----
  static const bienvenue1Titre = "Gérez votre boutique en toute simplicité";
  static const bienvenue1Texte =
      "Vos clients peuvent payer en espèces, avec Wave ou Orange Money, ou avec du Bitcoin. Tout s'affiche au même endroit, en FCFA.";
  static const bienvenue2Titre = "C'est quoi le Bitcoin ?";
  static const bienvenue2Texte =
      "Le Bitcoin est une monnaie numérique. Le client la garde dans une application sur son téléphone, comme un portefeuille. Pour payer, il scanne un code avec son téléphone.";
  static const bienvenue3Titre = "Un prix qui change";
  static const bienvenue3Texte =
      "Le prix du Bitcoin change tout au long de la journée. SamaBoutik calcule donc le montant au moment de la vente et le garde $dureeMinutes minutes. Après, un nouveau code est créé avec le prix du moment.";

  // ----- Choix du moyen de paiement -----
  static const paiementEspeces = "Le client vous remet l'argent en main propre.";
  static const paiementMobile =
      "Le client paie avec son téléphone, grâce à un lien ou un code.";
  static const paiementBitcoin =
      "Le client scanne un code avec son application Bitcoin.";

  static const bulleBitcoinTitre = "Comment ça marche ?";
  static const bulleBitcoinTexte =
      "1. SamaBoutik convertit le prix en FCFA en Bitcoin.\n"
      "2. Le client scanne le code avec son application Bitcoin.\n"
      "3. Vous voyez « Paiement reçu » en général en quelques secondes.\n\n"
      "Le code est valable $dureeMinutes minutes, car le prix du Bitcoin change. "
      "Vous recevez des bitcoins, pas des FCFA. Leur valeur en FCFA peut monter ou descendre.";

  static const premierPaiementTitre = "Premier paiement Bitcoin";
  static const premierPaiementTexte =
      "Le client doit avoir une application Bitcoin sur son téléphone. Montrez-lui le code, il le scanne, et c'est payé.";

  // ----- Écran du code QR (commerçant) -----
  static const qrConsigne =
      "Scannez ce QR code avec votre portefeuille Bitcoin";
  static const qrCompteARebours =
      "Le prix du Bitcoin change, donc le montant n'est exact que pendant ce temps.";
  static const qrQuestionTitre = "C'est quoi un code QR ?";
  static const qrQuestionTexte =
      "C'est un carré que le téléphone lit avec l'appareil photo. Il contient la demande de paiement : le montant et à qui payer.";
  static const satsTitre = "C'est quoi les « sats » ?";
  static const satsTexte =
      "Les sats sont les petites unités du Bitcoin, comme les centimes pour le franc. 100 000 000 sats font 1 Bitcoin.";

  // ----- Écran « Montrer au client » -----
  static const montrerClientTitre = "Payez avec votre application Bitcoin";
  static const montrerClientEtapes = [
    "Ouvrez votre application Bitcoin.",
    "Choisissez « Scanner » et visez ce code.",
    "Vérifiez le montant affiché.",
    "Confirmez le paiement.",
  ];
  static const montrerClientNote =
      "Le prix du Bitcoin change vite, donc le montant est calculé pour ce moment précis.";

  // ----- États du paiement -----
  static const attenteTitre = "En attente du paiement...";
  static const attenteTexte =
      "Dès que le client a payé, cet écran change tout seul. Ne fermez pas l'application.";
  static const recuBitcoin =
      "Vous avez reçu des bitcoins. Leur valeur en FCFA peut changer avec le temps.";
  static const expireTitre = "Code expiré";
  static const expireTexte =
      "Le prix du Bitcoin a changé depuis trop longtemps. Pour que le montant reste juste, créez un nouveau code. Le client ne perd rien : il n'a pas payé.";
  static const echecTitre = "Le paiement n'a pas abouti";
  static const echecTexte =
      "Aucun argent n'a été pris si vous n'avez pas vu « Paiement reçu ». Vous pouvez réessayer ou choisir un autre moyen de paiement.";

  // ----- Mobile money -----
  static const mobileTitre = "Paiement par téléphone";
  static const mobileTexte =
      "Le client peut scanner ce code ou ouvrir le lien, puis payer avec son application. Un code QR est un carré que le téléphone lit avec l'appareil photo.";
  static const mobileTest = "En mode test, aucun vrai argent n'est utilisé.";

  // ----- Retrait -----
  static const retraitTitre = "Retirer en FCFA";
  static const retraitTexte =
      "Cette fonction montre comment vous pourriez retirer votre argent sur votre compte mobile money. Dans cette version de démonstration, c'est une simulation : aucun argent ne bouge.";

  // ----- Suivi -----
  static const historiqueBitcoinInfo =
      "La valeur en FCFA est calculée au prix du Bitcoin à l'heure du paiement.";
  static const tableauBordBitcoinInfo =
      "Chaque paiement Bitcoin est converti en FCFA au prix de l'heure où le client a payé. Si vous gardez vos bitcoins, leur valeur d'aujourd'hui peut être différente.";
  static const conseilsIa =
      "Ces conseils sont écrits par une intelligence artificielle, à partir de vos ventes. Ils vous aident à décider, mais c'est vous qui connaissez votre boutique.";

  // ----- Questions fréquentes -----
  static const List<List<String>> faq = [
    [
      "C'est quoi le Bitcoin ?",
      "Une monnaie numérique que l'on garde dans une application sur le téléphone. On peut l'envoyer à quelqu'un en scannant un code."
    ],
    [
      "C'est quoi Lightning ?",
      "Un système qui rend les paiements en Bitcoin rapides et peu coûteux. Vous n'avez rien à régler : SamaBoutik s'en occupe."
    ],
    [
      "C'est quoi un code QR ?",
      "Un carré que le téléphone lit avec l'appareil photo. Il contient la demande de paiement."
    ],
    [
      "C'est quoi les « sats » ?",
      "Les petites unités du Bitcoin, comme les centimes. 100 000 000 sats font 1 Bitcoin."
    ],
    [
      "Pourquoi le code expire-t-il ?",
      "Le prix du Bitcoin change vite. Après $dureeMinutes minutes, le montant ne serait plus exact."
    ],
    [
      "Le client s'est trompé de montant ?",
      "Il ne doit pas payer. Annulez et créez un nouveau code."
    ],
    [
      "Est-ce de l'argent réel ?",
      "Oui, mais sa valeur varie. Gardez seulement ce que vous acceptez de voir monter ou descendre."
    ],
    [
      "Je reçois des FCFA ou des bitcoins ?",
      "Des bitcoins. SamaBoutik vous montre leur valeur en FCFA au moment du paiement."
    ],
    [
      "Comment retirer en FCFA ?",
      "Dans cette version de démonstration, le retrait est simulé."
    ],
  ];
}
