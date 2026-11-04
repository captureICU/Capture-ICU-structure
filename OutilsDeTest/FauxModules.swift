import Core
import Foundation

// FAUX MODULES — pour tester une pièce sans attendre les autres.
//
// Ils respectent les prises (vérifié dans Core/Tests/PrisesTests.swift), donc un
// test qui passe avec un faux module reste vrai avec le vrai.
//
// Réservés aux TESTS. Jamais dans l'app livrée.

/// Rend toujours les mêmes valeurs, sans regarder la photo.
public struct FauxOCR: PriseOCR {
    public var mesuresParAppareil: [Appareil: [Mesure]]

    /// Par défaut : des valeurs normales, toutes lues avec certitude.
    /// Pour un test, passez vos propres valeurs, par exemple une FC à 300.
    public init(_ mesuresParAppareil: [Appareil: [Mesure]] = FauxOCR.valeursNormales) {
        self.mesuresParAppareil = mesuresParAppareil
    }

    public func lire(_ photo: Photo, appareil: Appareil) async throws -> [Mesure] {
        guard !photo.donnees.isEmpty else { throw ErreurOCR.photoVide }
        return mesuresParAppareil[appareil] ?? []
    }

    /// Valeurs inventées, dans les plages plausibles, confiance 0,95.
    public static let valeursNormales: [Appareil: [Mesure]] = [
        .moniteur: [
            Mesure(.frequenceCardiaque, valeur: 88, confiance: 0.95),
            Mesure(.tensionSystolique, valeur: 118, confiance: 0.95),
            Mesure(.tensionDiastolique, valeur: 72, confiance: 0.95),
            Mesure(.tensionMoyenne, valeur: 87, confiance: 0.95),
            Mesure(.saturation, valeur: 97, confiance: 0.95),
            Mesure(.frequenceRespiratoire, valeur: 16, confiance: 0.95),
            Mesure(.temperature, valeur: 36.8, confiance: 0.95),
        ],
        .pompe: [
            Mesure(.debitPompe, valeur: 5, confiance: 0.95),
        ],
        .ventilateur: [
            Mesure(.fio2, valeur: 40, confiance: 0.95),
            Mesure(.peep, valeur: 8, confiance: 0.95),
        ],
    ]
}

/// Rend toujours le même texte, sans écouter l'audio.
public struct FauxTranscription: PriseTranscription {
    public var texte: String

    public init(texte: String = Exemples.note) {
        self.texte = texte
    }

    public func transcrire(_ audio: Audio) async throws -> String {
        guard !audio.donnees.isEmpty else { throw ErreurTranscription.audioVide }
        return texte
    }
}

/// Écrit le dossier en texte simple, une ligne par valeur.
public struct FauxExport: PriseExport {
    public init() {}

    public func exporter(_ dossier: Dossier) throws -> DocumentExporte {
        guard dossier.estValide else { throw ErreurExport.dossierNonValide }
        var lignes = ["Patient \(dossier.patient.code)"]
        for lecture in dossier.lectures {
            lignes.append(lecture.etape.titre)
            lignes += lecture.mesures.map(\.enTexte)
        }
        lignes.append(dossier.noteVocale ?? "")
        let texte = lignes.joined(separator: "\n")
        return DocumentExporte(
            nomFichier: "faux-\(dossier.patient.code).txt",
            typeMIME: "text/plain",
            contenu: Data(texte.utf8))
    }
}
