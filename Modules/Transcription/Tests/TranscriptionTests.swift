import Core
import ModuleTranscription
import OutilsDeTest
import Testing

// Les tests du module Transcription. Lancer : bash scripts/tester.sh transcription
//
// Un test se lit en trois temps :
//   1. préparer   ce qu'il faut (un audio)
//   2. agir       appeler le module
//   3. vérifier   avec #expect : « je m'attends à ce que… »
//
// Le titre commence par le numéro de l'exigence de la spécification entre
// crochets, par exemple [4.2.1-6]. C'est ce qui remplit la matrice de traçabilité.

@Suite("Module Transcription")
struct TranscriptionTests {
    // Ce test doit TOUJOURS passer. S'il échoue, votre module ne se branche
    // plus correctement sur le Core : lisez le message, il dit quelle promesse
    // n'est pas tenue.
    @Test("[4.2.1-6] le module Transcription respecte sa prise")
    func respecteLaPrise() async {
        let problemes = await VerifierPrise.transcription(Transcription())

        #expect(problemes.isEmpty, "\(problemes)")
    }

    @Test("[4.2.1-6] un audio donne un texte")
    func audioDonneUnTexte() async throws {
        // 1. préparer
        let audio = Exemples.audio

        // 2. agir
        let texte = try await Transcription().transcrire(audio)

        // 3. vérifier
        #expect(!texte.isEmpty)
    }

    // ── VOTRE PROCHAIN TEST ──────────────────────────────────────────────
    // Copiez ce modèle, enlevez les //, changez le titre et le contenu.
    // Lancez-le : il doit d'abord ÉCHOUER, puis passer une fois votre code écrit.
    //
    // Pour tester une vraie transcription, il faut un audio de test : une voix
    // de synthèse ou un membre de l'équipe qui lit une phrase inventée.
    // Jamais l'enregistrement d'un vrai patient.
    //
    // @Test("[7.2-7] les chiffres dictés sont transcrits en chiffres")
    // func chiffresDictes() async throws {
    //     let audio = ... // « Fréquence cardiaque quatre-vingt-huit »
    //     let texte = try await Transcription().transcrire(audio)
    //     #expect(texte.contains("88"))
    // }
}
