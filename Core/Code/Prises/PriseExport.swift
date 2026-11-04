import Foundation

// PRISE EXPORT — là où le module d'export se branche sur le Core.
//
// Le module qui se branche ici : Modules/Export/Code/ExportNoteInfirmiere.swift
// La vérification automatique : OutilsDeTest/VerifierLesPrises.swift
//
// Modifier ce fichier = modifier la prise de toute l'équipe. Ouvrir une issue d'abord.

/// Un fichier prêt à partager ou à imprimer.
public struct DocumentExporte: Sendable, Equatable {
    /// Par exemple « note-infirmiere-P-001.pdf ».
    public let nomFichier: String
    /// Par exemple « application/pdf ».
    public let typeMIME: String
    public let contenu: Data

    public init(nomFichier: String, typeMIME: String, contenu: Data) {
        self.nomFichier = nomFichier
        self.typeMIME = typeMIME
        self.contenu = contenu
    }
}

/// Transforme un dossier validé en document (la note infirmière).
///
/// Promesses (vérifiées par `VerifierPrise.export`) :
/// 1. Dossier pas encore validé → lance `ErreurExport.dossierNonValide`.
///    (Le Core le vérifie aussi. Deux verrous valent mieux qu'un.)
/// 2. Le document a un nom de fichier et un contenu non vides.
/// 3. Le même dossier donne toujours exactement le même document.
public protocol PriseExport: Sendable {
    func exporter(_ dossier: Dossier) throws -> DocumentExporte
}

/// Les seules erreurs que le module d'export a le droit de lancer.
public enum ErreurExport: Error, Sendable, Equatable {
    case dossierNonValide
}
