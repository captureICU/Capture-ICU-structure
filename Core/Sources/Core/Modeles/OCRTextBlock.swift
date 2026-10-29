import Foundation

/// Un rectangle en coordonnées normalisées (0 à 1), indépendant de la taille de l'image.
///
/// Type maison plutôt que `CGRect` : `CoreGraphics` n'existe pas sous Linux, et la
/// compilation du noyau sous Linux en intégration continue est ce qui garantit,
/// gratuitement, qu'aucune dépendance Apple ne s'infiltre ici.
public struct NormalizedRect: Sendable, Equatable {
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}

/// Un bloc de texte tel que l'OCR l'a renvoyé, avant toute interprétation.
///
/// C'est la frontière du noyau : le framework Vision d'Apple vit dans l'app et
/// produit ces blocs; le noyau ne connaît que ce type. C'est ce qui rend
/// l'extraction testable sans appareil, sans simulateur et sans photo.
public struct OCRTextBlock: Sendable, Equatable {
    public let text: String
    /// Entre 0 et 1.
    public let confidence: Double
    public let boundingBox: NormalizedRect?

    public init(text: String, confidence: Double, boundingBox: NormalizedRect? = nil) {
        self.text = text
        self.confidence = confidence
        self.boundingBox = boundingBox
    }
}
