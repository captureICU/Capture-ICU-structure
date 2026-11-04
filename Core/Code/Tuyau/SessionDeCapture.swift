import Foundation

// LE TUYAU CENTRAL.
//
// Une session = une visite au chevet d'un patient. Elle suit le parcours :
//
//   1. connexion        (ConnexionFactice)
//   2. choix du patient → SessionDeCapture(patient:modules:)
//   3. photos           → capturerPhoto(_:)   appelle le module OCR
//   4. note vocale      → enregistrerNote(_:) appelle le module Transcription
//   5. validation       → corriger(...), puis valider(par:)
//   6. export           → exporter()          appelle le module Export
//
// La session ne connaît que les prises, jamais les modules eux-mêmes. L'app lui
// branche les vrais modules; les tests lui branchent des faux. Le même code
// tourne dans les deux cas : c'est ce qui permet de tester tout le parcours
// sans iPhone.

/// Les trois modules branchés sur le Core.
public struct Modules: Sendable {
    public let ocr: any PriseOCR
    public let transcription: any PriseTranscription
    public let export: any PriseExport

    public init(ocr: any PriseOCR, transcription: any PriseTranscription, export: any PriseExport) {
        self.ocr = ocr
        self.transcription = transcription
        self.export = export
    }
}

/// Ce que la session refuse de faire, et pourquoi.
public enum ErreurSession: Error, Sendable, Equatable {
    /// Toutes les étapes de la séquence sont déjà faites.
    case plusDePhotoAPrendre
    /// On essaie de valider alors qu'il reste des photos à prendre (ou à sauter).
    case photosManquantes
    /// On essaie de valider alors qu'il reste des cases vides.
    case casesARemplir
    /// On essaie d'exporter un dossier pas encore validé.
    case pasEncoreValide
    /// On essaie de modifier un dossier déjà validé.
    case dejaValide
    /// On essaie de corriger une valeur qui n'existe pas pour cette étape.
    case mesureIntrouvable
}

public struct SessionDeCapture: Sendable {
    public private(set) var dossier: Dossier
    public private(set) var sequence: [EtapeDeCapture]
    /// La position dans la séquence. Égale à `sequence.count` quand tout est fait.
    public private(set) var indexEtape: Int = 0
    private let modules: Modules

    public init(
        patient: Patient,
        modules: Modules,
        sequence: [EtapeDeCapture] = SequenceDeCapture.standard(),
        date: Date = Date()
    ) {
        self.dossier = Dossier(patient: patient, creeLe: date)
        self.sequence = sequence
        self.modules = modules
    }

    // MARK: - Étape 3 · Photos

    /// L'appareil à photographier maintenant. `nil` quand toutes les photos sont faites.
    public var etapeCourante: EtapeDeCapture? {
        indexEtape < sequence.count ? sequence[indexEtape] : nil
    }

    /// Envoie la photo au module OCR, vide les valeurs douteuses, range le résultat
    /// sous l'étape courante, puis passe à l'étape suivante.
    public mutating func capturerPhoto(_ photo: Photo) async throws {
        guard !dossier.estValide else { throw ErreurSession.dejaValide }
        guard let etape = etapeCourante else { throw ErreurSession.plusDePhotoAPrendre }

        let lues = try await modules.ocr.lire(photo, appareil: etape.appareil)
        let mesures = Verification.viderLesDoutes(lues)

        dossier.lectures.removeAll { $0.etape == etape }
        dossier.lectures.append(Lecture(etape: etape, mesures: mesures))
        indexEtape += 1
    }

    /// Cet appareil n'est pas au chevet : on passe sans photo.
    public mutating func passerEtape() {
        if indexEtape < sequence.count {
            indexEtape += 1
        }
    }

    /// Le patient a une pompe de plus. Elle est demandée tout de suite si on a
    /// déjà dépassé les pompes, sinon à la suite des autres.
    public mutating func ajouterPompe() {
        let numero = sequence.filter { $0.appareil == .pompe }.count + 1
        let dernierePompe = sequence.lastIndex(where: { $0.appareil == .pompe })
        let moniteur = sequence.firstIndex(where: { $0.appareil == .moniteur })
        let apresLesPompes = (dernierePompe ?? moniteur ?? -1) + 1
        let position = max(apresLesPompes, indexEtape)
        sequence.insert(EtapeDeCapture(.pompe, numero: numero), at: position)
    }

    // MARK: - Étape 4 · Note vocale

    /// Envoie l'audio au module Transcription et garde le texte mot pour mot.
    /// Une nouvelle dictée remplace la précédente.
    public mutating func enregistrerNote(_ audio: Audio) async throws {
        guard !dossier.estValide else { throw ErreurSession.dejaValide }
        dossier.noteVocale = try await modules.transcription.transcrire(audio)
    }

    // MARK: - Étape 5 · Validation

    /// Ce que l'infirmière doit regarder avant de valider.
    public var alertes: [Alerte] {
        Verification.alertes(dossier)
    }

    /// L'infirmière remplace une valeur (ou remplit une case vide).
    public mutating func corriger(_ parametre: Parametre, a etape: EtapeDeCapture, valeur: Double) throws {
        guard !dossier.estValide else { throw ErreurSession.dejaValide }
        guard etape.appareil.parametres.contains(parametre),
              let i = dossier.lectures.firstIndex(where: { $0.etape == etape })
        else { throw ErreurSession.mesureIntrouvable }

        let corrigee = Mesure(parametre, valeur: valeur, confiance: 1, corrigeeParInfirmiere: true)
        if let j = dossier.lectures[i].mesures.firstIndex(where: { $0.parametre == parametre }) {
            dossier.lectures[i].mesures[j] = corrigee
        } else {
            dossier.lectures[i].mesures.append(corrigee)
        }
    }

    /// L'infirmière confirme tout le dossier (spécification 3.1 et 8.2-1).
    /// Refusé tant qu'il reste des photos à faire ou des cases vides.
    /// Les valeurs hors plage n'empêchent pas de valider : elles peuvent être vraies.
    public mutating func valider(par utilisateur: Utilisateur) throws {
        guard !dossier.estValide else { throw ErreurSession.dejaValide }
        guard etapeCourante == nil else { throw ErreurSession.photosManquantes }
        guard !alertes.contains(where: { $0.raison == .caseVide }) else { throw ErreurSession.casesARemplir }
        dossier.validePar = utilisateur.identifiant
    }

    // MARK: - Étape 6 · Export

    /// Produit la note infirmière. Impossible avant la validation.
    public func exporter() throws -> DocumentExporte {
        guard dossier.estValide else { throw ErreurSession.pasEncoreValide }
        return try modules.export.exporter(dossier)
    }
}
