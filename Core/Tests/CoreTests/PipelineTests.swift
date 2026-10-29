import Core
import CoreTestKit
import Testing

// Tests d'intégration avec bouchons : l'enchaînement complet, sans iPhone.
//
// Le bouchon OCR « lit » ce qu'on lui dit, puis le vrai extracteur et le vrai
// validateur font leur travail. Chaque équipe peut ainsi vérifier que sa pièce
// s'emboîte avec les autres, sous Linux, en quelques secondes.

@Suite("Pipelines — les sous-systèmes s'emboîtent")
struct PipelineTests {
    @Test("EX-001 : une photo de moniteur donne une fréquence cardiaque à réviser")
    func monitorPhotoYieldsHeartRateToReview() async throws {
        let pipeline = MonitorCapturePipeline(recognizer: FakeTextRecognizer(lines: ["IntelliVue MX800", "FC 90"]))

        let result = try await pipeline.run(SampleInputs.image)

        #expect(result.vitals.heartRate.value == 90)
        #expect(result.vitals.heartRate.requiresReview)
        #expect(result.issues.isEmpty)
    }

    @Test("EX-005 : une valeur aberrante lue sur la photo est signalée")
    func implausiblePhotoValueIsFlagged() async throws {
        let pipeline = MonitorCapturePipeline(recognizer: FakeTextRecognizer(lines: ["FC 300"]))

        let result = try await pipeline.run(SampleInputs.image)

        #expect(result.issues == [.heartRateOutOfRange(300)])
    }

    @Test("Une erreur de l'OCR remonte telle quelle, sans valeur inventée")
    func recognizerFailurePropagates() async {
        let pipeline = MonitorCapturePipeline(
            recognizer: FakeTextRecognizer(blocks: [], failure: .unreadableImage)
        )

        await #expect(throws: TextRecognitionError.unreadableImage) {
            try await pipeline.run(SampleInputs.image)
        }
    }

    @Test("EX-006 : une dictée donne une fréquence cardiaque avec la confiance de la transcription")
    func dictationYieldsHeartRateWithTranscriptConfidence() async throws {
        let pipeline = DictationCapturePipeline(transcriber: FakeSpeechTranscriber(text: "FC 90", confidence: 0.85))

        let result = try await pipeline.run(SampleInputs.audio)

        #expect(result.vitals.heartRate.value == 90)
        #expect(result.vitals.heartRate.confidence == 0.85)
        #expect(result.vitals.heartRate.requiresReview)
    }

    @Test("Un refus d'accès au micro remonte tel quel")
    func permissionDeniedPropagates() async {
        let pipeline = DictationCapturePipeline(
            transcriber: FakeSpeechTranscriber(transcript: Transcript(text: "", confidence: 0), failure: .permissionDenied)
        )

        await #expect(throws: SpeechTranscriptionError.permissionDenied) {
            try await pipeline.run(SampleInputs.audio)
        }
    }
}
