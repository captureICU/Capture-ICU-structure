import Foundation

// C'est ici que les sous-systèmes se branchent ensemble.
//
// Un pipeline ne connaît que des contrats (protocoles), jamais une
// implémentation. L'app lui passe les vrais services Apple; les tests lui
// passent des bouchons. Le même code tourne dans les deux cas : c'est ce qui
// permet de tester l'enchaînement complet sous Linux, sans iPhone.

/// Ce qu'une capture produit : des valeurs à réviser et les anomalies à signaler.
public struct CaptureResult: Sendable, Equatable {
    public let vitals: VitalSigns
    public let issues: [ValidationIssue]
}

/// Photo de moniteur → OCR → extraction → validation.
public struct MonitorCapturePipeline: Sendable {
    private let recognizer: any TextRecognizer
    private let extractor: MonitorExtractor
    private let validator: VitalSignValidator

    public init(
        recognizer: any TextRecognizer,
        extractor: MonitorExtractor = MonitorExtractor(),
        validator: VitalSignValidator = VitalSignValidator()
    ) {
        self.recognizer = recognizer
        self.extractor = extractor
        self.validator = validator
    }

    public func run(_ image: CapturedImage) async throws -> CaptureResult {
        let blocks = try await recognizer.recognizeText(in: image)
        let vitals = extractor.extract(from: blocks)
        return CaptureResult(vitals: vitals, issues: validator.validate(vitals))
    }
}

/// Dictée → transcription → interprétation → validation.
public struct DictationCapturePipeline: Sendable {
    private let transcriber: any SpeechTranscriber
    private let interpreter: any DictationInterpreter
    private let validator: VitalSignValidator

    public init(
        transcriber: any SpeechTranscriber,
        interpreter: any DictationInterpreter = DictationVitalSignsInterpreter(),
        validator: VitalSignValidator = VitalSignValidator()
    ) {
        self.transcriber = transcriber
        self.interpreter = interpreter
        self.validator = validator
    }

    public func run(_ clip: AudioClip) async throws -> CaptureResult {
        let transcript = try await transcriber.transcribe(clip)
        let vitals = interpreter.interpret(transcript)
        return CaptureResult(vitals: vitals, issues: validator.validate(vitals))
    }
}
