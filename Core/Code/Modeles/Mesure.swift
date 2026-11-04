import Foundation

/// Une valeur lue sur un appareil, avec sa provenance.
///
/// Règle du projet : aucune valeur ne se finalise toute seule. L'app aide à
/// documenter, elle ne décide rien. C'est l'infirmière qui valide le dossier.
public struct Mesure: Sendable, Equatable, Codable {
    public var parametre: Parametre
    /// `nil` = case vide : la valeur n'a pas été lue avec assez de certitude
    /// et doit être remplie à la main.
    public var valeur: Double?
    /// Entre 0 et 1. Vaut 1 quand l'infirmière a saisi ou corrigé la valeur.
    public var confiance: Double
    public var corrigeeParInfirmiere: Bool

    public init(_ parametre: Parametre, valeur: Double?, confiance: Double = 1, corrigeeParInfirmiere: Bool = false) {
        self.parametre = parametre
        self.valeur = valeur
        self.confiance = confiance
        self.corrigeeParInfirmiere = corrigeeParInfirmiere
    }

    /// Par exemple « FC : 88 bpm », « SpO2 : à remplir », « TAS : 92 mmHg (corrigée) ».
    public var enTexte: String {
        let texteValeur: String
        if let valeur {
            texteValeur = "\(Format.nombre(valeur)) \(parametre.unite)"
        } else {
            texteValeur = "à remplir"
        }
        let marque = corrigeeParInfirmiere ? " (corrigée)" : ""
        return "\(parametre.abreviation) : \(texteValeur)\(marque)"
    }
}

/// Mise en forme partagée, pour que l'app et la note écrivent les valeurs pareil.
public enum Format {
    /// 88.0 → « 88 », 36.8 → « 36.8 ».
    public static func nombre(_ valeur: Double) -> String {
        if valeur == valeur.rounded(), abs(valeur) < 1_000_000_000 {
            return String(Int(valeur))
        }
        return String(valeur)
    }

    /// « 2026-11-04 14:30 », heure de Montréal.
    public static func date(_ date: Date) -> String {
        let formateur = DateFormatter()
        formateur.locale = Locale(identifier: "en_US_POSIX")
        formateur.timeZone = TimeZone(identifier: "America/Toronto") ?? TimeZone(secondsFromGMT: 0)!
        formateur.dateFormat = "yyyy-MM-dd HH:mm"
        return formateur.string(from: date)
    }
}
