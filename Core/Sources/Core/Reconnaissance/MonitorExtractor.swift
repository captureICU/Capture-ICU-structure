import Foundation

/// Transforme le texte brut d'un moniteur de chevet en signes vitaux structurés.
///
/// SQUELETTE VOLONTAIREMENT INCOMPLET. Seule la fréquence cardiaque est extraite
/// (EX-001). Tout le reste est à écrire, et la façon de l'écrire est décrite dans
/// `docs/TESTS.md` : on ajoute d'abord un test qui échoue, puis le code qui le fait
/// passer. Chaque champ ajouté ici doit apparaître dans un `expected.json` du corpus.
public struct MonitorExtractor: Sendable {
    public init() {}

    /// Point d'entrée quand l'OCR a fourni des blocs (le cas réel).
    public func extract(from blocks: [OCRTextBlock]) -> VitalSigns {
        extract(from: blocks.map(\.text).joined(separator: "\n"))
    }

    /// Point d'entrée quand on n'a qu'un texte : dictée vocale, ou test écrit à la main.
    public func extract(from text: String) -> VitalSigns {
        var vitals = VitalSigns()

        // EX-001 — fréquence cardiaque. Étiquettes vues sur les moniteurs de l'ICM :
        // « FC » (français) et « HR » (anglais).
        if let beatsPerMinute = Self.firstInteger(inLineLabelled: ["FC", "HR"], of: text) {
            vitals.heartRate.value = beatsPerMinute
        }

        // TODO EX-002 — tension artérielle « TA 118/64 », « BP 118/64 », « PA 111/51 ».
        // TODO EX-003 — saturation « SpO2 96 % ». Attention : l'étiquette contient le
        //               chiffre 2, donc `firstInteger` ci-dessous ne suffit pas telle quelle.
        //               C'est exactement le genre de piège qu'un test attrape et qu'une
        //               relecture rate.
        // TODO EX-00? — fréquence respiratoire, PAM, température.

        return vitals
    }

    /// Cherche la première ligne portant une des étiquettes, et y lit le premier
    /// nombre entier. Délibérément naïf : c'est un point de départ, pas une solution.
    private static func firstInteger(inLineLabelled labels: [String], of text: String) -> Int? {
        for line in text.split(separator: "\n") {
            let uppercased = line.uppercased()
            guard labels.contains(where: { uppercased.contains($0) }) else { continue }

            let numbers = uppercased.split(whereSeparator: { !$0.isNumber })
            if let first = numbers.first, let value = Int(first) {
                return value
            }
        }
        return nil
    }
}
