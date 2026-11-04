import Foundation

/// La personne connectée.
public struct Utilisateur: Sendable, Equatable, Codable {
    public let identifiant: String

    public init(identifiant: String) {
        self.identifiant = identifiant
    }
}

/// FACTICE — accepte seulement « demo » / « demo ».
///
/// La vraie connexion sécurisée (comptes de l'hôpital, mots de passe protégés)
/// viendra plus tard. Ce bouchon sert à construire et tester le parcours dès
/// maintenant, avec la même forme : identifiant + mot de passe → utilisateur ou refus.
public struct ConnexionFactice: Sendable {
    public init() {}

    public func connecter(identifiant: String, motDePasse: String) -> Utilisateur? {
        guard identifiant == "demo", motDePasse == "demo" else { return nil }
        return Utilisateur(identifiant: identifiant)
    }
}
