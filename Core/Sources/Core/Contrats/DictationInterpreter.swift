import Foundation

// CONTRAT — interprétation de la dictée (texte dicté → signes vitaux)
//
// Implémentation de référence : `DictationVitalSignsInterpreter` (Core/Dictee/).
// Pas de bouchon : c'est du code pur, il tourne partout, on teste le vrai.
// Vérification du contrat : `DictationInterpreterContract.check(...)` dans CoreTestKit.

/// Tire des signes vitaux d'une transcription.
///
/// Promesses, vérifiées par `DictationInterpreterContract` :
/// 1. Transcription vide → aucune valeur.
/// 2. Toute valeur produite exige une révision (`requiresReview == true`) et
///    n'est pas marquée comme modifiée par le clinicien (EX-004).
/// 3. Toute confiance produite est entre 0 et 1.
public protocol DictationInterpreter: Sendable {
    func interpret(_ transcript: Transcript) -> VitalSigns
}
