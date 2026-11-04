import Core
import ModuleExport
import ModuleOCR
import ModuleTranscription
import OutilsDeTest
import Testing

// LE TEST QUI PROUVE QUE TOUT S'EMBOÎTE.
//
// Contrairement aux tests du Core, celui-ci branche les VRAIS modules (ceux de
// Modules/), exactement comme l'app. S'il échoue alors que les tests de votre
// module passent, votre module ne s'emboîte plus avec les autres.
//
// Lancer : bash scripts/tester.sh bout-en-bout

@Suite("Bout en bout · le parcours complet de l'infirmière")
struct ParcoursCompletTests {
    @Test("[4.1.1-6] connexion, patient, photos, note, validation, PDF")
    func parcoursComplet() async throws {
        // 1. Connexion
        let infirmiere = try #require(ConnexionFactice().connecter(identifiant: "demo", motDePasse: "demo"))

        // 2. Choix du patient, avec les vrais modules
        let modules = Modules(ocr: OCR(), transcription: Transcription(), export: ExportNoteInfirmiere())
        var session = SessionDeCapture(patient: PatientsFactices.liste[0], modules: modules, date: Exemples.date)

        // 3. Photos : moniteur, pompe 1, ventilateur
        while session.etapeCourante != nil {
            try await session.capturerPhoto(Exemples.photo)
        }
        #expect(session.dossier.lectures.count == 3)

        // 4. Note vocale
        try await session.enregistrerNote(Exemples.audio)
        let note = try #require(session.dossier.noteVocale)

        // 5. Validation
        #expect(session.alertes.isEmpty, "\(session.alertes.map(\.message))")
        try session.valider(par: infirmiere)

        // 6. Export
        let pdf = try session.exporter()
        #expect(pdf.nomFichier == "note-infirmiere-P-001.pdf")
        #expect(pdf.contenu.contientTexte("P-001"))
        #expect(pdf.contenu.contientTexte("FC : 88 bpm"))
        #expect(pdf.contenu.contientTexte("FiO2 : 40 %"))
        #expect(pdf.contenu.contientTexte(note))
    }
}
