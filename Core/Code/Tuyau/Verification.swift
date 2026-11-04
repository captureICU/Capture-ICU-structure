import Foundation

/// Quelque chose que l'infirmière doit regarder avant de valider.
public struct Alerte: Sendable, Equatable {
    public enum Raison: Sendable, Equatable {
        /// La valeur sort de la plage plausible : affichée en rouge.
        case horsPlage
        /// La valeur n'a pas été lue avec assez de certitude : case vide à remplir.
        case caseVide
    }

    public let etape: EtapeDeCapture
    public let parametre: Parametre
    public let raison: Raison

    public init(etape: EtapeDeCapture, parametre: Parametre, raison: Raison) {
        self.etape = etape
        self.parametre = parametre
        self.raison = raison
    }

    public var message: String {
        switch raison {
        case .horsPlage: return "\(etape.titre) · \(parametre.abreviation) hors plage : à vérifier"
        case .caseVide: return "\(etape.titre) · \(parametre.abreviation) illisible : à remplir à la main"
        }
    }
}

/// Les règles de vérification du Core (spécification 3.1 et 7.2).
public enum Verification {
    /// En dessous de ce niveau de confiance, on préfère une case vide à une valeur
    /// peut-être fausse. PROVISOIRE : à ajuster avec les vraies photos.
    public static let seuilDeConfiance = 0.8

    /// Vide les valeurs trop incertaines. Appliqué par le Core à chaque photo,
    /// quel que soit le module OCR branché.
    public static func viderLesDoutes(_ mesures: [Mesure]) -> [Mesure] {
        mesures.map { mesure in
            var resultat = mesure
            if resultat.confiance < seuilDeConfiance {
                resultat.valeur = nil
            }
            return resultat
        }
    }

    /// Tout ce que l'infirmière doit regarder dans ce dossier.
    public static func alertes(_ dossier: Dossier) -> [Alerte] {
        var alertes: [Alerte] = []
        for lecture in dossier.lectures {
            for mesure in lecture.mesures {
                if let valeur = mesure.valeur {
                    if !mesure.parametre.plagePlausible.contains(valeur) {
                        alertes.append(Alerte(etape: lecture.etape, parametre: mesure.parametre, raison: .horsPlage))
                    }
                } else {
                    alertes.append(Alerte(etape: lecture.etape, parametre: mesure.parametre, raison: .caseVide))
                }
            }
        }
        return alertes
    }
}
