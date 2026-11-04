import SwiftUI

// LE STYLE DE L'APP, tiré du Figma « project-v2 ».
//
// Toutes les couleurs et tous les éléments répétés (boutons, champs, cartes,
// bandeau de démo) sont ici. Un écran ne choisit jamais une couleur lui-même :
// il utilise `Couleurs.bleu`, `BoutonPrincipal`, etc. Changer le style = changer ce fichier.

enum Couleurs {
    static let fond = Color(hex: 0xF2F2F7)
    static let carte = Color.white
    static let texte = Color(hex: 0x1C1C1E)
    static let texteSecondaire = Color(hex: 0x6C6C72)
    static let bleu = Color(hex: 0x007AFF)
    static let bleuPale = Color(hex: 0xEAF3FF)
    static let rouge = Color(hex: 0xFF3B30)
    static let rougePale = Color(hex: 0xFFECEB)
    static let desactive = Color(hex: 0xE3E3E8)
    static let texteDesactive = Color(hex: 0x8E8E93)
    static let cameraFond = Color(hex: 0x1C1C1E)
}

extension Color {
    /// `Color(hex: 0x007AFF)`
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255)
    }
}

// MARK: - Textes

/// Grand titre + phrase d'explication, en haut des écrans (« Connexion », « Accueil »).
struct EnTete: View {
    let titre: String
    var sousTitre: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titre)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(Couleurs.texte)
            if let sousTitre {
                Text(sousTitre)
                    .font(.system(size: 17))
                    .foregroundStyle(Couleurs.texteSecondaire)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Petite phrase grise centrée, en bas des écrans (« Démo seulement… »).
struct NoteDeBas: View {
    let texte: String

    var body: some View {
        Text(texte)
            .font(.system(size: 13))
            .foregroundStyle(Couleurs.texteSecondaire)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }
}

// MARK: - Boutons

/// Le gros bouton bleu (« Se connecter », « Téléverser »). Gris quand il est désactivé.
struct BoutonPrincipal: View {
    let titre: String
    var actif = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(titre)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(actif ? Color.white : Couleurs.texteDesactive)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(actif ? Couleurs.bleu : Couleurs.desactive)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!actif)
    }
}

/// Le bouton blanc à texte bleu (« Essayer sans compte »).
struct BoutonSecondaire: View {
    let titre: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(titre)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Couleurs.bleu)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(Couleurs.carte)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

/// Un lien bleu sans fond (« Mot de passe oublié ? », « Changer de rôle »).
struct BoutonLien: View {
    let titre: String
    var taille: CGFloat = 15
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(titre)
                .font(.system(size: taille))
                .foregroundStyle(Couleurs.bleu)
        }
    }
}

/// « ‹ Connexion », en haut à gauche.
struct BoutonRetour: View {
    let titre: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                Text(titre)
                    .font(.system(size: 17))
            }
            .foregroundStyle(Couleurs.bleu)
        }
    }
}

// MARK: - Champs

/// Un champ de saisie avec son étiquette au-dessus (« Courriel », « Mot de passe »).
/// Avec `secret: true`, le texte est masqué et un œil permet de l'afficher.
struct ChampSaisie: View {
    let etiquette: String
    let indication: String
    @Binding var texte: String
    var secret = false

    @State private var visible = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(etiquette)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Couleurs.texte)
            HStack {
                Group {
                    if secret && !visible {
                        SecureField(indication, text: $texte)
                    } else {
                        TextField(indication, text: $texte)
                    }
                }
                .font(.system(size: 17))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

                if secret {
                    Button {
                        visible.toggle()
                    } label: {
                        Image(systemName: visible ? "eye.slash" : "eye")
                            .foregroundStyle(Couleurs.texteSecondaire)
                    }
                    .accessibilityLabel(visible ? "Masquer le mot de passe" : "Afficher le mot de passe")
                }
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 52)
            .background(Couleurs.carte)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Cartes et icônes

/// Le fond blanc arrondi des cartes.
struct Carte<Contenu: View>: View {
    @ViewBuilder let contenu: () -> Contenu

    var body: some View {
        contenu()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Couleurs.carte)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

/// L'icône bleue sur fond bleu pâle, dans les cartes.
struct IconeCarree: View {
    let symbole: String
    var taille: CGFloat = 44

    var body: some View {
        Image(systemName: symbole)
            .font(.system(size: taille * 0.42))
            .foregroundStyle(Couleurs.bleu)
            .frame(width: taille, height: taille)
            .background(Couleurs.bleuPale)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

/// Une carte qu'on touche pour aller ailleurs : icône, titre, description, chevron.
/// `empilee` : icône au-dessus du texte (accueil INF); sinon à gauche (choix du rôle).
struct CarteAction: View {
    let symbole: String
    let titre: String
    let description: String
    var empilee = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Carte {
                if empilee {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .top) {
                            IconeCarree(symbole: symbole)
                            Spacer()
                            chevron
                        }
                        .padding(.bottom, 20)
                        textes(tailleTitre: 20)
                    }
                    .padding(4)
                } else {
                    HStack(spacing: 14) {
                        IconeCarree(symbole: symbole, taille: 40)
                        textes(tailleTitre: 17)
                        Spacer()
                        chevron
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(Couleurs.bleu)
    }

    private func textes(tailleTitre: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(titre)
                .font(.system(size: tailleTitre, weight: .semibold))
                .foregroundStyle(Couleurs.texte)
            Text(description)
                .font(.system(size: 15))
                .foregroundStyle(Couleurs.texteSecondaire)
                .multilineTextAlignment(.leading)
        }
    }
}

// MARK: - Bandeau de démo

/// « Mode démo · Rôle INF   Quitter la démo », sous la barre d'état.
struct BandeauDemo: View {
    @Environment(EtatApp.self) private var etat

    var body: some View {
        if etat.modeDemo {
            HStack {
                Text("Mode démo · Rôle \(etat.role.nom)")
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Button("Quitter la démo") { etat.deconnecter() }
                    .font(.system(size: 13))
            }
            .foregroundStyle(Couleurs.bleu)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(Couleurs.bleuPale)
        }
    }
}

/// « Rôle INF   Changer de rôle » + « Les éléments de démo ne sont pas enregistrés. »
struct PiedDeRole: View {
    @Environment(EtatApp.self) private var etat

    var body: some View {
        VStack(spacing: 16) {
            Carte {
                HStack {
                    Text("Rôle \(etat.role.nom)")
                        .font(.system(size: 15))
                        .foregroundStyle(Couleurs.texte)
                    Spacer()
                    BoutonLien(titre: "Changer de rôle") { etat.ecran = .roles }
                }
            }
            if etat.modeDemo {
                NoteDeBas(texte: "Les éléments de démo ne sont pas enregistrés.")
            }
        }
    }
}
