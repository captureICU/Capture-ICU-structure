import Core
import SwiftUI

/// Figma « Login ». Connexion factice : demo / demo.
struct EcranConnexion: View {
    @Environment(EtatApp.self) private var etat

    @State private var courriel = ""
    @State private var motDePasse = ""
    @State private var refuse = false
    @State private var creerCompte = false
    @State private var motDePasseOublie = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Image(systemName: "person")
                            .font(.system(size: 22))
                            .foregroundStyle(Couleurs.bleu)
                            .frame(width: 56, height: 56)
                            .background(Couleurs.carte)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .padding(.top, 48)

                        EnTete(titre: "Connexion", sousTitre: "Entrez vos identifiants pour continuer.")

                        ChampSaisie(etiquette: "Courriel", indication: "vous@exemple.com", texte: $courriel)
                        ChampSaisie(etiquette: "Mot de passe", indication: "Entrez le mot de passe", texte: $motDePasse, secret: true)

                        HStack {
                            Spacer()
                            BoutonLien(titre: "Mot de passe oublié ?") { motDePasseOublie = true }
                        }
                        .padding(.top, -8)

                        if refuse {
                            Text("Courriel ou mot de passe incorrect.")
                                .font(.system(size: 15))
                                .foregroundStyle(Couleurs.rouge)
                        }
                        if motDePasseOublie {
                            Text("Démonstration : utilisez demo / demo.")
                                .font(.system(size: 15))
                                .foregroundStyle(Couleurs.texteSecondaire)
                        }

                        BoutonPrincipal(titre: "Se connecter") { seConnecter() }

                        HStack(spacing: 4) {
                            Text("Pas de compte ?")
                                .foregroundStyle(Couleurs.texteSecondaire)
                            BoutonLien(titre: "Créer un compte") { creerCompte = true }
                        }
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 24)
                }

                VStack(spacing: 12) {
                    BoutonSecondaire(titre: "Essayer sans compte") { etat.entrerEnDemo() }
                    NoteDeBas(texte: "Explorez l'un ou l'autre rôle. Aucun compte requis.")
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
            .background(Couleurs.fond)
            .navigationDestination(isPresented: $creerCompte) { EcranCreerCompte() }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func seConnecter() {
        if let utilisateur = ConnexionFactice().connecter(identifiant: courriel, motDePasse: motDePasse) {
            refuse = false
            etat.utilisateur = utilisateur
            etat.modeDemo = false
            etat.ecran = .roles
        } else {
            refuse = true
        }
    }
}
