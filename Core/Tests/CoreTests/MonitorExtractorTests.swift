import Testing

@testable import Core

// ┌──────────────────────────────────────────────────────────────────────────┐
// │  C'EST CE FICHIER QU'ON COPIE POUR ÉCRIRE UN NOUVEAU TEST.               │
// │  Marche à suivre complète : docs/TESTS.md                                │
// └──────────────────────────────────────────────────────────────────────────┘
//
// Anatomie d'un test, toujours la même :
//   1. on fabrique une entrée            (Arrange)
//   2. on appelle la fonction testée     (Act)
//   3. on vérifie le résultat            (Assert)
//
// Le titre entre guillemets est ce qui s'affiche dans le rapport d'intégration
// continue et dans la matrice de traçabilité. Il commence par le numéro
// d'exigence couverte (EX-###, voir docs/exigences.md) puis dit, en français et
// au présent, ce que le système doit faire. Pas « test 3 », pas « ça marche ».

@Suite("Extraction — moniteur de chevet")
struct MonitorExtractorTests {
    @Test("EX-001 : lit la fréquence cardiaque étiquetée FC")
    func readsFrenchHeartRateLabel() {
        // Arrange
        let text = "FC 90"

        // Act
        let vitals = MonitorExtractor().extract(from: text)

        // Assert
        #expect(vitals.heartRate.value == 90)
    }

    @Test("EX-001 : lit la fréquence cardiaque étiquetée HR")
    func readsEnglishHeartRateLabel() {
        let vitals = MonitorExtractor().extract(from: "HR 86")

        #expect(vitals.heartRate.value == 86)
    }

    @Test("EX-001 : ignore les lignes sans étiquette de fréquence cardiaque")
    func ignoresUnlabelledNumbers() {
        // Un moniteur affiche des dizaines de nombres : numéro de lit, heure,
        // limites d'alarme, numéro de série. En attraper un au hasard serait pire
        // que de ne rien lire, parce que personne ne s'en apercevrait.
        let vitals = MonitorExtractor().extract(from: "IntelliVue MX800\n2011130")

        #expect(vitals.heartRate.value == nil)
    }

    @Test("EX-004 : une valeur extraite exige toujours une révision")
    func extractedValuesAlwaysRequireReview() {
        // La règle « jamais d'autofinalisation » vaut aussi pour les valeurs que
        // l'OCR a lues parfaitement. C'est une exigence du client, pas un détail
        // d'implémentation : elle mérite son test.
        let vitals = MonitorExtractor().extract(from: "FC 90")

        #expect(vitals.heartRate.requiresReview)
    }

    // Un test qui échoue, laissé exprès en commentaire : c'est la prochaine
    // fonctionnalité à écrire. Décommenter, voir le rouge, puis écrire le code
    // dans MonitorExtractor jusqu'au vert. Ne jamais faire l'inverse.
    //
    // @Test("EX-002 : lit la tension artérielle systolique et diastolique")
    // func readsBloodPressure() {
    //     let vitals = MonitorExtractor().extract(from: "PA 111/51")
    //
    //     #expect(vitals.systolicBP.value == 111)
    //     #expect(vitals.diastolicBP.value == 51)
    // }
}
