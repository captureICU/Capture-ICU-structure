import Foundation

/// Implémentation de référence de `DictationInterpreter`.
///
/// SQUELETTE — réutilise les règles de lecture de `MonitorExtractor` (« FC 90 »
/// dicté se lit comme « FC 90 » photographié), puis reporte la confiance de la
/// transcription sur chaque valeur lue. L'équipe dictée remplacera l'intérieur
/// (« fréquence cardiaque quatre-vingt-dix », nombres en lettres, etc.) sans
/// toucher au contrat.
public struct DictationVitalSignsInterpreter: DictationInterpreter {
    private let extractor: MonitorExtractor

    public init(extractor: MonitorExtractor = MonitorExtractor()) {
        self.extractor = extractor
    }

    public func interpret(_ transcript: Transcript) -> VitalSigns {
        var vitals = extractor.extract(from: transcript.text)
        let confidence = min(max(transcript.confidence, 0), 1)

        vitals.heartRate = Self.stamp(vitals.heartRate, confidence)
        vitals.systolicBP = Self.stamp(vitals.systolicBP, confidence)
        vitals.diastolicBP = Self.stamp(vitals.diastolicBP, confidence)
        vitals.meanArterialPressure = Self.stamp(vitals.meanArterialPressure, confidence)
        vitals.oxygenSaturation = Self.stamp(vitals.oxygenSaturation, confidence)
        vitals.respiratoryRate = Self.stamp(vitals.respiratoryRate, confidence)
        vitals.temperatureCelsius = Self.stamp(vitals.temperatureCelsius, confidence)
        return vitals
    }

    /// Une valeur lue porte la confiance de la transcription; une valeur absente n'en porte aucune.
    private static func stamp<V: Sendable & Equatable & Codable>(_ observation: CapturedObservation<V>, _ confidence: Double) -> CapturedObservation<V> {
        guard observation.value != nil else { return observation }
        var stamped = observation
        stamped.confidence = confidence
        stamped.requiresReview = true
        return stamped
    }
}
