# SamaBoutik – Application mobile

SamaBoutik aide les petits commerçants du Sénégal à tenir leur boutique depuis leur téléphone : produits, stock, ventes, encaissement et chiffres de l’activité, le tout dans une seule application Android faite avec Flutter.

- Télécharger l’APK : onglet [Releases](https://github.com/Faith-time/samaboutik-app/releases)
- API utilisée par l’application : https://samaboutik.alwaysdata.net/api
- Code de l’API (Laravel) : https://github.com/Faith-time/samaboutik-api

## Ce que l’on peut faire

L’application suit le quotidien d’un commerçant, dans cet ordre :

1. **Bienvenue et connexion.** Trois écrans expliquent l’application, le Bitcoin et pourquoi son prix change. Ensuite, on se connecte avec son numéro de téléphone et son mot de passe.
2. **Accueil.** Les ventes du jour, le total des 30 derniers jours, la part payée en Bitcoin, une alerte sur les produits à racheter, le bouton « Nouvelle vente » et des raccourcis.
3. **Produits et stock.** Le catalogue avec l’état de chaque produit (en stock, stock bas, épuisé). On peut ajouter un produit avec sa photo, son prix de vente, son prix d’achat, ses unités par paquet, son stock de départ et un seuil d’alerte. L’écran « Mon stock » donne la valeur du stock, les achats du mois et ce qu’il faut réapprovisionner.
4. **Nouvelle vente.** On choisit les produits et les quantités, on voit le stock restant et le total. Un produit épuisé ne peut pas être vendu.
5. **Paiement en Bitcoin.** L’application affiche un QR code valable 5 minutes. Le client le scanne avec son portefeuille Bitcoin et l’écran passe tout seul à « Paiement réussi ».
6. **Paiement mobile money.** Wave, Orange Money ou Free Money, avec la page de paiement PayDunya ouverte dans l’application.
7. **Après la vente.** Le détail de la vente, puis l’accueil et le stock se mettent à jour automatiquement.
8. **Ventes.** L’évolution sur 7 jours, 30 jours ou 3 mois, la répartition par moyen de paiement et la liste des ventes (payée, en attente ou annulée).
9. **Classement des produits.** Un podium par jour, semaine, mois ou année, selon les produits les plus vendus, les plus rentables ou ceux qui rapportent le plus.
10. **Analyse.** La semaine comparée à la précédente, le panier moyen, le bénéfice, le meilleur jour, les produits stars et des conseils.
11. **Statistiques et finances.** Les recettes, le bénéfice estimé, la valeur du stock et les achats.
12. **Retrait en FCFA.** Un retrait simulé vers Wave, Orange Money ou Free Money.
13. **Profil et aide.** La boutique, les produits, et une petite foire aux questions pour comprendre le Bitcoin.

## Technologies

Flutter (3.41 ou plus) et Dart 3.11. Les principaux packages : `dio` pour parler à l’API, `provider` pour l’état de l’application, `flutter_secure_storage` pour garder le jeton de connexion, `qr_flutter` pour le QR code, `webview_flutter` pour la page PayDunya, `fl_chart` pour les courbes, `image_picker` et `cached_network_image` pour les photos des produits, `url_launcher` pour ouvrir le portefeuille Bitcoin, `connectivity_plus`, `share_plus`, `shared_preferences` et `intl`.

## Comment l’application parle à l’API

L’adresse de l’API est écrite à un seul endroit, dans la classe `Config` :

```dart
class Config {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://samaboutik.alwaysdata.net/api',
  );
}
```

Sans rien préciser, l’application utilise l’API en ligne. Pour travailler avec une API sur mon ordinateur :

```bash
# émulateur Android
flutter run --dart-define=BASE_URL=http://10.0.2.2:8000/api

# téléphone branché sur le même Wi-Fi
flutter run --dart-define=BASE_URL=http://<IP-du-PC>:8000/api
```

Pour fabriquer l’APK final, il ne faut surtout pas mettre d’adresse locale.

Après la connexion, l’API renvoie un jeton qui est gardé dans le stockage sécurisé du téléphone et envoyé à chaque requête.

Côté Android, le fichier `android/app/src/main/AndroidManifest.xml` doit contenir la permission Internet, sinon l’APK ne peut rien charger :

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

Il contient aussi l’autorisation d’ouvrir les liens `https`, pour lancer le portefeuille Bitcoin.

## Lancer le projet

Il faut Flutter, Android Studio ou VS Code, Git et un téléphone ou un émulateur Android.

```bash
git clone https://github.com/Faith-time/samaboutik-app.git
cd samaboutik-app
flutter pub get
flutter doctor
flutter run
```

## Fabriquer l’APK

Depuis la racine du projet :

```bash
flutter clean
flutter pub get
flutter build apk --release
```

La première fois, c’est long (Gradle télécharge beaucoup de choses) : il faut patienter. Le fichier se trouve ensuite dans `build/app/outputs/flutter-apk/app-release.apk`.

Avant de compiler, je vérifie qu’il ne reste aucune adresse locale dans le code :

```bash
grep -rn "alwaysdata\|localhost\|10.0.2.2\|192.168" lib/
```

On ne doit voir que `https://samaboutik.alwaysdata.net/api`.

L’APK est signé avec la clé de test fournie par Flutter. C’est suffisant pour l’installer et l’essayer, mais pas pour le Play Store. Pour que les mises à jour s’installent par-dessus, je compile toujours depuis le même ordinateur.

## Publier l’APK sur GitHub

GitHub ne compile rien : il sert seulement à héberger le fichier et à donner un lien de téléchargement.

1. Renommer `app-release.apk` en `SamaBoutik.apk`.
2. Sur GitHub, ouvrir le dépôt, puis **Releases → Create a new release**.
3. Créer le tag `v1.0.0` et mettre le titre `SamaBoutik v1.0.0`.
4. Glisser `SamaBoutik.apk` dans la zone des fichiers, puis cliquer sur **Publish release**.

Le lien direct ressemble à ceci :

```
https://github.com/Faith-time/samaboutik-app/releases/download/v1.0.0/SamaBoutik.apk
```

## Installer l’application (jury, testeurs)

1. Sur un téléphone **Android**, ouvrir le lien de l’APK et le télécharger.
2. Si Android le demande, autoriser l’installation depuis cette source.
3. Google Play Protect peut afficher un avertissement, parce que l’application ne vient pas du Play Store. Choisir d’installer quand même.
4. Ouvrir SamaBoutik, se connecter ou créer un compte. Une connexion Internet est nécessaire.

Si une ancienne version est déjà installée, la désinstaller d’abord : les signatures peuvent être différentes.

## Mettre à jour

- **Si je change l’API** : un `git pull` sur le serveur suffit, les téléphones en profitent tout de suite.
- **Si je change l’application** : il faut recompiler un APK et le republier, car il n’y a pas de mise à jour automatique. Dans `pubspec.yaml`, j’augmente la version (par exemple `1.0.1+2`, le chiffre après le `+` doit toujours grandir), je refais `flutter clean && flutter pub get && flutter build apk --release`, puis je crée une nouvelle Release. Avec un téléphone branché en USB, `flutter install --release` marche aussi.

## Si quelque chose ne va pas

- **Pas de réseau dans l’APK alors que tout marche en développement** : il manque la permission `INTERNET` dans le manifeste. Il faut l’ajouter puis recompiler.
- **L’application appelle une adresse locale** : vérifier avec la commande `grep` plus haut et recompiler sans `--dart-define`.
- **L’APK ne s’installe pas par-dessus l’ancien** : désinstaller l’ancien d’abord.
- **Le build reste longtemps sur `Running Gradle task 'assembleRelease'`** : c’est normal la première fois.
- **Les photos des produits ne s’affichent pas** : les images ne sont pas sur le serveur. Voir le README de l’API, il faut lancer `php artisan storage:link` et copier le dossier `storage/app/public`.
- **Un paiement Lightning reste « en attente »** : appuyer sur « Vérifier maintenant », puis lire `storage/logs/laravel.log` sur le serveur et vérifier l’adresse du webhook.

## Ce qui est en test ou simulé

- Le Bitcoin Lightning marche de bout en bout, avec un serveur LNbits de démonstration.
- PayDunya est en mode test : la page affiche « PAIEMENT TEST » et aucun argent réel n’est débité.
- Les retraits en FCFA sont simulés.
- L’application existe seulement en APK Android, elle n’est pas sur le Play Store.
- Le serveur gratuit convient à une démonstration.

Auteure : [@Faith-time](https://github.com/Faith-time)
