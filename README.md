<div align="center">

# SamaBoutik — Application mobile

**Application Flutter pour les petits commerçants : produits, stock, ventes, encaissement Bitcoin Lightning et mobile money, statistiques et analyse.**

![Flutter](https://img.shields.io/badge/Flutter-3.41%2B-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.11-0175C2?logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-APK-3DDC84?logo=android&logoColor=white)
![Bitcoin](https://img.shields.io/badge/Bitcoin-Lightning-F7931A?logo=bitcoin&logoColor=white)
![Backend](https://img.shields.io/badge/Backend-Laravel%2013-FF2D20?logo=laravel&logoColor=white)

**Télécharger l'APK :** onglet [Releases](https://github.com/Faith-time/samaboutik-app/releases) · **API :** `https://samaboutik.alwaysdata.net/api`

</div>

---

## Sommaire

1. [Présentation](#1-présentation)
2. [Parcours de l'application](#2-parcours-de-lapplication)
3. [Stack technique](#3-stack-technique)
4. [Architecture et communication avec le backend](#4-architecture-et-communication-avec-le-backend)
5. [Paiements](#5-paiements)
6. [Configuration](#6-configuration)
7. [Installation et lancement en développement](#7-installation-et-lancement-en-développement)
8. [Construire l'APK de production](#8-construire-lapk-de-production)
9. [Publier l'APK sur GitHub Releases](#9-publier-lapk-sur-github-releases)
10. [Installer l'APK (jury, testeurs)](#10-installer-lapk-jury-testeurs)
11. [Mettre à jour l'application](#11-mettre-à-jour-lapplication)
12. [Déploiement complet : vue d'ensemble](#12-déploiement-complet--vue-densemble)
13. [Dépannage](#13-dépannage)
14. [Limites connues et transparence](#14-limites-connues-et-transparence)
15. [Dépôts liés](#15-dépôts-liés)

---

## 1. Présentation

**SamaBoutik** aide les petits commerçants du Sénégal à tenir leur boutique depuis leur téléphone :

- cataloguer leurs **produits** (avec photo) et suivre leur **stock** en unités et en paquets ;
- enregistrer des **ventes** en quelques touches ;
- encaisser en **espèces**, par **mobile money** (Wave, Orange Money, Free Money via PayDunya) ou en **Bitcoin Lightning** ;
- consulter leurs **ventes**, un **classement de leurs produits**, des **statistiques** et une **analyse** avec des conseils ;
- simuler un **retrait en FCFA** ;
- comprendre le Bitcoin grâce à une section de questions fréquentes.

L'application est un client mobile : toute la logique métier et les paiements passent par l'**API Laravel** (voir [§15](#15-dépôts-liés)).

---

## 2. Parcours de l'application

Le parcours complet se déroule en 13 chapitres.

| # | Chapitre | Ce que fait l'utilisateur |
|---|---|---|
| 1 | **Bienvenue et connexion** | Trois écrans d'accueil (gérer sa boutique, « C'est quoi le Bitcoin ? », « Un prix qui change »), puis connexion par numéro de téléphone et mot de passe. |
| 2 | **L'accueil** | Ventes du jour, total des ventes sur 30 jours, ventes Bitcoin, alerte « produits à racheter », bouton **Nouvelle vente** et actions rapides (produits, ventes, analyse, stock, classement). |
| 3 | **Produits et stock** | Catalogue avec états (en stock, stock bas, épuisé) ; création d'un produit (nom, photo, prix de vente, prix d'achat, suivi du stock, unités par paquet, stock de départ, seuil d'alerte) ; écran **Mon stock** (valeur du stock, achats sur 30 jours, produits à réapprovisionner). |
| 4 | **Nouvelle vente** | Sélection des produits, quantités, stock restant, total ; un produit épuisé ne peut pas être vendu. |
| 5 | **Paiement en Bitcoin** | Facture Lightning avec QR code, compte à rebours de 5 minutes, ouverture du portefeuille. |
| 6 | **Paiement mobile money** | Choix de Wave, Orange Money ou Free Money, page de paiement PayDunya, attente puis confirmation. |
| 7 | **Après la vente** | Détail de la vente, retour à l'accueil, alertes de stock mises à jour. |
| 8 | **Suivre ses ventes** | Totaux sur 7 jours, 30 jours, 3 mois avec courbe ; détail par moyen de paiement ; dernières ventes avec statut (payée, en attente, annulée). |
| 9 | **Classement des produits** | Podium et autres produits, par période (jour, semaine, mois, année) et par critère (plus vendus, plus rentables, plus de ventes). |
| 10 | **Analyse** | Ventes de la semaine comparées à la précédente, panier moyen, bénéfice, meilleur jour, produits stars, « À faire maintenant » et conseils. |
| 11 | **Statistiques et finances** | Recettes de la semaine, répartition par moyen de paiement, bénéfice estimé, stock et finances. |
| 12 | **Retrait en FCFA** | Solde retraitable, choix de l'opérateur, historique des retraits (**simulation**). |
| 13 | **Profil et aide** | Profil, boutique, accès aux produits, retrait, section **Comprendre le Bitcoin** (FAQ), à propos, déconnexion. |

---

## 3. Stack technique

| Domaine | Package | Rôle |
|---|---|---|
| Framework | **Flutter** (SDK `>=3.41.0`), **Dart** `^3.11.0` | Application Android |
| Requêtes HTTP | `dio ^5.11.1` | Appels vers l'API Laravel |
| Gestion d'état | `provider ^6.1.5+1` | État partagé entre écrans |
| Stockage sécurisé | `flutter_secure_storage ^11.2.0` | Jeton d'authentification |
| Préférences | `shared_preferences ^2.5.6` | Réglages locaux |
| QR code | `qr_flutter ^4.1.0` | Affichage de la facture Lightning |
| Page de paiement | `webview_flutter ^4.14.1` | Page PayDunya dans l'application |
| Graphiques | `fl_chart ^1.3.0` | Courbes et histogrammes des ventes |
| Formats | `intl` | Dates et montants en FCFA |
| Liens externes | `url_launcher ^6.3.3` | Ouverture du portefeuille Bitcoin |
| Réseau | `connectivity_plus ^7.3.2` | Détection de la connexion |
| Partage | `share_plus ^13.3.1` | Partage de contenu |
| Photos | `image_picker ^1.2.4` | Photo du produit (appareil photo ou galerie) |
| Images réseau | `cached_network_image ^3.4.1` | Affichage et cache des photos de produits |
| Icônes | `cupertino_icons ^1.0.8` | Icônes |

**Ressources déclarées** (`pubspec.yaml`) : `assets/images/` (`illustration_bienvenue.png`, `logo_icone.png`).
**Version actuelle :** `1.0.0+1`.

---

## 4. Architecture et communication avec le backend

```
┌──────────────────────┐   HTTPS / JSON    ┌───────────────────────────────┐
│  Application Flutter │ ────────────────► │  API Laravel (alwaysdata)     │
│  (dio + provider)    │ ◄──────────────── │  https://samaboutik.          │
│                      │  Bearer (Sanctum) │  alwaysdata.net/api           │
└──────────┬───────────┘                   └───────────────┬───────────────┘
           │                                               │
           │ WebView (page PayDunya)                       ├── LNbits (Lightning)
           │ url_launcher (portefeuille Bitcoin)           ├── PayDunya (mobile money)
           ▼                                               └── MySQL
   Fournisseurs de paiement
```

- **Adresse de l'API** : centralisée dans la classe `Config`, avec une valeur par défaut pointant vers la production et une surcharge possible à la compilation :

```dart
class Config {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://samaboutik.alwaysdata.net/api',
  );
}
```

- **Authentification** : après connexion, l'API renvoie un jeton Sanctum, conservé avec `flutter_secure_storage` et envoyé à chaque requête dans `Authorization: Bearer <jeton>`.
- **Réseau** : `connectivity_plus` permet de réagir à une perte de connexion.
- **Photos de produits** : choisies avec `image_picker` (**Prendre une photo** ou **Choisir dans la galerie**), envoyées à l'API (`POST /api/produits/{id}/image`), puis affichées avec `cached_network_image`.

---

## 5. Paiements

### Espèces
Enregistrement immédiat du paiement.

### Bitcoin Lightning (via LNbits)
1. L'application demande une facture pour la vente.
2. Le backend convertit le montant FCFA en satoshis au cours du moment et crée la facture (valable **5 minutes**).
3. L'application affiche un **QR code** (`qr_flutter`) et un **compte à rebours** ; le bouton **Ouvrir le paiement** lance le portefeuille installé (`url_launcher`).
4. Dès que le client paie, le backend reçoit la notification de LNbits ; l'écran passe tout seul à **Paiement réussi**. Un bouton **Vérifier maintenant** interroge le statut à la demande.
5. Si le délai expire, un nouveau code est créé au cours du moment.

### Mobile money (via PayDunya)
1. L'utilisateur choisit Wave, Orange Money ou Free Money.
2. L'application ouvre la page de paiement PayDunya dans une **WebView** (`webview_flutter`).
3. Après paiement, le backend reçoit la notification (IPN) et l'application affiche la confirmation.

**Mode actuel : test PayDunya** — la page de paiement affiche « PAIEMENT TEST » et aucun argent réel n'est débité.

---

## 6. Configuration

### Adresse de l'API

| Cas | Commande |
|---|---|
| Production (par défaut) | aucune option : `flutter run` ou `flutter build apk --release` |
| API locale sur émulateur Android | `flutter run --dart-define=BASE_URL=http://10.0.2.2:8000/api` |
| API locale sur téléphone (même Wi-Fi) | `flutter run --dart-define=BASE_URL=http://<IP-du-PC>:8000/api` |

> ⚠️ Pour le build de production, **ne pas** passer `--dart-define=BASE_URL=…` avec une adresse locale.

### Android (`android/app/src/main/AndroidManifest.xml`)

- **Permission Internet** (indispensable dans l'APK de production) :
  ```xml
  <uses-permission android:name="android.permission.INTERNET"/>
  ```
- **Requête d'ouverture de liens `https`** (portefeuille et pages externes) via `<queries>` avec `android.intent.action.VIEW` et le schéma `https`.
- `android:usesCleartextTraffic="true"` autorise le HTTP en développement local. L'API de production est en HTTPS.
- Nom affiché : `SamaBoutik`.

---

## 7. Installation et lancement en développement

**Prérequis :** Flutter (SDK >= 3.41), Android Studio ou VS Code, un émulateur ou un téléphone Android, Git.

```bash
git clone https://github.com/Faith-time/samaboutik-app.git
cd samaboutik-app

flutter pub get
flutter doctor          # vérifier l'environnement

flutter run             # utilise l'API de production par défaut
```

Pour développer contre le backend local (Laravel sur `localhost:8000`) :

```bash
flutter run --dart-define=BASE_URL=http://10.0.2.2:8000/api
```

---

## 8. Construire l'APK de production

Commandes exécutées depuis la racine du projet (Git Bash sous Windows) :

```bash
cd /c/laragon/www/FLUTTER/samaboutik_app

flutter clean
flutter pub get
flutter build apk --release
```

La première compilation release est longue (téléchargement des dépendances Gradle, plusieurs minutes). En cas de succès, Flutter affiche le chemin du fichier :

```
build/app/outputs/flutter-apk/app-release.apk
```

Avant de compiler, vérifier qu'aucune adresse locale ne subsiste :

```bash
grep -rn "alwaysdata\|localhost\|10.0.2.2\|192.168" lib/
```

On doit voir uniquement `https://samaboutik.alwaysdata.net/api`.

**Signature.** L'APK est signé avec la clé de debug fournie par Flutter. C'est suffisant pour installer et tester l'application, mais **pas** pour une publication sur le Google Play Store (qui exige une clé de signature personnelle). Pour les mises à jour installables par-dessus, compiler toujours depuis le même ordinateur.

---

## 9. Publier l'APK sur GitHub Releases

GitHub **ne compile pas** l'APK : il sert à **héberger le fichier** et à fournir un lien de téléchargement public. L'APK est compilé sur l'ordinateur du développeur (§8).

1. Renommer `app-release.apk` en **`SamaBoutik.apk`**.
2. Ouvrir le dépôt `samaboutik-app` sur GitHub → colonne de droite → **Releases** → **Create a new release**.
3. **Choose a tag** : saisir `v1.0.0` puis créer le tag.
4. **Release title** : `SamaBoutik v1.0.0`.
5. Dans la zone **Attach binaries**, déposer `SamaBoutik.apk`.
6. Cliquer sur **Publish release**.

Le lien de téléchargement direct a la forme :

```
https://github.com/Faith-time/samaboutik-app/releases/download/v1.0.0/SamaBoutik.apk
```

---

## 10. Installer l'APK (jury, testeurs)

1. Sur un téléphone **Android**, ouvrir le lien de téléchargement de l'APK.
2. Autoriser l'installation depuis cette source si Android le demande (**sources inconnues**).
3. **Google Play Protect** peut afficher un avertissement, car l'application ne provient pas du Play Store : choisir d'installer quand même.
4. Ouvrir **SamaBoutik** et se connecter ou créer un compte. Une connexion Internet est nécessaire (l'application communique avec l'API en ligne).

Si une ancienne version est déjà installée, la **désinstaller** d'abord (les signatures peuvent différer).

---

## 11. Mettre à jour l'application

| Type de modification | Action |
|---|---|
| Changement du **backend Laravel** | `git pull` sur le serveur (voir le dépôt API). Les applications déjà installées en bénéficient **immédiatement**. |
| Changement de l'**application Flutter** (écrans, code Dart) | Recompiler un APK, augmenter la version, publier une nouvelle Release, réinstaller. **Pas de mise à jour automatique**, l'APK n'étant pas distribué via le Play Store. |

Procédure pour une nouvelle version :

1. Dans `pubspec.yaml`, augmenter la version, par exemple `version: 1.0.1+2` (le nombre après `+` doit toujours augmenter).
2. Recompiler : `flutter clean && flutter pub get && flutter build apk --release`.
3. Créer une nouvelle Release (`v1.0.1`) avec le nouvel APK.
4. Sur un téléphone branché en USB, `flutter install --release` permet aussi de mettre à jour directement.

---

## 12. Déploiement complet : vue d'ensemble

| Étape | Où | Outil | Résultat |
|---|---|---|---|
| 1 | Serveur | **alwaysdata** (gratuit) : site PHP, base MySQL, SSH, phpMyAdmin | Backend Laravel en ligne : `https://samaboutik.alwaysdata.net` |
| 2 | Serveur | `git clone`, `composer install --no-dev`, `.env`, `php artisan migrate` | API opérationnelle (`/api/ping`) |
| 3 | PC | `Config.baseUrl` = URL de l'API en HTTPS | L'application parle au serveur en ligne |
| 4 | PC | Permission `INTERNET` dans le manifeste | L'APK a accès au réseau |
| 5 | PC | `flutter build apk --release` | Fichier `app-release.apk` |
| 6 | Téléphone | Installation de l'APK, test en 4G | Parcours complet validé |
| 7 | GitHub | **Releases** : dépôt de `SamaBoutik.apk` | Lien de téléchargement public |
| 8 | Soumission | Lien APK, dépôts GitHub, vidéo de démonstration | Projet testable par le jury |

Le détail des commandes côté serveur se trouve dans le README du dépôt **samaboutik-api** (§11).

---

## 13. Dépannage

| Symptôme | Cause probable | Solution |
|---|---|---|
| L'application n'a aucun accès réseau dans l'APK mais fonctionne en développement | Permission `INTERNET` absente du manifeste principal | Ajouter `<uses-permission android:name="android.permission.INTERNET"/>` dans `android/app/src/main/AndroidManifest.xml`, puis recompiler. |
| L'application appelle une adresse locale | `BASE_URL` surchargée ou adresse locale dans le code | Vérifier avec `grep -rn "localhost\|10.0.2.2\|192.168" lib/`, recompiler **sans** `--dart-define`. |
| L'APK ne s'installe pas par-dessus l'ancienne version | Signatures différentes | Désinstaller l'ancienne version puis réinstaller. |
| Le build reste longtemps sur `Running Gradle task 'assembleRelease'` | Première compilation release | Patienter, c'est normal. |
| Les photos de produits ne s'affichent pas | Fichiers d'images absents du serveur | Voir le README de l'API (§11.9) : `php artisan storage:link` et copie de `storage/app/public`. |
| Un paiement Lightning reste « en attente » | Webhook non reçu ou facture expirée | Utiliser **Vérifier maintenant**, consulter `storage/logs/laravel.log` côté serveur, vérifier l'URL du webhook. |
| Erreur 500 côté API | Voir le README de l'API (§13) | Lire le journal Laravel. |

---

## 14. Limites connues et transparence

- **Bitcoin Lightning** : fonctionnel de bout en bout, via un serveur LNbits de **démonstration**.
- **PayDunya** : **mode test**, aucun argent réel.
- **Retraits en FCFA** : **simulés**.
- **Plateforme** : APK Android ; l'APK n'est pas publié sur le Play Store.
- **Hébergement du backend** : offre gratuite adaptée à une démonstration.

---

## 15. Dépôts liés

- **Backend Laravel (API) :** https://github.com/Faith-time/samaboutik-api
- **API en ligne :** https://samaboutik.alwaysdata.net/api/ping
- **APK :** [Releases](https://github.com/Faith-time/samaboutik-app/releases)

**Auteur :** [@Faith-time](https://github.com/Faith-time)
