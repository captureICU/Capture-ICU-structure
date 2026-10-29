import Foundation

// CONTRAT — compatibilité des données (format d'échange d'une capture)
//
// Le format exporté est ce que d'autres systèmes liront (dossier clinique,
// CritiCare, outils de l'équipe). C'est le contrat le plus coûteux à casser :
// un champ renommé ici casse un lecteur qu'on ne voit pas.
//
// Implémentation de référence : `JSONRecordCodec` (Core/Donnees/).
// Vérification du contrat : `RecordCodecContract.check(...)` dans CoreTestKit.
// Exemple figé du format v1 : Tests/CoreTests/Fixtures/export/v1-exemple.json.

/// Comment une capture a été faite.
public enum CaptureSource: String, Sendable, Equatable, Codable {
    case monitorPhoto
    case dictation
}

/// Une capture complète, telle qu'elle s'exporte.
///
/// Toute modification de ce type change le format d'échange. Règle : ajouter un
/// champ optionnel est compatible; renommer, retirer ou changer le type d'un
/// champ exige d'incrémenter `currentSchemaVersion` et d'ajouter un nouvel
/// exemple figé (`v2-exemple.json`) sans toucher à l'ancien.
public struct CaptureRecord: Sendable, Equatable, Codable {
    public static let currentSchemaVersion = 1

    public var schemaVersion: Int
    /// Code libre (lit, dossier d'étude). JAMAIS un nom ni un numéro de dossier.
    public var captureCode: String
    public var capturedAt: Date
    public var source: CaptureSource
    public var vitals: VitalSigns

    public init(
        captureCode: String,
        capturedAt: Date,
        source: CaptureSource,
        vitals: VitalSigns,
        schemaVersion: Int = CaptureRecord.currentSchemaVersion
    ) {
        self.schemaVersion = schemaVersion
        self.captureCode = captureCode
        self.capturedAt = capturedAt
        self.source = source
        self.vitals = vitals
    }
}

/// Les erreurs propres au format, en plus des erreurs de décodage ordinaires.
public enum RecordCodecError: Error, Sendable, Equatable {
    /// Le document ne déclare pas de `schemaVersion`.
    case missingSchemaVersion
    /// Le document vient d'une version plus récente que celle que l'app sait lire.
    case unsupportedSchemaVersion(Int)
}

/// Écrit et relit une capture.
///
/// Promesses, vérifiées par `RecordCodecContract` (EX-007) :
/// 1. Aller-retour sans perte : `decode(encode(r)) == r`.
/// 2. Déterministe : encoder deux fois la même capture donne les mêmes octets.
/// 3. Le document déclare `schemaVersion` au premier niveau.
/// 4. Une version future est refusée avec `unsupportedSchemaVersion`.
/// 5. Un document illisible lance une erreur, sans planter.
public protocol RecordCodec: Sendable {
    func encode(_ record: CaptureRecord) throws -> Data
    func decode(_ data: Data) throws -> CaptureRecord
}
