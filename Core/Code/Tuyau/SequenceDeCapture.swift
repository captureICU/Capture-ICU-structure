import Foundation

/// L'ordre dans lequel on demande les photos à l'infirmière.
///
/// L'app ne reconnaît pas l'appareil sur la photo : c'est la séquence qui dit
/// « maintenant, photographiez la pompe 1 ». Le nombre de pompes change d'un
/// patient à l'autre (spécification 3.2), d'où `SessionDeCapture.ajouterPompe()`.
///
/// PROVISOIRE : l'ordre est à confirmer avec l'équipe soignante de l'ICM.
public enum SequenceDeCapture {
    public static func standard(nombreDePompes: Int = 1, avecVentilateur: Bool = true) -> [EtapeDeCapture] {
        var etapes = [EtapeDeCapture(.moniteur)]
        if nombreDePompes > 0 {
            for numero in 1 ... nombreDePompes {
                etapes.append(EtapeDeCapture(.pompe, numero: numero))
            }
        }
        if avecVentilateur {
            etapes.append(EtapeDeCapture(.ventilateur))
        }
        return etapes
    }
}
