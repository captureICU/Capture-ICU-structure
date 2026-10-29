import Foundation

/// Les signes vitaux lus sur un moniteur de chevet.
///
/// SQUELETTE — la liste des champs est provisoire. Elle sera fixée par le
/// document de spécifications (livrable 1). Tout ajout ou retrait de champ ici
/// se répercute sur `ExpectedVitals.allowedFields` dans les tests et sur les
/// fichiers `expected.json` du corpus : les trois doivent bouger dans la même PR.
public struct VitalSigns: Sendable, Equatable, Codable {
    public var heartRate: CapturedObservation<Int>
    public var systolicBP: CapturedObservation<Int>
    public var diastolicBP: CapturedObservation<Int>
    public var meanArterialPressure: CapturedObservation<Int>
    public var oxygenSaturation: CapturedObservation<Int>
    public var respiratoryRate: CapturedObservation<Int>
    public var temperatureCelsius: CapturedObservation<Double>

    public init(
        heartRate: CapturedObservation<Int> = .init(unit: "bpm"),
        systolicBP: CapturedObservation<Int> = .init(unit: "mmHg"),
        diastolicBP: CapturedObservation<Int> = .init(unit: "mmHg"),
        meanArterialPressure: CapturedObservation<Int> = .init(unit: "mmHg"),
        oxygenSaturation: CapturedObservation<Int> = .init(unit: "%"),
        respiratoryRate: CapturedObservation<Int> = .init(unit: "/min"),
        temperatureCelsius: CapturedObservation<Double> = .init(unit: "°C")
    ) {
        self.heartRate = heartRate
        self.systolicBP = systolicBP
        self.diastolicBP = diastolicBP
        self.meanArterialPressure = meanArterialPressure
        self.oxygenSaturation = oxygenSaturation
        self.respiratoryRate = respiratoryRate
        self.temperatureCelsius = temperatureCelsius
    }
}
