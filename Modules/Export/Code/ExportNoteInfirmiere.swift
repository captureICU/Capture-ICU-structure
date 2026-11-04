import Core
import Foundation

// ════════════════════════════════════════════════════════════════════════
//  MODULE 3 · DONNÉES & EXPORT — C'EST ICI QUE VOUS CODEZ.
//
//  Votre travail : organiser le dossier validé et produire la note infirmière.
//  Mode d'emploi : Modules/Export/LISEZ-MOI.md
//  Vos tests    : Modules/Export/Tests/ExportTests.swift
//  Les lancer   : bash scripts/tester.sh export
// ════════════════════════════════════════════════════════════════════════

/// Le module d'export branché dans l'app.
///
/// VERSION DE DÉPART : produit déjà un vrai PDF, mais très simple (une liste de
/// lignes). Votre travail est de le faire ressembler au formulaire ICM211 de
/// l'Institut de Cardiologie (sections Neuro, Respiratoire, Circulation…).
public struct ExportNoteInfirmiere: PriseExport {
    public init() {}

    public func exporter(_ dossier: Dossier) throws -> DocumentExporte {
        // Promesse 1 de la prise : pas de note sans validation. Gardez cette ligne.
        guard dossier.estValide else { throw ErreurExport.dossierNonValide }

        return DocumentExporte(
            nomFichier: "note-infirmiere-\(dossier.patient.code).pdf",
            typeMIME: "application/pdf",
            contenu: PDFSimple.fabriquer(Self.lignes(de: dossier)))
    }

    /// Le contenu de la note, ligne par ligne. C'est la partie à enrichir.
    static func lignes(de dossier: Dossier) -> [PDFSimple.Ligne] {
        var lignes: [PDFSimple.Ligne] = []

        lignes.append(.init("NOTE INFIRMIÈRE · SOINS INTENSIFS", gras: true))
        lignes.append(.init("Version de démonstration : valeurs factices"))
        lignes.append(.init(""))
        lignes.append(.init("Patient : \(dossier.patient.code)    \(dossier.patient.lit)"))
        lignes.append(.init("Date : \(Format.date(dossier.creeLe))"))
        lignes.append(.init("Validé par : \(dossier.validePar ?? "")"))
        lignes.append(.init(""))

        lignes.append(.init("SIGNES VITAUX ET APPAREILS", gras: true))
        for lecture in dossier.lectures {
            lignes.append(.init(lecture.etape.titre, gras: true))
            for mesure in lecture.mesures {
                lignes.append(.init("    " + mesure.enTexte))
            }
        }
        lignes.append(.init(""))

        lignes.append(.init("OBSERVATIONS DE L'INFIRMIÈRE", gras: true))
        lignes.append(.init(dossier.noteVocale ?? "(aucune note dictée)"))

        return lignes
    }
}
