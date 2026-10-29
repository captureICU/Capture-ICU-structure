import Testing

@testable import Core

// Le corpus de fixtures est l'actif le plus précieux du projet.
//
// Chaque photo rapportée de l'ICM devient un dossier dans Fixtures/, avec la
// sortie de l'OCR figée et les valeurs attendues. Le corpus ne fait que grossir,
// et un cas qui passait ne peut plus jamais redevenir faux sans que la CI le dise.
//
// C'est aussi la preuve de validation du livrable 4 (résultats et rapport de
// tests) : « l'extraction est correcte sur N photos de moniteur » est une phrase
// qu'on peut écrire parce que ce test existe.
//
// Ajouter un cas : Fixtures/LISEZ-MOI.md. Aucun code Swift à écrire.

@Suite("Corpus de fixtures — moniteurs")
struct MonitorCorpusTests {
    /// Sans ce test, un corpus qu'on aurait cessé de charger (dossier mal nommé,
    /// ressource oubliée dans Package.swift) donnerait zéro cas à exécuter, donc
    /// zéro échec, donc une CI verte qui ne vérifie plus rien.
    @Test("Le corpus contient au moins un cas")
    func corpusIsNotEmpty() {
        let names = FixtureCorpus.caseNames(prefix: FixtureCorpus.monitorPrefix)

        #expect(!names.isEmpty, "Aucun cas trouvé dans Tests/CoreTests/Fixtures/")
    }

    @Test(
        "L'extraction correspond à expected.json",
        arguments: FixtureCorpus.caseNames(prefix: FixtureCorpus.monitorPrefix)
    )
    func extractionMatchesExpectation(caseName: String) throws {
        let fixture = try FixtureCorpus.load(caseName)

        let vitals = MonitorExtractor().extract(from: fixture.ocrBlocks)
        let mismatches = fixture.mismatches(against: vitals)

        #expect(
            mismatches.isEmpty,
            "\(caseName) — \(mismatches.map(\.description).joined(separator: " ; "))"
        )
    }
}
