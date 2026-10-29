import Core
import CoreTestKit
import Foundation
import Testing

// Le format d'échange v1, figé.
//
// Fixtures/export/v1-exemple.json est ce que d'autres systèmes liront. Si ce
// test casse, quelqu'un a changé le format : un champ renommé, retiré, ou un
// type changé. Ce n'est PAS une raison de modifier v1-exemple.json. La marche
// à suivre est dans docs/SOUS-SYSTEMES.md, « Changer un contrat ».

@Suite("Données — format d'échange v1")
struct RecordFormatTests {
    @Test("EX-007 : l'export produit exactement le format v1 figé")
    func exportMatchesFrozenV1() throws {
        let produced = try JSONRecordCodec().encode(SampleInputs.record)
        let frozen = try Self.frozenV1()

        // On compare le contenu, pas les octets bruts : l'espacement peut varier
        // entre Linux et macOS, les clés et les valeurs non. Les deux documents
        // sont relus puis réécrits de la même façon avant comparaison.
        #expect(
            try Self.canonical(produced) == Self.canonical(frozen),
            "Produit : \(String(decoding: produced, as: UTF8.self))"
        )
    }

    private static func canonical(_ data: Data) throws -> String {
        let object = try JSONSerialization.jsonObject(with: data)
        let rewritten = try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
        return String(decoding: rewritten, as: UTF8.self)
    }

    @Test("EX-007 : un document v1 se relit sans perte")
    func frozenV1StillDecodes() throws {
        let record = try JSONRecordCodec().decode(Self.frozenV1())

        #expect(record == SampleInputs.record)
    }

    @Test("EX-007 : un document sans schemaVersion est refusé")
    func missingVersionIsRejected() {
        let data = Data(#"{"captureCode": "EXEMPLE-01"}"#.utf8)

        #expect(throws: RecordCodecError.missingSchemaVersion) {
            try JSONRecordCodec().decode(data)
        }
    }

    private static func frozenV1() throws -> Data {
        let root = Bundle.module.url(forResource: "Fixtures", withExtension: nil)
            ?? Bundle.module.resourceURL!.appendingPathComponent("Fixtures", isDirectory: true)
        return try Data(contentsOf: root.appendingPathComponent("export/v1-exemple.json"))
    }
}
