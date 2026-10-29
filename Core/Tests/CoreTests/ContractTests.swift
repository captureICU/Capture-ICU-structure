import Core
import CoreTestKit
import Foundation
import Testing

// Tests de contrat : chaque implémentation tient-elle les promesses de
// Core/Contrats/ ?
//
// Ici on vérifie les bouchons et les implémentations du noyau. Les vrais
// services Apple passent EXACTEMENT les mêmes vérifications dans les tests de
// l'app (voir App/LISEZ-MOI.md). Si les deux passent, un test écrit avec un
// bouchon reste vrai avec le vrai service.

@Suite("Contrats — les implémentations tiennent leurs promesses")
struct ContractTests {
    @Test("EX-102 : le bouchon OCR respecte le contrat de reconnaissance de caractères")
    func fakeTextRecognizerHonoursContract() async {
        let violations = await TextRecognizerContract.check(
            FakeTextRecognizer(lines: ["FC 90", "SpO2 96"]),
            sample: SampleInputs.image
        )

        #expect(violations.isEmpty, "\(violations)")
    }

    @Test("Le bouchon de parole respecte le contrat de transcription")
    func fakeSpeechTranscriberHonoursContract() async {
        let violations = await SpeechTranscriberContract.check(
            FakeSpeechTranscriber(text: "FC 90"),
            sample: SampleInputs.audio
        )

        #expect(violations.isEmpty, "\(violations)")
    }

    @Test("EX-004 : l'interprète de dictée respecte le contrat")
    func dictationInterpreterHonoursContract() {
        let violations = DictationInterpreterContract.check(
            DictationVitalSignsInterpreter(),
            samples: [
                Transcript(text: "FC 90", confidence: 0.9),
                Transcript(text: "HR 120", confidence: 1.4), // confiance hors bornes : doit être ramenée à 1
            ]
        )

        #expect(violations.isEmpty, "\(violations)")
    }

    @Test("EX-007 : l'export JSON respecte le contrat de compatibilité des données")
    func jsonCodecHonoursContract() {
        let violations = RecordCodecContract.check(JSONRecordCodec())

        #expect(violations.isEmpty, "\(violations)")
    }
}

// Les vérifications de contrat sont elles-mêmes du code, donc elles peuvent
// être fausses. Une vérification qui ne voit jamais rien est pire que pas de
// vérification : elle rassure. On lui donne donc de MAUVAISES implémentations,
// et elle doit les attraper. C'est la version « voir le rouge » de docs/TESTS.md.

@Suite("Contrats — les vérifications attrapent une mauvaise implémentation")
struct ContractChecksCatchBadImplementations {
    /// Accepte l'image vide, renvoie une confiance de 1,5 et une boîte qui déborde.
    struct BrokenRecognizer: TextRecognizer {
        func recognizeText(in image: CapturedImage) async throws -> [OCRTextBlock] {
            [OCRTextBlock(text: "FC 90", confidence: 1.5, boundingBox: NormalizedRect(x: 0.8, y: 0, width: 0.5, height: 0.1))]
        }
    }

    @Test("Un OCR qui ne respecte pas le contrat est signalé")
    func brokenRecognizerIsCaught() async {
        let violations = await TextRecognizerContract.check(BrokenRecognizer(), sample: SampleInputs.image)
        let rules = Set(violations.map(\.rule))

        #expect(rules == ["image vide", "confiance 0…1", "boîte 0…1"], "\(violations)")
    }

    @Test("Un OCR trop lent est signalé")
    func slowRecognizerIsCaught() async {
        let slow = FakeTextRecognizer(blocks: [OCRTextBlock(text: "FC 90", confidence: 0.9)], delay: .milliseconds(200))

        let violations = await TextRecognizerContract.check(slow, sample: SampleInputs.image, latencyBudget: .milliseconds(50))

        #expect(violations.map(\.rule) == ["temps de réponse"], "\(violations)")
    }

    /// Finalise ses valeurs toute seule : exactement ce que EX-004 interdit.
    struct AutoFinalisingInterpreter: DictationInterpreter {
        func interpret(_ transcript: Transcript) -> VitalSigns {
            var vitals = VitalSigns()
            vitals.heartRate = CapturedObservation(value: 90, requiresReview: false)
            return vitals
        }
    }

    @Test("EX-004 : un interprète qui finalise sans révision est signalé")
    func autoFinalisingInterpreterIsCaught() {
        let violations = DictationInterpreterContract.check(
            AutoFinalisingInterpreter(),
            samples: [Transcript(text: "FC 90", confidence: 0.9)]
        )
        let rules = Set(violations.map(\.rule))

        #expect(rules == ["transcription vide", "EX-004 révision"], "\(violations)")
    }

    /// Lit n'importe quelle version sans se plaindre.
    struct VersionBlindCodec: RecordCodec {
        func encode(_ record: CaptureRecord) throws -> Data { try JSONRecordCodec().encode(record) }
        func decode(_ data: Data) throws -> CaptureRecord {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(CaptureRecord.self, from: data)
        }
    }

    @Test("EX-007 : un format qui accepte une version future est signalé")
    func versionBlindCodecIsCaught() {
        let violations = RecordCodecContract.check(VersionBlindCodec())

        #expect(violations.map(\.rule) == ["version future"], "\(violations)")
    }
}
