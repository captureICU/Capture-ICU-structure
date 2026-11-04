import Core
import ModuleExport
import ModuleOCR
import ModuleTranscription
import Observation
import SwiftUI

// Le point d'entrée de l'app iPhone.
//
// C'est ici, et seulement ici, qu'on choisit les modules branchés sur le Core.
// Quand une équipe livre son vrai module, rien d'autre ne change dans l'app.

extension Modules {
    static let application = Modules(
        ocr: OCR(),
        transcription: Transcription(),
        export: ExportNoteInfirmiere())
}

/// Les deux rôles du Figma.
enum Role: String, CaseIterable {
    case m
    case inf

    /// « M » ou « INF ».
    var nom: String { rawValue.uppercased() }
}

/// Un formulaire du rôle M. DÉMO : gardé en mémoire seulement, aucune note
/// médicale n'est encore produite (reportée par la spécification).
struct FormulaireDemo: Identifiable {
    let id = UUID()
    let information: String
    let nombreEnregistrements: Int
    let creeLe: Date
}

/// Tout ce que l'app retient pendant qu'elle est ouverte. Rien n'est écrit sur le
/// téléphone : fermer l'app efface tout (spécification 3.1).
@Observable
final class EtatApp {
    enum Ecran {
        case connexion
        case roles
        case accueil
    }

    var ecran: Ecran = .connexion
    var utilisateur: Utilisateur?
    var role: Role = .inf
    var modeDemo = false

    /// Le patient en cours (rôle INF). Une session de capture par patient.
    var patient: Patient = PatientsFactices.liste[0]
    private var sessions: [String: SessionDeCapture] = [:]

    var formulairesM: [FormulaireDemo] = []

    /// La session du patient en cours, créée au premier besoin.
    var session: SessionDeCapture {
        get { sessions[patient.code] ?? SessionDeCapture(patient: patient, modules: .application) }
        set { sessions[patient.code] = newValue }
    }

    func entrerEnDemo() {
        utilisateur = Utilisateur(identifiant: "demo")
        modeDemo = true
        ecran = .roles
    }

    func choisirRole(_ role: Role) {
        self.role = role
        ecran = .accueil
    }

    /// Quitte la démo ou se déconnecte : on oublie tout.
    func deconnecter() {
        utilisateur = nil
        modeDemo = false
        sessions = [:]
        formulairesM = []
        patient = PatientsFactices.liste[0]
        ecran = .connexion
    }

    /// Recommence la visite du patient en cours (après l'envoi de sa note).
    func nouvelleVisite() {
        sessions[patient.code] = nil
    }
}

@main
struct CaptureICUApp: App {
    @State private var etat = EtatApp()

    var body: some Scene {
        WindowGroup {
            Group {
                switch etat.ecran {
                case .connexion:
                    EcranConnexion()
                case .roles:
                    EcranChoixRole()
                case .accueil:
                    if etat.role == .inf {
                        EcranAccueilINF()
                    } else {
                        EcranAccueilM()
                    }
                }
            }
            .environment(etat)
            .preferredColorScheme(.light)
        }
    }
}
