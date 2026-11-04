import Core
import OutilsDeTest
import Testing

@Suite("Étape 5 · Validation")
struct Etape5ValidationTests {
    @Test("[4.2.1-7] l'infirmière valide un dossier complet")
    func validerUnDossierComplet() async throws {
        var session = try await Exemples.sessionComplete()

        try session.valider(par: Exemples.infirmiere)

        #expect(session.dossier.estValide)
        #expect(session.dossier.validePar == "demo")
    }

    @Test("[8.2-1] la valeur corrigée par l'infirmière est celle qui est gardée")
    func correctionGardee() async throws {
        let ocr = FauxOCR([.moniteur: [Mesure(.frequenceCardiaque, valeur: 300, confiance: 0.95)]])
        var session = try await Exemples.sessionComplete(Exemples.modulesFactices(ocr: ocr))

        try session.corriger(.frequenceCardiaque, a: EtapeDeCapture(.moniteur), valeur: 92)
        try session.valider(par: Exemples.infirmiere)

        let frequence = try #require(session.dossier.lectures.first?.mesures.first)
        #expect(frequence.valeur == 92)
        #expect(frequence.corrigeeParInfirmiere)
        #expect(session.alertes.isEmpty)
    }

    @Test("[7.2-4] une case vide bloque la validation tant qu'elle n'est pas remplie")
    func caseVideBloque() async throws {
        let ocr = FauxOCR([.moniteur: [Mesure(.saturation, valeur: 97, confiance: 0.5)]])
        let session = try await Exemples.sessionComplete(Exemples.modulesFactices(ocr: ocr))

        #expect(throws: ErreurSession.casesARemplir) {
            var copie = session
            try copie.valider(par: Exemples.infirmiere)
        }

        var corrigee = session
        try corrigee.corriger(.saturation, a: EtapeDeCapture(.moniteur), valeur: 95)
        try corrigee.valider(par: Exemples.infirmiere)
        #expect(corrigee.dossier.estValide)
    }

    @Test("[7.2-5] une valeur hors plage n'empêche pas de valider : elle peut être vraie")
    func horsPlageNEmpechePas() async throws {
        let ocr = FauxOCR([.moniteur: [Mesure(.frequenceCardiaque, valeur: 300, confiance: 0.95)]])
        var session = try await Exemples.sessionComplete(Exemples.modulesFactices(ocr: ocr))

        try session.valider(par: Exemples.infirmiere)

        #expect(session.dossier.estValide)
        #expect(session.alertes.count == 1)
    }

    @Test("La validation exige que chaque photo soit prise ou sautée")
    func photosManquantes() {
        let session = Exemples.session()

        #expect(throws: ErreurSession.photosManquantes) {
            var copie = session
            try copie.valider(par: Exemples.infirmiere)
        }
    }

    @Test("On ne peut pas corriger un paramètre qui n'existe pas sur l'appareil")
    func corrigerUnParametreAbsent() async throws {
        let session = try await Exemples.sessionComplete()

        #expect(throws: ErreurSession.mesureIntrouvable) {
            var copie = session
            try copie.corriger(.peep, a: EtapeDeCapture(.moniteur), valeur: 5)
        }
    }

    @Test("Un dossier validé ne se modifie plus")
    func dossierValideFige() async throws {
        var session = try await Exemples.sessionComplete()
        try session.valider(par: Exemples.infirmiere)

        #expect(throws: ErreurSession.dejaValide) {
            var copie = session
            try copie.corriger(.frequenceCardiaque, a: EtapeDeCapture(.moniteur), valeur: 70)
        }
        await #expect(throws: ErreurSession.dejaValide) {
            var copie = session
            try await copie.enregistrerNote(Exemples.audio)
        }
    }
}
