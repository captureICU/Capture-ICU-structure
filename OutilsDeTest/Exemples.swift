import Core
import Foundation

/// Des entrées toutes prêtes, pour ne pas les fabriquer dans chaque test.
/// Tout est inventé : aucune donnée patient, jamais.
public enum Exemples {
    /// Pas une vraie image : un faux module ne lit pas les octets, il vérifie
    /// seulement qu'il y en a.
    public static let photo = Photo(donnees: Data([0xFF, 0xD8, 0xFF]))
    public static let photoVide = Photo(donnees: Data())

    public static let audio = Audio(donnees: Data([0x00, 0x01, 0x02]), dureeSecondes: 3)
    public static let audioVide = Audio(donnees: Data(), dureeSecondes: 0)

    public static let patient = PatientsFactices.liste[0]
    public static let infirmiere = Utilisateur(identifiant: "demo")

    /// 2026-11-04 à 15 h 00, heure de Montréal. Une date fixe rend les tests répétables.
    public static let date = Date(timeIntervalSince1970: 1_793_822_400)

    public static let note = "Patiente éveillée et orientée. Respiration régulière. Pansement sec."

    /// Les trois faux modules. Remplacez-en un pour un test précis :
    /// `Exemples.modulesFactices(ocr: FauxOCR([.moniteur: [...]]))`.
    public static func modulesFactices(
        ocr: FauxOCR = FauxOCR(),
        transcription: FauxTranscription = FauxTranscription(),
        export: FauxExport = FauxExport()
    ) -> Modules {
        Modules(ocr: ocr, transcription: transcription, export: export)
    }

    /// Une session neuve pour P-001, avec les faux modules.
    public static func session(_ modules: Modules = modulesFactices()) -> SessionDeCapture {
        SessionDeCapture(patient: patient, modules: modules, date: date)
    }

    /// Une session où toutes les photos sont prises et la note est dictée,
    /// prête à être validée.
    public static func sessionComplete(_ modules: Modules = modulesFactices()) async throws -> SessionDeCapture {
        var resultat = session(modules)
        while resultat.etapeCourante != nil {
            try await resultat.capturerPhoto(photo)
        }
        try await resultat.enregistrerNote(audio)
        return resultat
    }

    /// Un dossier validé, tel que le module Export le reçoit.
    public static var dossierValide: Dossier {
        Dossier(
            patient: patient,
            creeLe: date,
            lectures: [
                Lecture(etape: EtapeDeCapture(.moniteur), mesures: FauxOCR.valeursNormales[.moniteur] ?? []),
                Lecture(etape: EtapeDeCapture(.pompe, numero: 1), mesures: FauxOCR.valeursNormales[.pompe] ?? []),
            ],
            noteVocale: note,
            validePar: infirmiere.identifiant)
    }

    /// Le même dossier, pas encore validé.
    public static var dossierNonValide: Dossier {
        var dossier = dossierValide
        dossier.validePar = nil
        return dossier
    }
}

extension Data {
    /// Vrai si le texte apparaît dans ces octets (en UTF-8 ou en Latin-1, le
    /// codage du PDF). Sert à vérifier ce que contient un document exporté.
    public func contientTexte(_ texte: String) -> Bool {
        let codages: [String.Encoding] = [.utf8, .isoLatin1]
        for codage in codages {
            if let motif = texte.data(using: codage), !motif.isEmpty, range(of: motif) != nil {
                return true
            }
        }
        return false
    }
}
