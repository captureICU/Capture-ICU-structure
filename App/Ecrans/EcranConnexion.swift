import Core
import SwiftUI

/// Étape 1 · Connexion (factice : demo / demo).
struct EcranConnexion: View {
    let connecte: (Utilisateur) -> Void

    @State private var identifiant = ""
    @State private var motDePasse = ""
    @State private var refuse = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Identifiant", text: $identifiant)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    SecureField("Mot de passe", text: $motDePasse)
                }
                if refuse {
                    Text("Identifiant ou mot de passe incorrect.")
                        .foregroundStyle(Color.red)
                }
                Button("Se connecter") {
                    if let utilisateur = ConnexionFactice().connecter(identifiant: identifiant, motDePasse: motDePasse) {
                        connecte(utilisateur)
                    } else {
                        refuse = true
                    }
                }
                Text("Démonstration : demo / demo")
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
            }
            .navigationTitle("Capture ICU")
        }
    }
}
