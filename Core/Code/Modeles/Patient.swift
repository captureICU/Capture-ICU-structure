import Foundation

/// Un patient, identifié seulement par un code.
///
/// Règle du projet : jamais de nom, jamais de vrai numéro de dossier dans ce dépôt.
public struct Patient: Sendable, Equatable, Hashable, Codable {
    /// Par exemple « P-001 ».
    public let code: String
    /// Par exemple « Lit 1 ».
    public let lit: String

    public init(code: String, lit: String) {
        self.code = code
        self.lit = lit
    }
}

/// FACTICE — la liste de patients du squelette.
/// Plus tard, elle viendra du système de l'hôpital, derrière une connexion sécurisée.
public enum PatientsFactices {
    public static let liste: [Patient] = [
        Patient(code: "P-001", lit: "Lit 1"),
        Patient(code: "P-002", lit: "Lit 2"),
        Patient(code: "P-003", lit: "Lit 3"),
    ]
}
