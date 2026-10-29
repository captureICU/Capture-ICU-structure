import Foundation

// CONTRAT — reconnaissance de caractères (OCR)
//
// Un contrat dit trois choses : ce qui entre, ce qui sort, et ce qui arrive en
// cas d'échec. Tant qu'une implémentation le respecte, l'équipe OCR peut tout
// changer à l'intérieur (Vision, autre moteur, réglages) sans casser le reste.
//
// Implémentation réelle : App/ (framework Vision d'Apple).
// Bouchon pour les tests : `FakeTextRecognizer` dans CoreTestKit.
// Vérification du contrat : `TextRecognizerContract.check(...)` dans CoreTestKit.
//
// Modifier ce fichier = modifier le contrat de tout le monde. Voir
// docs/SOUS-SYSTEMES.md, section « Changer un contrat ».

/// Une image à lire, sous forme d'octets (JPEG ou PNG).
///
/// Des octets plutôt qu'un `UIImage` : le noyau ne connaît aucun type d'interface,
/// ce qui le garde testable sous Linux.
public struct CapturedImage: Sendable, Equatable {
    public let data: Data

    public init(data: Data) {
        self.data = data
    }
}

/// Les seules erreurs qu'un `TextRecognizer` a le droit de lancer.
public enum TextRecognitionError: Error, Sendable, Equatable {
    /// L'image ne contient aucun octet. Doit être lancée AVANT tout appel au moteur.
    case emptyImage
    /// Les octets ne forment pas une image lisible.
    case unreadableImage
    /// Le moteur n'est pas disponible sur cet appareil.
    case unavailable
}

/// Lit le texte d'une image.
///
/// Promesses, vérifiées par `TextRecognizerContract` :
/// 1. Image vide → lance `TextRecognitionError.emptyImage`.
/// 2. Chaque bloc renvoyé a un texte non vide et une confiance entre 0 et 1.
/// 3. Chaque `boundingBox`, si présente, tient dans le carré 0…1.
/// 4. Répond dans le budget de temps (EX-102 : 3 s par défaut).
///
/// L'OCR ne fait QUE lire. Il n'interprète rien : « FC 90 » reste un bloc de
/// texte. C'est `MonitorExtractor` qui en tire une fréquence cardiaque.
public protocol TextRecognizer: Sendable {
    func recognizeText(in image: CapturedImage) async throws -> [OCRTextBlock]
}
