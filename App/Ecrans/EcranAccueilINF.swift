import Core
import SwiftUI

/// Les écrans où l'on peut aller depuis l'accueil INF.
enum DestinationINF: Hashable {
    case formulaire
    case verification
    case termine(Resultat)
}

/// Ce que l'écran « Téléversement terminé » doit afficher.
enum Resultat: Hashable {
    case photos(nombre: Int)
    case formulaire(enregistrements: Int)
    case noteInfirmiere(fichier: URL)
}

/// Figma « INF home ».
///
/// AJOUTÉ au Figma (exigé par le squelette) : la carte « Patient » en haut, et
/// la carte « Vérifier et créer la note » sous les deux cartes du Figma.
struct EcranAccueilINF: View {
    @Environment(EtatApp.self) private var etat

    @State private var chemin: [DestinationINF] = []
    @State private var cameraOuverte = false
    @State private var choixPatient = false

    var body: some View {
        NavigationStack(path: $chemin) {
            VStack(spacing: 0) {
                BandeauDemo()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        EnTete(titre: "Accueil", sousTitre: "Choisissez ce que vous voulez téléverser.")
                            .padding(.top, 24)
                            .padding(.bottom, 8)

                        cartePatient

                        CarteAction(
                            symbole: "camera",
                            titre: "Prendre des photos",
                            description: "Capturer, vérifier et téléverser des photos.",
                            empilee: true
                        ) { cameraOuverte = true }

                        CarteAction(
                            symbole: "doc.text",
                            titre: "Remplir un formulaire",
                            description: "Ajouter des informations et des enregistrements audio.",
                            empilee: true
                        ) { chemin.append(.formulaire) }

                        CarteAction(
                            symbole: "checklist",
                            titre: "Vérifier et créer la note",
                            description: progression,
                            empilee: true
                        ) { chemin.append(.verification) }
                    }
                    .padding(.horizontal, 24)
                }
                PiedDeRole()
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }
            .background(Couleurs.fond)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: DestinationINF.self) { destination in
                switch destination {
                case .formulaire:
                    EcranFormulaire(role: .inf) { enregistrements in
                        chemin = [.termine(.formulaire(enregistrements: enregistrements))]
                    }
                case .verification:
                    EcranVerification { fichier in
                        chemin = [.termine(.noteInfirmiere(fichier: fichier))]
                    }
                case .termine(let resultat):
                    EcranTermine(resultat: resultat, retourAccueil: { chemin = [] }, recommencer: {
                        recommencer(apres: resultat)
                    })
                }
            }
            .fullScreenCover(isPresented: $cameraOuverte) {
                EcranCamera { nombre in
                    cameraOuverte = false
                    chemin = [.termine(.photos(nombre: nombre))]
                }
            }
            .sheet(isPresented: $choixPatient) {
                ChoixPatient()
                    .presentationDetents([.medium])
            }
        }
    }

    // MARK: - Ajouts au Figma

    private var cartePatient: some View {
        Carte {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Patient")
                        .font(.system(size: 13))
                        .foregroundStyle(Couleurs.texteSecondaire)
                    Text("\(etat.patient.code) · \(etat.patient.lit)")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Couleurs.texte)
                }
                Spacer()
                BoutonLien(titre: "Changer") { choixPatient = true }
            }
        }
    }

    /// « Photos 1/3 · Note : à faire »
    private var progression: String {
        let session = etat.session
        let faites = min(session.indexEtape, session.sequence.count)
        let note = session.dossier.noteVocale == nil ? "à faire" : "faite"
        if session.dossier.estValide {
            return "Note infirmière déjà créée."
        }
        return "Photos \(faites)/\(session.sequence.count) · Note : \(note)"
    }

    private func recommencer(apres resultat: Resultat) {
        switch resultat {
        case .photos:
            chemin = []
            cameraOuverte = true
        case .formulaire:
            chemin = [.formulaire]
        case .noteInfirmiere:
            etat.nouvelleVisite()
            chemin = []
        }
    }
}

/// AJOUTÉ : la liste des patients (factice).
struct ChoixPatient: View {
    @Environment(EtatApp.self) private var etat
    @Environment(\.dismiss) private var fermer

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choisir un patient")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Couleurs.texte)
                .padding(.top, 24)
            ForEach(PatientsFactices.liste, id: \.code) { patient in
                Button {
                    etat.patient = patient
                    fermer()
                } label: {
                    Carte {
                        HStack {
                            Text("\(patient.code) · \(patient.lit)")
                                .font(.system(size: 17))
                                .foregroundStyle(Couleurs.texte)
                            Spacer()
                            if patient == etat.patient {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Couleurs.bleu)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .background(Couleurs.fond)
    }
}
