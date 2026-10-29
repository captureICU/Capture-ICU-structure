import Testing

@testable import Core

@Suite("Validation — bornes physiologiques")
struct VitalSignValidatorTests {
    @Test("EX-005 : des valeurs normales ne produisent aucune anomalie")
    func normalValuesProduceNoIssue() {
        var vitals = VitalSigns()
        vitals.heartRate.value = 86
        vitals.oxygenSaturation.value = 96

        let issues = VitalSignValidator().validate(vitals)

        #expect(issues.isEmpty)
    }

    @Test("EX-005 : une fréquence cardiaque hors bornes est signalée")
    func outOfRangeHeartRateIsFlagged() {
        var vitals = VitalSigns()
        vitals.heartRate.value = 300

        let issues = VitalSignValidator().validate(vitals)

        #expect(issues == [.heartRateOutOfRange(300)])
    }

    @Test("EX-005 : un champ non lu n'est pas une anomalie")
    func missingValuesAreNotFlagged() {
        let issues = VitalSignValidator().validate(VitalSigns())

        #expect(issues.isEmpty)
    }

    // Test paramétré : une seule fonction, un cas par valeur. Chaque valeur
    // apparaît séparément dans le rapport, donc on sait laquelle a cassé.
    @Test("EX-005 : saturation hors bornes", arguments: [0, 10, 49, 101, 255])
    func outOfRangeSaturationIsFlagged(value: Int) {
        var vitals = VitalSigns()
        vitals.oxygenSaturation.value = value

        let issues = VitalSignValidator().validate(vitals)

        #expect(issues == [.oxygenSaturationOutOfRange(value)])
    }
}
