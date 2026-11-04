import Foundation

// PRISE TRANSCRIPTION — là où le module de transcription se branche sur le Core.
//
// Le module qui se branche ici : Modules/Transcription/Code/Transcription.swift
// La vérification automatique : OutilsDeTest/VerifierLesPrises.swift
//
// Modifier ce fichier = modifier la prise de toute l'équipe. Ouvrir une issue d'abord.

/// Transforme l'enregistrement de la note dictée en texte.
///
/// Promesses (vérifiées par `VerifierPrise.transcription`) :
/// 1. Audio vide → lance `ErreurTranscription.audioVide`.
/// 2. Sur un audio qui contient de la parole, le texte rendu n'est pas vide.
///
/// Le texte est la note de l'infirmière, gardée telle quelle : le module ne
/// la résume pas et n'en tire pas de chiffres.
public protocol PriseTranscription: Sendable {
    func transcrire(_ audio: Audio) async throws -> String
}

/// Les seules erreurs que le module de transcription a le droit de lancer.
public enum ErreurTranscription: Error, Sendable, Equatable {
    /// L'audio ne contient aucun octet.
    case audioVide
    /// L'utilisateur a refusé l'accès au micro ou à la reconnaissance vocale.
    case microRefuse
    /// Le moteur n'est pas disponible (langue non installée, hors ligne…).
    case indisponible
}
