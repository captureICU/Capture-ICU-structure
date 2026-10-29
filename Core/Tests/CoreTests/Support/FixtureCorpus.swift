import Foundation

// Chargement du corpus de fixtures (Tests/CoreTests/Fixtures/).
//
// Un cas = un dossier contenant exactement deux fichiers :
//   blocks.json    la sortie de l'OCR, figée une fois pour toutes
//   expected.json  les valeurs que l'extraction doit en tirer
//
// Personne n'a besoin de lire ce fichier pour ajouter un cas.
// La marche à suivre est dans Fixtures/LISEZ-MOI.md.

// MARK: - Format de blocks.json

struct FixtureRect: Codable, Sendable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double
}

struct FixtureBlock: Codable, Sendable {
    let text: String
    let confidence: Double
    let boundingBox: FixtureRect?
}

struct FixtureInput: Codable, Sendable {
    /// Ce que montre la photo, en français, en une phrase.
    let description: String
    /// D'où elle vient et comment elle a été anonymisée. Obligatoire : c'est la
    /// trace qu'on présentera si le comité d'éthique pose la question.
    let source: String
    let blocks: [FixtureBlock]
}

// MARK: - Format de expected.json

/// Les sept champs doivent tous figurer dans `expected.json`.
///
/// - une valeur : l'extraction doit produire exactement cette valeur;
/// - `null`     : l'extraction ne doit produire AUCUNE valeur pour ce champ.
///
/// Les deux comptent autant. Un extracteur qui invente une saturation à partir
/// d'un numéro de série est aussi faux qu'un extracteur qui rate la fréquence
/// cardiaque, et seul le `null` explicite l'attrape.
///
/// Une clé absente ou mal orthographiée est une erreur dure, pas un champ ignoré :
/// sans cette vérification, une faute de frappe transforme l'assertion en
/// « je n'attends rien », qui passe toujours.
struct ExpectedVitals: Sendable {
    static let allowedFields: [String] = [
        "heartRate",
        "systolicBP",
        "diastolicBP",
        "meanArterialPressure",
        "oxygenSaturation",
        "respiratoryRate",
        "temperatureCelsius",
    ]

    let fields: [String: Double?]

    init(data: Data, caseName: String) throws {
        guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw FixtureError.malformed(caseName: caseName, file: "expected.json")
        }

        let present = Set(object.keys)
        let allowed = Set(Self.allowedFields)
        let unknown = present.subtracting(allowed).sorted()
        let missing = allowed.subtracting(present).sorted()

        guard unknown.isEmpty, missing.isEmpty else {
            throw FixtureError.fieldMismatch(caseName: caseName, unknown: unknown, missing: missing)
        }

        fields = try JSONDecoder().decode(Raw.self, from: data).asDictionary
    }

    /// La même forme, construite à partir de ce que l'extraction a réellement produit.
    static func fields(of vitals: VitalSigns) -> [String: Double?] {
        [
            "heartRate": vitals.heartRate.value.map { Double($0) },
            "systolicBP": vitals.systolicBP.value.map { Double($0) },
            "diastolicBP": vitals.diastolicBP.value.map { Double($0) },
            "meanArterialPressure": vitals.meanArterialPressure.value.map { Double($0) },
            "oxygenSaturation": vitals.oxygenSaturation.value.map { Double($0) },
            "respiratoryRate": vitals.respiratoryRate.value.map { Double($0) },
            "temperatureCelsius": vitals.temperatureCelsius.value,
        ]
    }

    private struct Raw: Decodable {
        let heartRate: Double?
        let systolicBP: Double?
        let diastolicBP: Double?
        let meanArterialPressure: Double?
        let oxygenSaturation: Double?
        let respiratoryRate: Double?
        let temperatureCelsius: Double?

        var asDictionary: [String: Double?] {
            [
                "heartRate": heartRate,
                "systolicBP": systolicBP,
                "diastolicBP": diastolicBP,
                "meanArterialPressure": meanArterialPressure,
                "oxygenSaturation": oxygenSaturation,
                "respiratoryRate": respiratoryRate,
                "temperatureCelsius": temperatureCelsius,
            ]
        }
    }
}

// MARK: - Comparaison

/// Un champ dont la valeur produite ne correspond pas à `expected.json`.
struct FieldMismatch: Sendable, CustomStringConvertible {
    let field: String
    let expected: Double?
    let actual: Double?

    var description: String {
        "\(field) : attendu \(Self.format(expected)), obtenu \(Self.format(actual))"
    }

