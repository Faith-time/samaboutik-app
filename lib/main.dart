import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/paiement_provider.dart';
import 'providers/panier_provider.dart';
import 'providers/produit_provider.dart';
import 'providers/rapport_provider.dart';
import 'providers/retrait_provider.dart';
import 'providers/tableau_bord_provider.dart';
import 'providers/vente_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..demarrer()),
        ChangeNotifierProvider(create: (_) => ProduitProvider()),
        ChangeNotifierProvider(create: (_) => PanierProvider()),
        ChangeNotifierProvider(create: (_) => VenteProvider()),
        ChangeNotifierProvider(create: (_) => PaiementProvider()),
        ChangeNotifierProvider(create: (_) => TableauBordProvider()),
        ChangeNotifierProvider(create: (_) => RapportProvider()),
        ChangeNotifierProvider(create: (_) => RetraitProvider()),
      ],
      child: const SamaBoutikApp(),
    ),
  );
}
