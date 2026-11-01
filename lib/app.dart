import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/accueil/accueil_screen.dart';
import 'screens/auth/connexion_screen.dart';
import 'screens/bienvenue/bienvenue_screen.dart';
import 'widgets/chargement.dart';
import 'widgets/fond_neo.dart';

class SamaBoutikApp extends StatelessWidget {
  const SamaBoutikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SamaBoutik',
      debugShowCheckedModeBanner: false,
      theme: themeSamaBoutik,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!auth.initialise) {
            return const Scaffold(body: FondNeo(child: Chargement()));
          }
          if (auth.estConnecte) return const AccueilScreen();
          if (!auth.bienvenueVue) return const BienvenueScreen();
          return const ConnexionScreen();
        },
      ),
    );
  }
}
