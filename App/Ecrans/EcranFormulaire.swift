import Core
import SwiftUI

/// Figma « INF form », « M form sheet » et « Audio recording ».
///
/// Rôle INF : l'information tapée devient la note, et chaque enregistrement y
/// est ajouté par le module Transcription (via le Core), au téléversement.
/// Rôle M : DÉMO, le formulaire est seulement gardé en mémoire.
///
/// SQUELETTE : l'enregistrement est factice (aucun micro). Le vrai micro viendra
/// avec le module Transcription.
struct EcranFormulaire: View {
    let role: Role
    /// Appelé avec le nombre d'enregistrements, une fois téléversé.
    let televerse: (Int) -> Void

    @Environment(EtatApp.self) private var etat
    @Environment(\.dismiss) private var fermer

    @State private var information = ""
    @State private var champs: [EtatAudio] = [.vide, .vide]
    @State private var erreur: String?

    var body: some View {
        VStack(spacing: 0) {
            barreDuHaut
            BandeauDemo()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Tapez l'information. Touchez un micro pour enregistrer l'audio des autres champs.")
                        .font(.system(size: 15))
                        .foregroundStyle(Couleurs.texteSecondaire)
                        .padding(.top, 20)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Informations")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Couleurs.texte)
                        ZStack(alignment: .topLeading) {
                            if information.isEmpty {
                                Text("Exemple d'information")
                                    .font(.system(size: 17))
                                    .foregroundStyle(Couleurs.texteSecondaire)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 18)
                            }
                            TextEditor(text: $information)
                                .font(.system(size: 17))
                                .scrollContentBackground(.hidden)
                                .padding(.horizontal, 11)
                                .padding(.vertical, 10)
                        }
                        .frame(minHeight: 86)
                        .background(Couleurs.carte)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    ForEach(champs.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Champ \(index + 2)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Couleurs.texte)
                            ChampAudio(etat: $champs[index])
                        }
                    }

                    Text(enregistrementEnCours
                         ? "Arrêtez l'enregistrement avant de téléverser."
                         : "Vous pouvez écouter ou supprimer l'audio avant de téléverser.")
                        .font(.system(size: 13))
                        .foregroundStyle(Couleurs.texteSecondaire)

                    if let erreur {
                        Text(erreur)
                            .font(.system(size: 15))
                            .foregroundStyle(Couleurs.rouge)
                    }
                }
                .padding(.horizontal, 24)
            }

            VStack(spacing: 12) {
                NoteDeBas(texte: "Démo seulement. Rien ne sera téléversé.")
                BoutonPrincipal(titre: "Téléverser", actif: peutTeleverser) {
                    Task { await televerser() }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .background(Couleurs.fond)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Barre du haut (différente selon le rôle, comme dans le Figma)

    private var barreDuHaut: some View {
        ZStack {
            Text("Nouveau formulaire")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Couleurs.texte)
            HStack {
                if role == .inf {
                    BoutonRetour(titre: "Accueil") { fermer() }
                    Spacer()
                    BoutonLien(titre: "Annuler", taille: 17) { fermer() }
                } else {
                    BoutonLien(titre: "Annuler", taille: 17) { fermer() }
                    Spacer()
                    Text("M")
                        .font(.system(size: 15))
                        .foregroundStyle(Couleurs.texteSecondaire)
                }
            }
        }
        .padding(.horizontal, 24)
        .frame(height: 52)
    }

    // MARK: - Règles

    private var enregistrementEnCours: Bool {
        champs.contains { if case .enCours = $0 { return true } else { return false } }
    }

    private var durees: [Double] {
        champs.compactMap { if case .enregistre(let duree) = $0 { return duree } else { return nil } }
    }

    private var peutTeleverser: Bool {
        !enregistrementEnCours && (!information.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !durees.isEmpty)
    }

    private func televerser() async {
        switch role {
        case .inf:
            var copie = etat.session
            do {
                try copie.ecrireNote(information)
                for duree in durees {
                    try await copie.ajouterALaNote(Audio(donnees: Data([0x01]), dureeSecondes: duree))
                }
                etat.session = copie
                televerse(durees.count)
            } catch ErreurSession.dejaValide {
                erreur = "La note de ce patient est déjà créée. Recommencez une visite depuis l'accueil."
            } catch {
                erreur = "Le téléversement a échoué : \(error)"
            }
        case .m:
            etat.formulairesM.append(
                FormulaireDemo(information: information, nombreEnregistrements: durees.count, creeLe: Date()))
            televerse(durees.count)
        }
    }
}