    private static func format(_ value: Double?) -> String {
        guard let value else { return "aucune valeur" }
        return value == value.rounded() ? String(Int(value)) : String(value)
    }
}

// MARK: - Un cas chargé

struct FixtureCase: Sendable {
    let name: String
    let input: FixtureInput
    let expected: ExpectedVitals

    var ocrBlocks: [OCRTextBlock] {
        input.blocks.map { block in
            OCRTextBlock(
                text: block.text,
                confidence: block.confidence,
                boundingBox: block.boundingBox.map {
                    NormalizedRect(x: $0.x, y: $0.y, width: $0.width, height: $0.height)
                }
            )
        }
    }

    /// Liste vide = le cas passe.
    func mismatches(against vitals: VitalSigns) -> [FieldMismatch] {
        let actual = ExpectedVitals.fields(of: vitals)

        return ExpectedVitals.allowedFields.compactMap { field in
            let expectedValue = expected.fields[field] ?? nil
            let actualValue = actual[field] ?? nil

            switch (expectedValue, actualValue) {
            case (nil, nil):
                return nil
            case let (expectedValue?, actualValue?) where abs(expectedValue - actualValue) < 1e-9:
                return nil
            default:
                return FieldMismatch(field: field, expected: expectedValue, actual: actualValue)
            }
        }
    }
}

// MARK: - Erreurs

enum FixtureError: Error, CustomStringConvertible {
    case corpusDirectoryMissing
    case fileMissing(caseName: String, file: String)
    case malformed(caseName: String, file: String)
    case fieldMismatch(caseName: String, unknown: [String], missing: [String])

    var description: String {
        switch self {
        case .corpusDirectoryMissing:
            return "Dossier Fixtures/ introuvable dans le bundle de tests. "
                + "Vérifier que Package.swift déclare resources sur CoreTests."
        case let .fileMissing(caseName, file):
            return "Le cas « \(caseName) » n'a pas de fichier \(file)."
        case let .malformed(caseName, file):
            return "Le fichier \(file) du cas « \(caseName) » n'est pas un objet JSON valide."
        case let .fieldMismatch(caseName, unknown, missing):
            var parts = ["expected.json du cas « \(caseName) » :"]
            if !unknown.isEmpty {
                parts.append("champs inconnus (faute de frappe ?) : " + unknown.joined(separator: ", "))
            }
            if !missing.isEmpty {
                parts.append("champs manquants : " + missing.joined(separator: ", ")
                    + ". Mettre null si le champ ne doit pas être extrait.")
            }
            return parts.joined(separator: " ")
        }
    }
}

// MARK: - Chargement

enum FixtureCorpus {
    /// Un préfixe par famille d'appareil, pour que chaque famille ait sa suite de
    /// tests sans qu'il faille tenir un registre à jour quelque part.
    static let monitorPrefix = "moniteur-"
    static let pumpPrefix = "pompe-"

    /// On passe le NOM du cas aux tests, pas le cas chargé : un échec affiche
    /// alors « moniteur-philips-01 » et non le contenu entier du JSON.
    static func caseNames(prefix: String) -> [String] {
        guard let root = rootDirectory else { return [] }

        let contents = (try? FileManager.default.contentsOfDirectory(
            at: root,
            includingPropertiesForKeys: nil
        )) ?? []

        return contents
            .filter { FileManager.default.fileExists(atPath: $0.appendingPathComponent("blocks.json").path) }
            .map(\.lastPathComponent)
            .filter { $0.hasPrefix(prefix) }
            .sorted()
    }

    static func load(_ caseName: String) throws -> FixtureCase {
        guard let root = rootDirectory else { throw FixtureError.corpusDirectoryMissing }
        let directory = root.appendingPathComponent(caseName, isDirectory: true)

        let inputData = try data(at: directory, file: "blocks.json", caseName: caseName)
        let expectedData = try data(at: directory, file: "expected.json", caseName: caseName)

        return try FixtureCase(
            name: caseName,
            input: JSONDecoder().decode(FixtureInput.self, from: inputData),
            expected: ExpectedVitals(data: expectedData, caseName: caseName)
        )
    }

    private static var rootDirectory: URL? {
        if let url = Bundle.module.url(forResource: "Fixtures", withExtension: nil) {
            return url
        }
        return Bundle.module.resourceURL?.appendingPathComponent("Fixtures", isDirectory: true)
    }

    private static func data(at directory: URL, file: String, caseName: String) throws -> Data {
        let url = directory.appendingPathComponent(file)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw FixtureError.fileMissing(caseName: caseName, file: file)
        }
        return try Data(contentsOf: url)
    }
}
