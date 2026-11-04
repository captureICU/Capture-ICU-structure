import Foundation

/// Un paramètre clinique qu'on peut lire sur un appareil.
///
/// Ajouter un paramètre : l'ajouter ici (avec son abréviation, son unité et sa
/// plage), puis dans `Appareil.parametres`. C'est un changement du Core :
/// ouvrir une issue d'abord.
public enum Parametre: String, Sendable, Codable, CaseIterable {
    // Moniteur
    case frequenceCardiaque
    case tensionSystolique
    case tensionDiastolique
    case tensionMoyenne
    case saturation
    case frequenceRespiratoire
    case temperature
    // Pompe
    case debitPompe
    // Ventilateur
    case fio2
    case peep

    /// Ce qu'on écrit dans la note, par exemple « FC ».
    public var abreviation: String {
        switch self {
        case .frequenceCardiaque: return "FC"
        case .tensionSystolique: return "TAS"
        case .tensionDiastolique: return "TAD"
        case .tensionMoyenne: return "TAM"
        case .saturation: return "SpO2"
        case .frequenceRespiratoire: return "FR"
        case .temperature: return "Temp."
        case .debitPompe: return "Débit"
        case .fio2: return "FiO2"
        case .peep: return "PEEP"
        }
    }

    public var unite: String {
        switch self {
        case .frequenceCardiaque: return "bpm"
        case .tensionSystolique, .tensionDiastolique, .tensionMoyenne: return "mmHg"
        case .saturation, .fio2: return "%"
        case .frequenceRespiratoire: return "/min"
        case .temperature: return "°C"
        case .debitPompe: return "mL/h"
        case .peep: return "cmH2O"
        }
    }

    /// Les valeurs physiologiquement plausibles. En dehors : la valeur est signalée
    /// en rouge, jamais corrigée automatiquement.
    ///
    /// PROVISOIRE : ces bornes sont des valeurs de départ choisies par l'équipe.
    /// Elles doivent être validées par le client (Dr Lamarche) avant les essais.
    public var plagePlausible: ClosedRange<Double> {
        switch self {
        case .frequenceCardiaque: return 20 ... 250
        case .tensionSystolique: return 40 ... 260
        case .tensionDiastolique: return 20 ... 160
        case .tensionMoyenne: return 30 ... 200
        case .saturation: return 50 ... 100
        case .frequenceRespiratoire: return 4 ... 60
        case .temperature: return 30 ... 43
        case .debitPompe: return 0 ... 999
        case .fio2: return 21 ... 100
        case .peep: return 0 ... 30
        }
    }
}
