import Core
import Foundation

// BOUCHONS — de fausses implémentations des contrats, pour les tests.
//
// Avec eux, chaque équipe teste sa pièce sans attendre les autres : l'équipe
// extraction n'a pas besoin de Vision, l'équipe export n'a pas besoin du micro.
// Ils respectent le contrat (vérifié dans ContractTests.swift), donc un test
// qui passe avec un bouchon reste vrai avec le vrai service.
//
// À importer dans les cibles de TESTS seulement, jamais dans l'app livrée.

/// Renvoie toujours les mêmes blocs, sans lire l'image.
public struct FakeTextRecognizer: TextRecognizer {
    public var blocks: [OCRTextBlock]
    public var delay: Duration
    /// Si présent, lancé à chaque appel (pour tester les chemins d'erreur).
    public var failure: TextRecognitionError?

    public init(blocks: [OCRTextBlock], delay: Duration = .zero, failure: TextRecognitionError? = nil) {
        self.blocks = blocks
        self.delay = delay
        self.failure = failure
    }

    /// Raccourci : une ligne de texte = un bloc, confiance 0,95.
    public init(lines: [String], confidence: Double = 0.95) {
        self.init(blocks: lines.map { OCRTextBlock(text: $0, confidence: confidence) })
    }

    public func recognizeText(in image: CapturedImage) async throws -> [OCRTextBlock] {
        guard !image.data.isEmpty else { throw TextRecognitionError.emptyImage }
        if let failure { throw failure }
        if delay > .zero { try await Task.sleep(for: delay) }
        return blocks
    }
}

/// Renvoie toujours la même transcription, sans écouter l'audio.
public struct FakeSpeechTranscriber: SpeechTranscriber {
    public var transcript: Transcript
    public var delay: Duration
    public var failure: SpeechTranscriptionError?

    public init(transcript: Transcript, delay: Duration = .zero, failure: SpeechTranscriptionError? = nil) {
        self.transcript = transcript
        self.delay = delay
        self.failure = failure
    }

    /// Raccourci : le texte « entendu », confiance 0,9, français canadien.
    public init(text: String, confidence: Double = 0.9) {
        self.init(transcript: Transcript(text: text, confidence: confidence))
    }

    public func transcribe(_ clip: AudioClip) async throws -> Transcript {
        guard !clip.data.isEmpty else { throw SpeechTranscriptionError.emptyAudio }
        if let failure { throw failure }
        if delay > .zero { try await Task.sleep(for: delay) }
        return transcript
    }
}

/// Entrées d'exemple, pour ne pas fabriquer des octets dans chaque test.
public enum SampleInputs {
    /// N'est pas une vraie image : un bouchon ne lit pas les octets, il vérifie
    /// seulement qu'il y en a.
    public static let image = CapturedImage(data: Data([0xFF, 0xD8, 0xFF]))
    public static let emptyImage = CapturedImage(data: Data())

    public static let audio = AudioClip(data: Data([0x00, 0x01, 0x02]), durationSeconds: 2)
    public static let emptyAudio = AudioClip(data: Data(), durationSeconds: 0)

    /// Une capture complète, synthétique. Date à la seconde près : l'ISO 8601
    /// ne garde pas les fractions de seconde.
    public static var record: CaptureRecord {
        var vitals = VitalSigns()
        vitals.heartRate = CapturedObservation(value: 90, unit: "bpm", confidence: 0.92)
        vitals.oxygenSaturation = CapturedObservation(value: 96, unit: "%", confidence: 0.88)
        vitals.temperatureCelsius = CapturedObservation(value: 37.1, unit: "°C", confidence: 0.8)
        return CaptureRecord(
            captureCode: "EXEMPLE-01",
            capturedAt: Date(timeIntervalSince1970: 1_793_197_800), // 2026-10-28T14:30:00Z
            source: .monitorPhoto,
            vitals: vitals
        )
    }
}
