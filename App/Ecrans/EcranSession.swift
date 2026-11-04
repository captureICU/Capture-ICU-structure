import Core
import Foundation
import SwiftUI

/// Étapes 3 à 6 · Photos, note vocale, validation, PDF.
///
/// SQUELETTE : les boutons envoient des octets factices au lieu d'ouvrir la
/// caméra et le micro. Brancher la vraie caméra et le vrai micro est le travail
/// des équipes OCR et Transcription, ici dans App/.
struct EcranSession: View {
    let utilisateur: Utilisateur

    @State private var session: SessionDeCapture
    @State private var erreur: String?
    @State private var fichierPDF: URL?

    init(utilisateur: Utilisateur, patient: Patient) {
        self.utilisateur = utilisateur
        _session = State(initialValue: SessionDeCapture(patient: patient, modules: .application))
    }

    var body: some View {
        List {
            Section("Photos") {
                if let etape = session.etapeCourante {
                    Text("Photographier : \(etape.titre)")
                        .font(.headline)
                    Button("Prendre la photo (factice)") {
                        Task { await prendrePhoto() }
                    }
                    Button("Pas de \(etape.titre.lowercased()) au chevet") {
                        session.passerEtape()
                    }
                } else {
                    Text("Toutes les photos sont faites.")
                }
                Button("+ Ajouter une pompe") {
                    session.ajouterPompe()
                }
            }

            Section("Note vocale") {
                Button("Dicter la note (factice)") {
                    Task { await dicter() }
                }
                if let note = session.dossier.noteVocale {
                    Text(note)
                }
            }

            Section("Valeurs à vérifier") {
                ForEach(session.dossier.lectures, id: \.etape) { lecture in
                    Text(lecture.etape.titre)
                        .font(.subheadline.bold())
                    ForEach(lecture.mesures, id: \.parametre) { mesure in
                        Text(mesure.enTexte)
                            .foregroundStyle(enAlerte(mesure, lecture.etape) ? Color.red : Color.primary)
                    }
                }
            }

            Section {
                if session.dossier.estValide {
                    if let fichierPDF {
                        ShareLink("Partager la note infirmière (PDF)", item: fichierPDF)
                    }
                } else {
                    Button("Valider le dossier") {
                        validerEtExporter()
                    }
                }
            }

            if let erreur {
                Text(erreur)
                    .foregroundStyle(Color.red)
            }
        }
        .navigationTitle(session.dossier.patient.code)
    }

    // MARK: - Actions

    private func prendrePhoto() async {
        var copie = session
        do {
            try await copie.capturerPhoto(Photo(donnees: Data([0x01])))
            session = copie
            erreur = nil
        } catch {
            erreur = "Photo : \(error)"
        }
    }

    private func dicter() async {
        var copie = session
        do {
            try await copie.enregistrerNote(Audio(donnees: Data([0x01]), dureeSecondes: 1))
            session = copie
            erreur = nil
        } catch {
            erreur = "Note : \(error)"
        }
    }

    private func validerEtExporter() {
        var copie = session
        do {
            try copie.valider(par: utilisateur)
            let document = try copie.exporter()
            // TEMPORAIRE : fichier dans le dossier temporaire, pour le partage.
            // La spécification (3.1) interdit de garder des données cliniques sur
            // le téléphone : à revoir avant tout essai avec de vraies données.
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(document.nomFichier)
            try document.contenu.write(to: url)
            session = copie
            fichierPDF = url
            erreur = nil
        } catch {
            erreur = "Validation : \(error)"
        }
    }

    private func enAlerte(_ mesure: Mesure, _ etape: EtapeDeCapture) -> Bool {
        session.alertes.contains { $0.etape == etape && $0.parametre == mesure.parametre }
    }
}
