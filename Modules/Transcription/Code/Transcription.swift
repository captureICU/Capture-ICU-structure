import Core
import Foundation

// ════════════════════════════════════════════════════════════════════════
//  MODULE 2 · TRANSCRIPTION — C'EST ICI QUE VOUS CODEZ.
//
//  Votre travail : recevoir l'audio de la note dictée, rendre le texte.
//  Mode d'emploi : Modules/Transcription/LISEZ-MOI.md
//  Vos tests    : Modules/Transcription/Tests/TranscriptionTests.swift
//  Les lancer   : bash scripts/tester.sh transcription
// ════════════════════════════════════════════════════════════════════════

/// Le module de transcription branché dans l'app.
///
/// VERSION DE DÉPART : n'écoute pas encore l'audio. Rend toujours la même note
/// inventée, pour que tout le parcours fonctionne dès aujourd'hui.
/// Votre travail est de remplacer `noteFactice` par une vraie transcription.
public struct Transcription: PriseTranscription {
    public init() {}

    public func transcrire(_ audio: Audio) async throws -> String {
        // Promesse 1 de la prise : audio vide → erreur. Gardez cette ligne.
        guard !audio.donnees.isEmpty else { throw ErreurTranscription.audioVide }

        // À REMPLACER : transcrire vraiment l'audio.
        return Self.noteFactice
    }

    static let noteFactice = "Patiente éveillée et orientée. Respiration régulière. Pansement sec."
}
