import Core
import OutilsDeTest
import Testing

@Suite("Étape 4 · Note vocale")
struct Etape4NoteVocaleTests {
    @Test("[4.2.1-6] la note est gardée mot pour mot")
    func noteMotPourMot() async throws {
        let dictee = "Patiente éveillée, orientée ×3. Douleur 2/10 au repos, pansement sec."
        var session = Exemples.session(Exemples.modulesFactices(transcription: FauxTranscription(texte: dictee)))

        try await session.enregistrerNote(Exemples.audio)

        #expect(session.dossier.noteVocale == dictee)
    }

    @Test("[4.2.1-5] un audio vide donne une erreur claire")
    func audioVide() async {
        let session = Exemples.session()

        await #expect(throws: ErreurTranscription.audioVide) {
            var copie = session
            try await copie.enregistrerNote(Exemples.audioVide)
        }
    }

    @Test("[4.2.1-10] la note est attachée au bon patient")
    func noteDuBonPatient() async throws {
        var session = SessionDeCapture(patient: PatientsFactices.liste[2], modules: Exemples.modulesFactices())

        try await session.enregistrerNote(Exemples.audio)

        #expect(session.dossier.patient.code == "P-003")
        #expect(session.dossier.noteVocale == Exemples.note)
    }

}
