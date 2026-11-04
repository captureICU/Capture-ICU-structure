import Foundation

/// Ce qu'une photo a donné : l'étape (« Pompe 1 ») et les valeurs lues.
public struct Lecture: Sendable, Equatable, Codable {
    public let etape: EtapeDeCapture
    public var mesures: [Mesure]

    public init(etape: EtapeDeCapture, mesures: [Mesure]) {
        self.etape = etape
        self.mesures = mesures
    }
}

/// Le dossier d'un patient pour une visite : tout ce qui finira dans la note.
///
/// C'est ce que le Core remplit au fil du parcours, et ce que le module Export
/// reçoit une fois validé.
public struct Dossier: Sendable, Equatable, Codable {
    public let patient: Patient
    public let creeLe: Date
    /// Une lecture par photo, dans l'ordre de la séquence.
    public var lectures: [Lecture]
    /// La note dictée, gardée mot pour mot. `nil` tant que rien n'a été dicté.
    public var noteVocale: String?
    /// Qui a validé le dossier. `nil` = pas encore validé, donc pas exportable.
    public var validePar: String?

    public init(
        patient: Patient,
        creeLe: Date,
        lectures: [Lecture] = [],
        noteVocale: String? = nil,
        validePar: String? = nil
    ) {
        self.patient = patient
        self.creeLe = creeLe
        self.lectures = lectures
        self.noteVocale = noteVocale
        self.validePar = validePar
    }

    public var estValide: Bool { validePar != nil }
}
