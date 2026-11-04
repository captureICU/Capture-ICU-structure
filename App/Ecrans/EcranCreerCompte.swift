import Core
import SwiftUI

/// Figma « Create account ». FACTICE : aucun compte n'est créé sur un serveur.
struct EcranCreerCompte: View {
    @Environment(EtatApp.self) private var etat
    @Environment(\.dismiss) private var fermer

    @State private var courriel = ""
    @State private var motDePasse = ""
    @State private var role: Role = .m
    @State private var erreur: String?

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    BoutonRetour(titre: "Connexion") { fermer() }
                        .padding(.top, 8)

                    EnTete(titre: "Créer un compte", sousTitre: "Entrez vos informations et choisissez votre rôle.")

                    ChampSaisie(etiquette: "Courriel", indication: "vous@exemple.com", texte: $courriel)

                    VStack(alignment: .leading, spacing: 12) {
                        ChampSaisie(etiquette: "Mot de passe", indication: "Créez un mot de passe", texte: $motDePasse, secret: true)
                        Text("Au moins 8 caractères.")
                            .font(.system(size: 13))
                            .foregroundStyle(Couleurs.texteSecondaire)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Votre rôle")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Couleurs.texte)
                        ForEach(Role.allCases, id: \.self) { choix in
                            optionDeRole(choix)
                        }
                    }

                    if let erreur {
                        Text(erreur)
                            .font(.system(size: 15))
                            .foregroundStyle(Couleurs.rouge)
                    }
                }
                .padding(.horizontal, 24)
            }

            BoutonPrincipal(titre: "Créer le compte") { creer() }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
        }
        .background(Couleurs.fond)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func optionDeRole(_ choix: Role) -> some View {
        let choisi = role == choix
        return Button {
            role = choix
        } label: {
            HStack {
                Text(choix.nom)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Couleurs.texte)
                Spacer()
                Image(systemName: choisi ? "checkmark.circle" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(choisi ? Couleurs.bleu : Couleurs.texteSecondaire)
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 64)
            .background(choisi ? Couleurs.bleuPale : Couleurs.carte)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(choisi ? Couleurs.bleu : Color.clear, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }

    private func creer() {
        guard courriel.contains("@") else {
            erreur = "Entrez un courriel valide."
            return
        }
        guard motDePasse.count >= 8 else {
            erreur = "Le mot de passe doit avoir au moins 8 caractères."
            return
        }
        erreur = nil
        etat.utilisateur = Utilisateur(identifiant: courriel)
        etat.modeDemo = false
        etat.choisirRole(role)
    }
}
