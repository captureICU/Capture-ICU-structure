import Core
import ModuleExport
import ModuleOCR
import ModuleTranscription
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

@main
struct CaptureICUApp: App {
    @State private var utilisateur: Utilisateur?

    var body: some Scene {
        WindowGroup {
            if let utilisateur {
                EcranPatients(utilisateur: utilisateur)
            } else {
                EcranConnexion { utilisateur = $0 }
            }
        }
    }
}
