import Foundation

/// Un signe vital qui sort des bornes physiologiquement plausibles.
///
/// Signalé, jamais corrigé automatiquement : une valeur aberrante est le plus
/// souvent une erreur d'OCR, mais elle peut être vraie et cliniquement urgente.
/// Trancher est le rôle du clinicien.
public enum ValidationIssue: Sendable, Equatable {
    case heartRateOutOfRange(Int)
    case oxygenSaturationOutOfRange(Int)
}

/// SQUELETTE — deux bornes seulement. Les bornes retenues devront être justifiées
/// dans le document de spécifications et validées par le client (Dr Lamarche),
/// pas choisies par l'équipe.
public struct VitalSignValidator: Sendable {
    public static let plausibleHeartRate = 20 ... 250
    public static let plausibleOxygenSaturation = 50 ... 100

    public init() {}

    /// EX-005 — une valeur hors bornes est signalée.
    /// Un champ absent n'est pas une anomalie : on ne signale que ce qu'on a lu.
    public func validate(_ vitals: VitalSigns) -> [ValidationIssue] {
        var issues: [ValidationIssue] = []

        if let value = vitals.heartRate.value,
           !Self.plausibleHeartRate.contains(value) {
            issues.append(.heartRateOutOfRange(value))
        }

        if let value = vitals.oxygenSaturation.value,
           !Self.plausibleOxygenSaturation.contains(value) {
            issues.append(.oxygenSaturationOutOfRange(value))
        }

        return issues
    }
}
