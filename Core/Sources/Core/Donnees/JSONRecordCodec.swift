import Foundation

/// Implémentation de référence de `RecordCodec` : JSON trié, dates ISO 8601.
///
/// Les clés sont triées pour que la sortie soit déterministe : deux exports de
/// la même capture donnent les mêmes octets, et un changement de format se voit
/// ligne par ligne dans le diff d'une PR.
public struct JSONRecordCodec: RecordCodec {
    public init() {}

    public func encode(_ record: CaptureRecord) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(record)
    }

    public func decode(_ data: Data) throws -> CaptureRecord {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        // On lit la version AVANT le reste : un document v2 lu avec les règles v1
        // pourrait se décoder « presque » correctement, ce qui est pire qu'un refus.
        let probe = try decoder.decode(VersionProbe.self, from: data)
        guard let version = probe.schemaVersion else {
            throw RecordCodecError.missingSchemaVersion
        }
        guard version <= CaptureRecord.currentSchemaVersion else {
            throw RecordCodecError.unsupportedSchemaVersion(version)
        }

        return try decoder.decode(CaptureRecord.self, from: data)
    }

    private struct VersionProbe: Decodable {
        let schemaVersion: Int?
    }
}
