import Core
import Foundation

// VÉRIFICATIONS DE CONTRAT — les promesses de Core/Contrats/, en code.
//
// Une seule vérification par contrat, utilisée par TOUTES les implémentations :
// le bouchon (tests du noyau, Linux) et le vrai service Apple (tests de l'app,
// macOS). Si les deux passent la même vérification, le bouchon dit vrai, et
// les tests écrits avec lui restent valables avec le vrai service.
//
// Chaque fonction renvoie la liste des promesses non tenues. Liste vide = contrat
// respecté. Dans un test :
//
//     let violations = await TextRecognizerContract.check(MonOCR(), sample: image)
//     #expect(violations.isEmpty, "\(violations)")
//
// Pas d'`import Testing` ici, volontairement : ce fichier doit compiler partout.

/// Une promesse du contrat qui n'est pas tenue.
public struct ContractViolation: Sendable, Equatable, CustomStringConvertible {
    public let rule: String
    public let detail: String

    public var description: String { "[\(rule)] \(detail)" }
}

private let unitInterval = 0.0 ... 1.0

// MARK: - Reconnaissance de caractères

public enum TextRecognizerContract {
    /// - Parameters:
    ///   - sample: une image qui contient du texte lisible. Pour le vrai OCR, une
    ///     image synthétique générée dans le test (jamais une photo de patient).
    ///   - latencyBudget: EX-102, 3 s par défaut.
    public static func check(
        _ recognizer: some TextRecognizer,
        sample: CapturedImage,
        latencyBudget: Duration = .seconds(3)
    ) async -> [ContractViolation] {
        var violations: [ContractViolation] = []

        do {
            _ = try await recognizer.recognizeText(in: CapturedImage(data: Data()))
            violations.append(.init(rule: "image vide", detail: "aucune erreur lancée, emptyImage attendue"))
        } catch let error as TextRecognitionError where error == .emptyImage {
            // promesse tenue
        } catch {
            violations.append(.init(rule: "image vide", detail: "lance \(error), emptyImage attendue"))
        }

        let clock = ContinuousClock()
        let start = clock.now
        let blocks: [OCRTextBlock]
        do {
            blocks = try await recognizer.recognizeText(in: sample)
        } catch {
            violations.append(.init(rule: "image lisible", detail: "lance \(error) sur l'image d'exemple"))
            return violations
        }
        let elapsed = clock.now - start

        if elapsed > latencyBudget {
            violations.append(.init(rule: "temps de réponse", detail: "\(elapsed), budget \(latencyBudget)"))
        }
        if blocks.isEmpty {
            violations.append(.init(rule: "image lisible", detail: "aucun bloc renvoyé"))
        }

        for (index, block) in blocks.enumerated() {
            if block.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                violations.append(.init(rule: "texte non vide", detail: "bloc \(index) vide"))
            }
            if !unitInterval.contains(block.confidence) {
                violations.append(.init(rule: "confiance 0…1", detail: "bloc \(index) : \(block.confidence)"))
            }
            if let box = block.boundingBox, !isNormalized(box) {
                violations.append(.init(rule: "boîte 0…1", detail: "bloc \(index) : \(box)"))
            }
        }

        return violations
    }

    private static func isNormalized(_ box: NormalizedRect) -> Bool {
        let tolerance = 1e-6
        return box.x >= -tolerance && box.y >= -tolerance
            && box.width >= 0 && box.height >= 0
            && box.x + box.width <= 1 + tolerance
            && box.y + box.height <= 1 + tolerance
    }
}

// MARK: - Reconnaissance de la parole

public enum SpeechTranscriberContract {
    /// - Parameter sample: un enregistrement qui contient de la parole. Pour le
    ///   vrai service, un fichier synthétique (synthèse vocale), jamais un patient.
    public static func check(
        _ transcriber: some SpeechTranscriber,
        sample: AudioClip,
        latencyBudget: Duration = .seconds(3)
    ) async -> [ContractViolation] {
        var violations: [ContractViolation] = []

        do {
            _ = try await transcriber.transcribe(AudioClip(data: Data(), durationSeconds: 0))
            violations.append(.init(rule: "audio vide", detail: "aucune erreur lancée, emptyAudio attendue"))
        } catch let error as SpeechTranscriptionError where error == .emptyAudio {
            // promesse tenue
        } catch {
            violations.append(.init(rule: "audio vide", detail: "lance \(error), emptyAudio attendue"))
        }

        let clock = ContinuousClock()
        let start = clock.now
        let transcript: Transcript
        do {
            transcript = try await transcriber.transcribe(sample)
        } catch {
            violations.append(.init(rule: "audio lisible", detail: "lance \(error) sur l'audio d'exemple"))
            return violations
        }
        let elapsed = clock.now - start

        if elapsed > latencyBudget {
            violations.append(.init(rule: "temps de réponse", detail: "\(elapsed), budget \(latencyBudget)"))
        }
        if transcript.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            violations.append(.init(rule: "texte non vide", detail: "transcription vide"))
        }
        if !unitInterval.contains(transcript.confidence) {
            violations.append(.init(rule: "confiance 0…1", detail: "\(transcript.confidence)"))
        }
        if transcript.localeIdentifier.isEmpty {
            violations.append(.init(rule: "langue nommée", detail: "localeIdentifier vide"))
        }

