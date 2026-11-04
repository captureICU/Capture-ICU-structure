import Foundation

/// Une photo prise par l'app, sous forme d'octets (JPEG ou HEIC).
///
/// Des octets plutôt qu'une `UIImage` : le Core ne connaît aucun type propre à
/// l'iPhone. C'est ce qui permet de tout tester sur un ordinateur ordinaire.
public struct Photo: Sendable, Equatable {
    public let donnees: Data

    public init(donnees: Data) {
        self.donnees = donnees
    }
}

/// Un enregistrement audio, sous forme d'octets (par exemple un fichier .m4a).
public struct Audio: Sendable, Equatable {
    public let donnees: Data
    public let dureeSecondes: Double

    public init(donnees: Data, dureeSecondes: Double) {
        self.donnees = donnees
        self.dureeSecondes = dureeSecondes
    }
}
