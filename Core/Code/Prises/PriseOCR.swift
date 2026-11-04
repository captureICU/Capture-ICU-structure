import Foundation

// PRISE OCR — là où le module OCR se branche sur le Core.
//
// Une prise (en anglais, un « protocol ») dit trois choses :
//   ce qui entre, ce qui sort, et ce qui arrive en cas d'erreur.
// Tant que le module respecte sa prise, il peut tout changer à l'intérieur
// sans rien casser chez les autres.
//
// Le module qui se branche ici : Modules/OCR/Code/OCR.swift
// La vérification automatique : OutilsDeTest/VerifierLesPrises.swift
//
// Modifier ce fichier = modifier la prise de toute l'équipe. Ouvrir une issue d'abord.

/// Lit les valeurs affichées sur la photo d'un appareil.
///
/// Promesses (vérifiées par `VerifierPrise.ocr`) :
/// 1. Photo vide → lance `ErreurOCR.photoVide`.
/// 2. Chaque mesure rendue appartient à l'appareil photographié
///    (pas de FiO2 sur un moniteur).
/// 3. Pas deux fois le même paramètre dans une même lecture.
/// 4. Chaque confiance est entre 0 et 1.
/// 5. Aucune mesure n'est marquée « corrigée par l'infirmière » : seule
///    l'infirmière corrige, jamais l'OCR.
///
/// Si l'OCR n'est pas sûr d'une valeur, il la rend quand même avec une confiance
/// basse. C'est le Core qui décide de vider la case (voir `Verification`).
public protocol PriseOCR: Sendable {
    func lire(_ photo: Photo, appareil: Appareil) async throws -> [Mesure]
}

/// Les seules erreurs que le module OCR a le droit de lancer.
public enum ErreurOCR: Error, Sendable, Equatable {
    /// La photo ne contient aucun octet.
    case photoVide
    /// Les octets ne forment pas une image lisible.
    case photoIllisible
}
