import Core
import Foundation

// ════════════════════════════════════════════════════════════════════════
//  MODULE 1 · OCR — C'EST ICI QUE VOUS CODEZ.
//
//  Votre travail : recevoir la photo d'un appareil, rendre les valeurs lues.
//  Mode d'emploi : Modules/OCR/LISEZ-MOI.md
//  Vos tests    : Modules/OCR/Tests/OCRTests.swift
//  Les lancer   : bash scripts/tester.sh ocr
// ════════════════════════════════════════════════════════════════════════

/// Le module OCR branché dans l'app.
///
/// VERSION DE DÉPART : ne lit pas encore la photo. Rend toujours les mêmes
/// valeurs inventées, pour que tout le parcours fonctionne dès aujourd'hui.
/// Votre travail est de remplacer `valeursFactices` par une vraie lecture.
public struct OCR: PriseOCR {
    public init() {}

    public func lire(_ photo: Photo, appareil: Appareil) async throws -> [Mesure] {
        // Promesse 1 de la prise : photo vide → erreur. Gardez cette ligne.
        guard !photo.donnees.isEmpty else { throw ErreurOCR.photoVide }

        // À REMPLACER : lire vraiment la photo.
        return Self.valeursFactices(pour: appareil)
    }

    /// Valeurs inventées, dans les plages normales.
    static func valeursFactices(pour appareil: Appareil) -> [Mesure] {
        switch appareil {
        case .moniteur:
            return [
                Mesure(.frequenceCardiaque, valeur: 88, confiance: 0.95),
                Mesure(.tensionSystolique, valeur: 118, confiance: 0.95),
                Mesure(.tensionDiastolique, valeur: 72, confiance: 0.95),
                Mesure(.tensionMoyenne, valeur: 87, confiance: 0.95),
                Mesure(.saturation, valeur: 97, confiance: 0.95),
                Mesure(.frequenceRespiratoire, valeur: 16, confiance: 0.95),
                Mesure(.temperature, valeur: 36.8, confiance: 0.95),
            ]
        case .pompe:
            return [Mesure(.debitPompe, valeur: 5, confiance: 0.95)]
        case .ventilateur:
            return [
                Mesure(.fio2, valeur: 40, confiance: 0.95),
                Mesure(.peep, valeur: 8, confiance: 0.95),
            ]
        }
    }
}
