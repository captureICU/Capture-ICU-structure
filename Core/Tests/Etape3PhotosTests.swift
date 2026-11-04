import Core
import OutilsDeTest
import Testing

@Suite("Étape 3 · Photos")
struct Etape3PhotosTests {
    @Test("[4.2.1-1] la séquence de départ : moniteur, pompe 1, ventilateur")
    func sequenceDeDepart() {
        let session = Exemples.session()

        #expect(session.sequence.map(\.titre) == ["Moniteur", "Pompe 1", "Ventilateur"])
        #expect(session.etapeCourante == EtapeDeCapture(.moniteur))
    }

    @Test("[4.2.1-4] chaque valeur arrive dans le bon champ")
    func valeurDansLeBonChamp() async throws {
        var session = Exemples.session()

        try await session.capturerPhoto(Exemples.photo)

        let lecture = try #require(session.dossier.lectures.first)
        #expect(lecture.etape == EtapeDeCapture(.moniteur))
        let frequence = try #require(lecture.mesures.first(where: { $0.parametre == .frequenceCardiaque }))
        #expect(frequence.valeur == 88)
        #expect(session.etapeCourante == EtapeDeCapture(.pompe, numero: 1))
    }

    @Test("[7.2-5] une valeur hors plage est signalée")
    func horsPlageSignalee() async throws {
        let ocr = FauxOCR([.moniteur: [Mesure(.frequenceCardiaque, valeur: 300, confiance: 0.95)]])
        var session = Exemples.session(Exemples.modulesFactices(ocr: ocr))

        try await session.capturerPhoto(Exemples.photo)

        #expect(session.alertes == [
            Alerte(etape: EtapeDeCapture(.moniteur), parametre: .frequenceCardiaque, raison: .horsPlage),
        ])
    }

    @Test("[7.2-4] une valeur douteuse laisse la case vide")
    func douteLaisseLaCaseVide() async throws {
        let ocr = FauxOCR([.moniteur: [Mesure(.saturation, valeur: 97, confiance: 0.5)]])
        var session = Exemples.session(Exemples.modulesFactices(ocr: ocr))

        try await session.capturerPhoto(Exemples.photo)

        let saturation = try #require(session.dossier.lectures.first?.mesures.first)
        #expect(saturation.valeur == nil)
        #expect(session.alertes == [
            Alerte(etape: EtapeDeCapture(.moniteur), parametre: .saturation, raison: .caseVide),
        ])
    }

    @Test("[4.2.1-1] on peut ajouter une pompe")
    func ajouterUnePompe() {
        var session = Exemples.session()

        session.ajouterPompe()

        #expect(session.sequence.map(\.titre) == ["Moniteur", "Pompe 1", "Pompe 2", "Ventilateur"])
    }

    @Test("[4.2.1-1] une pompe ajoutée à la fin est demandée tout de suite")
    func pompeAjouteeALaFin() async throws {
        var session = try await Exemples.sessionComplete()
        #expect(session.etapeCourante == nil)

        session.ajouterPompe()

        #expect(session.etapeCourante == EtapeDeCapture(.pompe, numero: 2))
    }

    @Test("[4.2.1-1] on peut sauter un appareil absent")
    func sauterUnAppareil() async throws {
        var session = Exemples.session()

        try await session.capturerPhoto(Exemples.photo) // moniteur
        try await session.capturerPhoto(Exemples.photo) // pompe 1
        session.passerEtape()                            // pas de ventilateur

        #expect(session.etapeCourante == nil)
        #expect(session.dossier.lectures.map(\.etape.titre) == ["Moniteur", "Pompe 1"])
    }

    @Test("[4.2.1-1] revenir en arrière efface la dernière photo")
    func revenirEnArriere() async throws {
        var session = Exemples.session()
        try await session.capturerPhoto(Exemples.photo) // moniteur
        try await session.capturerPhoto(Exemples.photo) // pompe 1

        try session.revenirEnArriere()

        #expect(session.etapeCourante == EtapeDeCapture(.pompe, numero: 1))
        #expect(session.dossier.lectures.map(\.etape.titre) == ["Moniteur"])
    }

    @Test("Revenir en arrière au début ne fait rien")
    func revenirAuDebut() throws {
        var session = Exemples.session()

        try session.revenirEnArriere()

        #expect(session.etapeCourante == EtapeDeCapture(.moniteur))
    }

    @Test("Une photo de trop est refusée")
    func photoDeTrop() async throws {
        var session = SessionDeCapture(
            patient: Exemples.patient,
            modules: Exemples.modulesFactices(),
            sequence: [EtapeDeCapture(.moniteur)])
        try await session.capturerPhoto(Exemples.photo)

        await #expect(throws: ErreurSession.plusDePhotoAPrendre) {
            var copie = session
            try await copie.capturerPhoto(Exemples.photo)
        }
    }

    @Test("Une photo vide donne une erreur claire")
    func photoVide() async {
        let session = Exemples.session()

        await #expect(throws: ErreurOCR.photoVide) {
            var copie = session
            try await copie.capturerPhoto(Exemples.photoVide)
        }
    }
}
