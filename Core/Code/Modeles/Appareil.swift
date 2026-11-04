import Foundation

/// Un appareil qu'on photographie au chevet.
public enum Appareil: String, Sendable, Codable, CaseIterable {
    case moniteur
    case pompe
    case ventilateur

    public var nom: String {
        switch self {
        case .moniteur: return "Moniteur"
        case .pompe: return "Pompe"
        case .ventilateur: return "Ventilateur"
        }
    }

    /// Les paramètres qu'on peut lire sur cet appareil.
    public var parametres: [Parametre] {
        switch self {
        case .moniteur:
            return [.frequenceCardiaque, .tensionSystolique, .tensionDiastolique,
                    .tensionMoyenne, .saturation, .frequenceRespiratoire, .temperature]
        case .pompe:
            return [.debitPompe]
        case .ventilateur:
            return [.fio2, .peep]
        }
    }
}

/// Une étape de la séquence de photos : « Moniteur », « Pompe 2 »…
public struct EtapeDeCapture: Sendable, Equatable, Hashable, Codable {
    public let appareil: Appareil
    /// 1, 2, 3… Sert surtout aux pompes, qui peuvent être plusieurs.
    public let numero: Int

    public init(_ appareil: Appareil, numero: Int = 1) {
        self.appareil = appareil
        self.numero = numero
    }

    /// Ce qu'on affiche à l'infirmière et dans la note.
    public var titre: String {
        appareil == .pompe ? "\(appareil.nom) \(numero)" : appareil.nom
    }
}
