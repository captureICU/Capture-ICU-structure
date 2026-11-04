import Core
import OutilsDeTest
import Testing

@Suite("Étape 6 · Export")
struct Etape6ExportTests {
    @Test("[8.2-1] impossible d'exporter avant la validation")
    func pasDExportAvantValidation() async throws {
        let session = try await Exemples.sessionComplete()

        #expect(throws: ErreurSession.pasEncoreValide) {
            try session.exporter()
        }
    }

    @Test("[4.2.1-8] après validation, le dossier part au module Export")
    func exportApresValidation() async throws {
        var session = try await Exemples.sessionComplete()
        try session.valider(par: Exemples.infirmiere)

        let document = try session.exporter()

        #expect(document.contenu.contientTexte("Patient P-001"))
        #expect(document.contenu.contientTexte("FC : 88 bpm"))
        #expect(document.contenu.contientTexte(Exemples.note))
    }

    @Test("[8.2-1] la valeur corrigée est celle qui est exportée")
    func valeurCorrigeeExportee() async throws {
        let ocr = FauxOCR([.moniteur: [Mesure(.frequenceCardiaque, valeur: 300, confiance: 0.95)]])
        var session = try await Exemples.sessionComplete(Exemples.modulesFactices(ocr: ocr))
        try session.corriger(.frequenceCardiaque, a: EtapeDeCapture(.moniteur), valeur: 92)
        try session.valider(par: Exemples.infirmiere)

        let document = try session.exporter()

        #expect(document.contenu.contientTexte("FC : 92 bpm (corrigée)"))
        #expect(!document.contenu.contientTexte("300"))
    }
}