        return violations
    }
}

// MARK: - Interprétation de la dictée

public enum DictationInterpreterContract {
    /// - Parameter samples: des transcriptions qui contiennent des signes vitaux.
    public static func check(
        _ interpreter: some DictationInterpreter,
        samples: [Transcript]
    ) -> [ContractViolation] {
        var violations: [ContractViolation] = []

        let empty = interpreter.interpret(Transcript(text: "", confidence: 0))
        for field in empty.fieldStates where field.hasValue {
            violations.append(.init(rule: "transcription vide", detail: "\(field.name) a une valeur"))
        }

        for sample in samples {
            let vitals = interpreter.interpret(sample)
            for field in vitals.fieldStates where field.hasValue {
                if !field.requiresReview {
                    violations.append(.init(rule: "EX-004 révision", detail: "« \(sample.text) » : \(field.name) finalisé sans révision"))
                }
                if field.wasEditedByClinician {
                    violations.append(.init(rule: "EX-004 révision", detail: "« \(sample.text) » : \(field.name) marqué modifié par le clinicien"))
                }
                if let confidence = field.confidence, !unitInterval.contains(confidence) {
                    violations.append(.init(rule: "confiance 0…1", detail: "« \(sample.text) » : \(field.name) = \(confidence)"))
                }
            }
        }

        return violations
    }
}

// MARK: - Compatibilité des données

public enum RecordCodecContract {
    public static func check(
        _ codec: some RecordCodec,
        sample: CaptureRecord = SampleInputs.record
    ) -> [ContractViolation] {
        var violations: [ContractViolation] = []

        let encoded: Data
        do {
            encoded = try codec.encode(sample)
        } catch {
            return [.init(rule: "encodage", detail: "lance \(error)")]
        }

        do {
            let decoded = try codec.decode(encoded)
            if decoded != sample {
                violations.append(.init(rule: "aller-retour", detail: "la capture relue diffère de l'originale"))
            }
        } catch {
            violations.append(.init(rule: "aller-retour", detail: "relecture impossible : \(error)"))
        }

        if let again = try? codec.encode(sample), again != encoded {
            violations.append(.init(rule: "déterminisme", detail: "deux encodages de la même capture diffèrent"))
        }

        // Lu indépendamment du codec testé : on regarde le document tel qu'un
        // autre système le verrait.
        let declared = (try? JSONDecoder().decode(VersionProbe.self, from: encoded))?.schemaVersion
        if declared != CaptureRecord.currentSchemaVersion {
            violations.append(.init(rule: "schemaVersion", detail: "absent du premier niveau ou différent de \(CaptureRecord.currentSchemaVersion)"))
        }

        var future = sample
        future.schemaVersion = CaptureRecord.currentSchemaVersion + 1
        if let futureData = try? codec.encode(future) {
            do {
                _ = try codec.decode(futureData)
                violations.append(.init(rule: "version future", detail: "acceptée, unsupportedSchemaVersion attendue"))
            } catch let error as RecordCodecError where error == .unsupportedSchemaVersion(future.schemaVersion) {
                // promesse tenue
            } catch {
                violations.append(.init(rule: "version future", detail: "lance \(error), unsupportedSchemaVersion attendue"))
            }
        }

        if (try? codec.decode(Data("pas du JSON".utf8))) != nil {
            violations.append(.init(rule: "document illisible", detail: "accepté sans erreur"))
        }

        return violations
    }
}

// MARK: - Aide

private struct VersionProbe: Decodable {
    let schemaVersion: Int?
}

/// L'état d'un champ de `VitalSigns`, sans se soucier de son type (Int ou Double).
public struct VitalFieldState: Sendable, Equatable {
    public let name: String
    public let hasValue: Bool
    public let requiresReview: Bool
    public let wasEditedByClinician: Bool
    public let confidence: Double?
}

extension VitalSigns {
    /// Les sept champs, dans l'ordre. Ajouter un champ à `VitalSigns` = l'ajouter ici.
    public var fieldStates: [VitalFieldState] {
        [
            Self.state("heartRate", heartRate),
            Self.state("systolicBP", systolicBP),
            Self.state("diastolicBP", diastolicBP),
            Self.state("meanArterialPressure", meanArterialPressure),
            Self.state("oxygenSaturation", oxygenSaturation),
            Self.state("respiratoryRate", respiratoryRate),
            Self.state("temperatureCelsius", temperatureCelsius),
        ]
    }

    private static func state<V: Sendable & Equatable & Codable>(_ name: String, _ observation: CapturedObservation<V>) -> VitalFieldState {
        VitalFieldState(
            name: name,
            hasValue: observation.value != nil,
            requiresReview: observation.requiresReview,
            wasEditedByClinician: observation.wasEditedByClinician,
            confidence: observation.confidence
        )
    }
}
