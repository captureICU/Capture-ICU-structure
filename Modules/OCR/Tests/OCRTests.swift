import Core
import ModuleOCR
import OutilsDeTest
import Testing

// Les tests du module OCR. Lancer : bash scripts/tester.sh ocr
//
// Un test se lit en trois temps :
//   1. préparer   ce qu'il faut (une photo, un appareil)
//   2. agir       appeler le module
//   3. vérifier   avec #expect : « je m'attends à ce que… »
//
// Le titre commence par le numéro de l'exigence de la spécification entre
// crochets, par exemple [4.2.1-2]. C'est ce qui remplit la matrice de traçabilité.

@Suite("Module OCR")
struct OCRTests {
    // Ce test doit TOUJOURS passer. S'il échoue, votre module ne se branche
    // plus correctement sur le Core : lisez le message, il dit quelle promesse
    // n'est pas tenue.
    @Test("[4.2.1-4] le module OCR respecte sa prise")
    func respecteLaPrise() async {
        let problemes = await VerifierPrise.ocr(OCR())

        #expect(problemes.isEmpty, "\(problemes)")
    }

    @Test("[4.2.1-2] le moniteur donne une fréquence cardiaque")
    func moniteurDonneUneFrequence() async throws {
        // 1. préparer
        let photo = Exemples.photo

        // 2. agir
        let mesures = try await OCR().lire(photo, appareil: .moniteur)

        // 3. vérifier
        #expect(mesures.contains(where: { $0.parametre == .frequenceCardiaque }))
    }

    @Test("[4.2.1-4] une pompe ne donne que son débit")
    func pompeDonneSonDebit() async throws {
        let mesures = try await OCR().lire(Exemples.photo, appareil: .pompe)

        #expect(mesures.map(\.parametre) == [.debitPompe])
    }

    // ── VOTRE PROCHAIN TEST ──────────────────────────────────────────────
    // Copiez ce modèle, enlevez les //, changez le titre et le contenu.
    // Lancez-le : il doit d'abord ÉCHOUER (votre code n'existe pas encore),
    // puis passer une fois votre code écrit.
    //
    // @Test("[4.2.1-3] lit la saturation étiquetée SpO2")
    // func litLaSaturation() async throws {
    //     let photo = ... // une photo de test, jamais une photo de patient
    //     let mesures = try await OCR().lire(photo, appareil: .moniteur)
    //     let saturation = try #require(mesures.first(where: { $0.parametre == .saturation }))
    //     #expect(saturation.valeur == 96)
    // }
}
