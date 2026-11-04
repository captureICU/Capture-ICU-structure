import Core
import Foundation
import SwiftUI

/// AJOUTÉ au Figma (exigé par la spécification 3.1, 7.2 et 8.2-1) :
/// l'infirmière vérifie les valeurs lues, corrige ou remplit ce qu'il faut,
/// puis valide. Le module Export crée alors la note infirmière en PDF.
///
/// Dans le style du Figma : fond gris, cartes blanches, bouton bleu en bas.
struct EcranVerification: View {
    /// Appelé avec le fichier PDF une fois la note créée.
    let noteCreee: (URL) -> Void

    @Environment(EtatApp.self) private var etat
    @Environment(\.dismiss) private var fermer

    /// Ce que l'infirmière a tapé dans chaque case, avant de toucher « OK ».
    @State private var saisies: [String: String] = [:]
    @State private var erreur: String?

    var body: some View {
        let session = etat.session

        VStack(spacing: 0) {
            ZStack {
                Text("Vérification")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Couleurs.texte)
                HStack {
                    BoutonRetour(titre: "Accueil") { fermer() }
                    Spacer()
                }
            }
            .padding(.horizontal, 24)
            .frame(height: 52)

            BandeauDemo()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("\(session.dossier.patient.code) · \(session.dossier.patient.lit). Vérifiez chaque valeur. En rouge : hors plage. Une case vide n'a pas pu être lue : remplissez-la.")
                        .font(.system(size: 15))
                        .foregroundStyle(Couleurs.texteSecondaire)
                        .padding(.top, 20)

                    if session.dossier.lectures.isEmpty {
                        Carte {
                            Text("Aucune photo pour l'instant. Commencez par « Prendre des photos ».")
                                .font(.system(size: 15))
                                .foregroundStyle(Couleurs.texteSecondaire)
                        }
                    }

                    ForEach(session.dossier.lectures, id: \.etape) { lecture in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(lecture.etape.titre)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Couleurs.texte)
                            Carte {
                                VStack(spacing: 12) {
                                    ForEach(lecture.mesures, id: \.parametre) { mesure in
                                        ligne(mesure, etape: lecture.etape, session: session)
                                    }
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Observations")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Couleurs.texte)
                        Carte {
                            Text(session.dossier.noteVocale ?? "Aucune note. Utilisez « Remplir un formulaire ».")
                                .font(.system(size: 15))
                                .foregroundStyle(session.dossier.noteVocale == nil ? Couleurs.texteSecondaire : Couleurs.texte)
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

            VStack(spacing: 12) {
                NoteDeBas(texte: "Démo seulement. Valeurs factices.")
                BoutonPrincipal(titre: "Valider et créer la note", actif: !session.dossier.estValide) {
                    validerEtCreer()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .background(Couleurs.fond)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Une valeur

    @ViewBuilder
    private func ligne(_ mesure: Mesure, etape: EtapeDeCapture, session: SessionDeCapture) -> some View {
        let horsPlage = session.alertes.contains {
            $0.etape == etape && $0.parametre == mesure.parametre && $0.raison == .horsPlage
        }
        let cle = "\(etape.titre)-\(mesure.parametre.rawValue)"

        HStack {
            Text(mesure.parametre.abreviation)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(horsPlage ? Couleurs.rouge : Couleurs.texte)
                .frame(width: 64, alignment: .leading)

            if let valeur = mesure.valeur {
                Text("\(Format.nombre(valeur)) \(mesure.parametre.unite)")
                    .font(.system(size: 17))
                    .foregroundStyle(horsPlage ? Couleurs.rouge : Couleurs.texte)
                if horsPlage {
                    Text("hors plage")
                        .font(.system(size: 13))
                        .foregroundStyle(Couleurs.rouge)
                }
                if mesure.corrigeeParInfirmiere {
                    Text("corrigée")
                        .font(.system(size: 13))
                        .foregroundStyle(Couleurs.texteSecondaire)
                }
                Spacer()
            } else {
                TextField("à remplir", text: Binding(
                    get: { saisies[cle] ?? "" },
                    set: { saisies[cle] = $0 }))
                    .keyboardType(.decimalPad)
                    .font(.system(size: 17))
                    .padding(.horizontal, 10)
                    .frame(height: 36)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Couleurs.rouge, lineWidth: 1))
                Text(mesure.parametre.unite)
                    .font(.system(size: 15))
                    .foregroundStyle(Couleurs.texteSecondaire)
                BoutonLien(titre: "OK") {
                    remplir(mesure.parametre, etape: etape, cle: cle)
                }
            }
        }
    }

    // MARK: - Actions

    private func remplir(_ parametre: Parametre, etape: EtapeDeCapture, cle: String) {
        let texte = (saisies[cle] ?? "").replacingOccurrences(of: ",", with: ".")
        guard let valeur = Double(texte) else {
            erreur = "\(parametre.abreviation) : entrez un nombre."
            return
        }
        var copie = etat.session
        do {
            try copie.corriger(parametre, a: etape, valeur: valeur)
            etat.session = copie
            saisies[cle] = nil
            erreur = nil
        } catch {
            erreur = "\(parametre.abreviation) : correction impossible (\(error))."
        }
    }

    private func validerEtCreer() {
        guard let utilisateur = etat.utilisateur else { return }
        var copie = etat.session
        do {
            try copie.valider(par: utilisateur)
            let document = try copie.exporter()
            // TEMPORAIRE : fichier dans le dossier temporaire, le temps du partage.
            // La spécification (3.1) interdit de garder des données cliniques sur
            // le téléphone : à revoir avant tout essai avec de vraies données.
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(document.nomFichier)
            try document.contenu.write(to: url)
            etat.session = copie
            erreur = nil
            noteCreee(url)
        } catch ErreurSession.photosManquantes {
            erreur = "Il reste des appareils à photographier (ou à passer) dans « Prendre des photos »."
        } catch ErreurSession.casesARemplir {
            erreur = "Remplissez les cases vides avant de valider."
        } catch {
            erreur = "La note n'a pas pu être créée : \(error)"
        }
    }
}
