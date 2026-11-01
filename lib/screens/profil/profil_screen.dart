import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/aide_info.dart';
import '../../widgets/bouton_principal.dart';
import '../../widgets/carte_neo.dart';
import '../../widgets/composants_neo.dart';
import '../../widgets/fond_neo.dart';
import '../bitcoin/comprendre_bitcoin_screen.dart';
import '../produits/liste_produits_screen.dart';
import '../retrait/retrait_screen.dart';

/// Onglet Profil : informations du commerçant et menu.
class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final u = context.watch<AuthProvider>().utilisateur;
    return CorpsNeo(
      titre: 'Profil',
      defiler: true,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: Couleurs.bleuClair,
              shape: BoxShape.circle,
              boxShadow: ombresNeo,
            ),
            child: const Icon(Icons.person_rounded,
                size: 44, color: Couleurs.bleu),
          ),
          const SizedBox(height: 12),
          Text(u?.nom ?? '', style: Typo.titre),
          const Text('Commerçant', style: Typo.doux),
          const SizedBox(height: 22),
          CarteNeo(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Column(
              children: [
                LigneMenu(
                  icone: Icons.storefront_outlined,
                  titre: 'Ma boutique',
                  sousTitre: u?.boutique?.nom,
                  onTap: () => afficherAide(
                    context,
                    u?.boutique?.nom ?? 'Ma boutique',
                    'Téléphone : ${u?.telephone ?? ''}',
                  ),
                ),
                const Divider(height: 1),
                LigneMenu(
                  icone: Icons.inventory_2_outlined,
                  titre: 'Mes produits',
                  onTap: () => aller(context, const ListeProduitsScreen()),
                ),
                const Divider(height: 1),
                LigneMenu(
                  icone: Icons.account_balance_wallet_outlined,
                  titre: 'Retirer en FCFA',
                  sousTitre: 'Simulation',
                  onTap: () => aller(context, const RetraitScreen()),
                ),
                const Divider(height: 1),
                LigneMenu(
                  icone: Icons.help_outline_rounded,
                  titre: 'Comprendre le Bitcoin',
                  onTap: () => aller(context, const ComprendreBitcoinScreen()),
                ),
                const Divider(height: 1),
                LigneMenu(
                  icone: Icons.info_outline_rounded,
                  titre: 'À propos',
                  onTap: () => afficherAide(
                    context,
                    'SamaBoutik',
                    "Une application simple pour encaisser vos clients, suivre vos ventes et comprendre votre activité.",
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          BoutonPrincipal(
            texte: 'Se déconnecter',
            icone: Icons.logout_rounded,
            danger: true,
            onPressed: () => context.read<AuthProvider>().deconnexion(),
          ),
        ],
      ),
    );
  }
}
