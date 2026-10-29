import Foundation

/// Une valeur clinique accompagnée de sa provenance.
///
/// Règle non négociable du projet : **aucune valeur ne se finalise toute seule.**
/// L'app est un assistant de documentation, pas un outil de diagnostic. Le type
/// porte cette règle plutôt qu'un `if` quelque part : `requiresReview` vaut `true`
/// par défaut, et seul un geste explicite du clinicien peut le faire passer à `false`.
///
/// Ne jamais remplacer ce type par un `Int` nu « pour aller plus vite » : une valeur
/// sans provenance n'est pas défendable devant le client ni dans le rapport de tests.
public struct CapturedObservation<Value: Sendable & Equatable & Codable>: Sendable, Equatable, Codable {
    public var value: Value?
    public var unit: String?
    /// Confiance retournée par l'OCR ou la reconnaissance vocale, entre 0 et 1.
    /// `nil` quand la valeur a été saisie à la main.
    public var confidence: Double?
    public var requiresReview: Bool
    public var wasEditedByClinician: Bool

    public init(
        value: Value? = nil,
        unit: String? = nil,
        confidence: Double? = nil,
        requiresReview: Bool = true,
        wasEditedByClinician: Bool = false
    ) {
        self.value = value
        self.unit = unit
        self.confidence = confidence
        self.requiresReview = requiresReview
        self.wasEditedByClinician = wasEditedByClinician
    }
}
