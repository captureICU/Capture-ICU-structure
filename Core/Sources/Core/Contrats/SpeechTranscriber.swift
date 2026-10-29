import Foundation

// CONTRAT — reconnaissance de la parole (audio → texte)
//
// Implémentation réelle : App/ (framework Speech d'Apple).
// Bouchon pour les tests : `FakeSpeechTranscriber` dans CoreTestKit.
// Vérification du contrat : `SpeechTranscriberContract.check(...)` dans CoreTestKit.

/// Un enregistrement audio, sous forme d'octets (par exemple un fichier .m4a lu
/// en mémoire). L'adaptateur réel l'écrit dans un fichier temporaire si le
/// moteur l'exige.
public struct AudioClip: Sendable, Equatable {
    public let data: Data
    public let durationSeconds: Double

    public init(data: Data, durationSeconds: Double) {
        self.data = data
        self.durationSeconds = durationSeconds
    }
}

/// Ce que la reconnaissance de la parole a entendu, avant toute interprétation.
public struct Transcript: Sendable, Equatable {
    public let text: String
    /// Entre 0 et 1.
    public let confidence: Double
    /// Langue reconnue, par exemple « fr-CA ».
    public let localeIdentifier: String

    public init(text: String, confidence: Double, localeIdentifier: String = "fr-CA") {
        self.text = text
        self.confidence = confidence
        self.localeIdentifier = localeIdentifier
    }
}

/// Les seules erreurs qu'un `SpeechTranscriber` a le droit de lancer.
public enum SpeechTranscriptionError: Error, Sendable, Equatable {
    /// L'audio ne contient aucun octet. Doit être lancée AVANT tout appel au moteur.
    case emptyAudio
    /// L'utilisateur a refusé l'accès au micro ou à la reconnaissance vocale.
    case permissionDenied
    /// Le moteur n'est pas disponible (langue non installée, appareil hors ligne…).
    case unavailable
}

/// Transforme un enregistrement en texte.
///
/// Promesses, vérifiées par `SpeechTranscriberContract` :
/// 1. Audio vide → lance `SpeechTranscriptionError.emptyAudio`.
/// 2. Le texte renvoyé n'est pas vide, la confiance est entre 0 et 1, la langue est nommée.
/// 3. Répond dans le budget de temps (3 s par défaut).
///
/// La transcription ne fait QUE transcrire. Tirer des signes vitaux du texte est
/// le travail de `DictationInterpreter`.
public protocol SpeechTranscriber: Sendable {
    func transcribe(_ clip: AudioClip) async throws -> Transcript
}
