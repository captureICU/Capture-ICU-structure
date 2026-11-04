import SwiftUI

/// Figma « Upload complete ».
///
/// AJOUTÉ au Figma : la variante « note infirmière », avec le bouton de partage
/// du PDF produit par le module Export.
struct EcranTermine: View {
    let resultat: Resultat
    let retourAccueil: () -> Void
    let recommencer: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            BandeauDemo()

            HStack {
                Spacer()
                Button("Terminé") { retourAccueil() }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Couleurs.bleu)
            }
            .padding(.horizontal, 24)
            .frame(height: 52)

            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 30, weight: .regular))
                        .foregroundStyle(Couleurs.bleu)
                        .frame(width: 88, height: 88)
                        .background(Couleurs.bleuPale)
                        .clipShape(Circle())
                        .padding(.top, 72)

                    VStack(spacing: 12) {
                        Text(titre)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Couleurs.texte)
                        Text(explication)
                            .font(.system(size: 17))
                            .foregroundStyle(Couleurs.texteSecondaire)
                            .multilineTextAlignment(.center)
                    }

                    Carte {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 18))
                                    .foregroundStyle(Couleurs.bleu)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(nomElement)
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundStyle(Couleurs.texte)
                                    Text(detailElement)
                                        .font(.system(size: 13))
                                        .foregroundStyle(Couleurs.texteSecondaire)
                                }
                            }
                            HStack {
                                Text("Statut")
                                    .font(.system(size: 15))
                                    .foregroundStyle(Couleurs.texteSecondaire)
                                Spacer()
                                Text("Aperçu démo")
                                    .font(.system(size: 15))
                                    .foregroundStyle(Couleurs.bleu)
                            }
                        }
                    }

                    if case .noteInfirmiere(let fichier) = resultat {
                        ShareLink(item: fichier) {
                            Label("Partager la note infirmière (PDF)", systemImage: "square.and.arrow.up")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Couleurs.bleu)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }

            VStack(spacing: 16) {
                BoutonPrincipal(titre: "Retour à l'accueil") { retourAccueil() }
                BoutonLien(titre: libelleRecommencer, taille: 17) { recommencer() }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .background(Couleurs.fond)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Textes selon ce qui vient d'être fait

    private var titre: String {
        switch resultat {
        case .noteInfirmiere: return "Note infirmière prête"
        default: return "Téléversement terminé"
        }
    }

    private var explication: String {
        switch resultat {
        case .noteInfirmiere:
            return "Le PDF a été créé à partir des valeurs validées. Rien n'a réellement été envoyé."
        default:
            return "Ceci est une confirmation de démo. Rien n'a réellement été téléversé."
        }
    }

    private var nomElement: String {
        switch resultat {
        case .photos: return "Photos"
        case .formulaire: return "Formulaire"
        case .noteInfirmiere: return "Note infirmière"
        }
    }

    private var detailElement: String {
        switch resultat {
        case .photos(let nombre):
            return nombre > 1 ? "\(nombre) photos" : "\(nombre) photo"
        case .formulaire(let enregistrements):
            switch enregistrements {
            case 0: return "Informations"
            case 1: return "Informations et 1 enregistrement audio"
            default: return "Informations et \(enregistrements) enregistrements audio"
            }
        case .noteInfirmiere(let fichier):
            return fichier.lastPathComponent
        }
    }

    private var libelleRecommencer: String {
        switch resultat {
        case .photos: return "Prendre d'autres photos"
        case .formulaire: return "Créer un autre formulaire"
        case .noteInfirmiere: return "Commencer une nouvelle visite"
        }
    }
}