// MARK: - Un champ audio

/// Les trois états d'un champ audio du Figma.
enum EtatAudio: Equatable {
    /// « Ajouter un audio » + micro.
    case vide
    /// Cadre rouge : « ● Enregistrement », onde, minuteur, Annuler, Arrêter.
    case enCours(debut: Date)
    /// « Enregistrement audio · 00:12 · Prêt à téléverser », lecture, corbeille.
    case enregistre(duree: Double)
}

struct ChampAudio: View {
    @Binding var etat: EtatAudio

    var body: some View {
        switch etat {
        case .vide:
            HStack(spacing: 12) {
                Text("Ajouter un audio")
                    .font(.system(size: 17))
                    .foregroundStyle(Couleurs.texteSecondaire)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
                    .background(Couleurs.carte)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Button {
                    etat = .enCours(debut: Date())
                } label: {
                    Image(systemName: "mic")
                        .font(.system(size: 18))
                        .foregroundStyle(Couleurs.bleu)
                        .frame(width: 48, height: 48)
                        .background(Couleurs.bleuPale)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .accessibilityLabel("Enregistrer")
            }

        case .enCours(let debut):
            VStack(spacing: 16) {
                HStack {
                    HStack(spacing: 6) {
                        Circle().fill(Couleurs.rouge).frame(width: 7, height: 7)
                        Text("Enregistrement")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Couleurs.rouge)
                    }
                    Spacer()
                    Onde()
                    Spacer()
                    TimelineView(.periodic(from: debut, by: 1)) { contexte in
                        Text(Self.minuteur(contexte.date.timeIntervalSince(debut)))
                            .font(.system(size: 15).monospacedDigit())
                            .foregroundStyle(Couleurs.texte)
                    }
                }
                HStack {
                    BoutonLien(titre: "Annuler") { etat = .vide }
                    Spacer()
                    Button {
                        etat = .enregistre(duree: max(Date().timeIntervalSince(debut), 1))
                    } label: {
                        Label("Arrêter", systemImage: "stop.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Couleurs.rouge)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Couleurs.rougePale)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .padding(14)
            .background(Couleurs.carte)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Couleurs.rouge, lineWidth: 1.5))

        case .enregistre(let duree):
            HStack(spacing: 14) {
                Image(systemName: "play")
                    .font(.system(size: 15))
                    .foregroundStyle(Couleurs.bleu)
                    .frame(width: 38, height: 38)
                    .background(Couleurs.bleuPale)
                    .clipShape(Circle())
                    .accessibilityLabel("Écouter (démo)")
                VStack(alignment: .leading, spacing: 2) {
                    Text("Enregistrement audio")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Couleurs.texte)
                    Text("\(Self.minuteur(duree)) · Prêt à téléverser")
                        .font(.system(size: 13))
                        .foregroundStyle(Couleurs.texteSecondaire)
                }
                Spacer()
                Button {
                    etat = .vide
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(Couleurs.texteSecondaire)
                }
                .accessibilityLabel("Supprimer l'enregistrement")
            }
            .padding(14)
            .background(Couleurs.carte)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    /// 8 secondes → « 00:08 ».
    static func minuteur(_ secondes: Double) -> String {
        let total = Int(secondes)
        let minutes = total / 60
        let reste = total % 60
        return (minutes < 10 ? "0" : "") + "\(minutes):" + (reste < 10 ? "0" : "") + "\(reste)"
    }
}

/// L'onde rouge de l'enregistrement (décorative).
struct Onde: View {
    private let hauteurs: [CGFloat] = [8, 14, 22, 12, 26, 18, 10, 24, 16, 8, 20, 12]

    var body: some View {
        HStack(spacing: 3) {
            ForEach(hauteurs.indices, id: \.self) { i in
                Capsule()
                    .fill(Couleurs.rouge)
                    .frame(width: 2.5, height: hauteurs[i])
            }
        }
        .frame(height: 26)
        .accessibilityHidden(true)
    }
}
