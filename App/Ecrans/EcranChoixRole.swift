import SwiftUI

/// Figma « Choose a demo role ». Sert aussi après la connexion et pour « Changer de rôle ».
struct EcranChoixRole: View {
    @Environment(EtatApp.self) private var etat

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    BoutonRetour(titre: "Connexion") { etat.deconnecter() }
                        .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 8) {
                        if etat.modeDemo {
                            Text("MODE DÉMO")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Couleurs.bleu)
                        }
                        EnTete(
                            titre: "Choisir un rôle",
                            sousTitre: etat.modeDemo
                                ? "Essayez l'une ou l'autre expérience sans créer de compte."
                                : "Choisissez l'expérience à utiliser.")
                    }

                    VStack(spacing: 12) {
                        CarteAction(
                            symbole: "doc.badge.plus",
                            titre: "Essayer le rôle M",
                            description: "Créer et téléverser des formulaires"
                        ) { etat.choisirRole(.m) }

                        CarteAction(
                            symbole: "camera",
                            titre: "Essayer le rôle INF",
                            description: "Prendre des photos ou remplir un formulaire"
                        ) { etat.choisirRole(.inf) }
                    }

                    if etat.modeDemo {
                        Carte {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "info.circle")
                                    .foregroundStyle(Couleurs.texteSecondaire)
                                Text("Les formulaires, enregistrements et photos sont un aperçu seulement. Rien n'est enregistré ni téléversé.")
                                    .font(.system(size: 15))
                                    .foregroundStyle(Couleurs.texteSecondaire)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 24)
            }

            NoteDeBas(texte: "Vous pouvez changer de rôle depuis l'accueil.")
                .padding(.bottom, 16)
        }
        .background(Couleurs.fond)
    }
}
