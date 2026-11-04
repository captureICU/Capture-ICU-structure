import Core
import OutilsDeTest
import Testing

@Suite("Étape 2 · Choix du patient")
struct Etape2PatientTests {
    @Test("[4.2.1-10] le dossier porte le code du patient choisi")
    func dossierPorteLeCode() {
        let patient = PatientsFactices.liste[1]

        let session = SessionDeCapture(patient: patient, modules: Exemples.modulesFactices())

        #expect(session.dossier.patient.code == "P-002")
    }

    @Test("[4.2.1-10] deux patients donnent deux dossiers distincts")
    func deuxPatientsDeuxDossiers() async throws {
        var premier = SessionDeCapture(
            patient: PatientsFactices.liste[0],
            modules: Exemples.modulesFactices(transcription: FauxTranscription(texte: "Note du patient 1")))
        var second = SessionDeCapture(
            patient: PatientsFactices.liste[1],
            modules: Exemples.modulesFactices(transcription: FauxTranscription(texte: "Note du patient 2")))

        try await premier.enregistrerNote(Exemples.audio)
        try await second.enregistrerNote(Exemples.audio)

        #expect(premier.dossier.noteVocale == "Note du patient 1")
        #expect(second.dossier.noteVocale == "Note du patient 2")
        #expect(premier.dossier.patient != second.dossier.patient)
    }

    @Test("La liste factice ne contient que des codes, jamais de noms")
    func codesSeulement() {
        for patient in PatientsFactices.liste {
            #expect(patient.code.hasPrefix("P-"), "\(patient.code) ne ressemble pas à un code")
        }
    }
}
