import Core
import Foundation
import ModuleExport
import OutilsDeTest
import Testing

// Les tests du module Export. Lancer : bash scripts/tester.sh export
//
// Un test se lit en trois temps :
//   1. préparer   ce qu'il faut (un dossier validé)
//   2. agir       appeler le module
//   3. vérifier   avec #expect : « je m'attends à ce que… »
//
// Le titre commence par le numéro de l'exigence de la spécification entre
// crochets, par exemple [4.2.2-4]. C'est ce qui remplit la matrice de traçabilité.

@Suite("Module Export")
struct ExportTests {
    // Ce test doit TOUJOURS passer. S'il échoue, votre module ne se branche
    // plus correctement sur le Core : lisez le message, il dit quelle promesse
    // n'est pas tenue.
    @Test("[4.2.1-8] le module Export respecte sa prise")
    func respecteLaPrise() {
        let problemes = VerifierPrise.export(ExportNoteInfirmiere())

        #expect(problemes.isEmpty, "\(problemes)")
    }

    @Test("[4.2.2-4] la note infirmière est un PDF")
    func cEstUnPDF() throws {
        // 1. préparer
        let dossier = Exemples.dossierValide

        // 2. agir
        let document = try ExportNoteInfirmiere().exporter(dossier)

        // 3. vérifier
        #expect(document.typeMIME == "application/pdf")
        #expect(document.nomFichier == "note-infirmiere-P-001.pdf")
        #expect(document.contenu.starts(with: Data("%PDF".utf8)))
    }

    @Test("[4.2.2-4] la note contient les valeurs validées")
    func contientLesValeurs() throws {
        let document = try ExportNoteInfirmiere().exporter(Exemples.dossierValide)

        #expect(document.contenu.contientTexte("P-001"))
        #expect(document.contenu.contientTexte("FC : 88 bpm"))
        #expect(document.contenu.contientTexte("Temp. : 36.8 °C"))
        #expect(document.contenu.contientTexte("Débit : 5 mL/h"))
    }

    @Test("[4.2.1-6] la note dictée apparaît mot pour mot")
    func contientLaNote() throws {
        let document = try ExportNoteInfirmiere().exporter(Exemples.dossierValide)

        #expect(document.contenu.contientTexte(Exemples.note))
    }

    @Test("[7.3-2] le même dossier donne toujours le même PDF")
    func memeDossierMemePDF() throws {
        let premier = try ExportNoteInfirmiere().exporter(Exemples.dossierValide)
        let second = try ExportNoteInfirmiere().exporter(Exemples.dossierValide)

        #expect(premier == second)
    }

    @Test("Une note très longue tient sur plusieurs pages sans rien perdre")
    func noteTresLongue() throws {
        var dossier = Exemples.dossierValide
        dossier.noteVocale = Array(repeating: "Patiente confortable.", count: 400).joined(separator: " ") + " FIN"

        let document = try ExportNoteInfirmiere().exporter(dossier)

        #expect(document.contenu.contientTexte("/Count 3"))  // trois pages
        #expect(document.contenu.contientTexte("FIN"))
    }

    // ── VOTRE PROCHAIN TEST ──────────────────────────────────────────────
    // Copiez ce modèle, enlevez les //, changez le titre et le contenu.
    // Lancez-le : il doit d'abord ÉCHOUER, puis passer une fois votre code écrit.
    //
    // @Test("[4.2.2-4] la note suit les sections du formulaire ICM211")
    // func sectionsICM211() throws {
    //     let document = try ExportNoteInfirmiere().exporter(Exemples.dossierValide)
    //     #expect(document.contenu.contientTexte("RESPIRATOIRE"))
    //     #expect(document.contenu.contientTexte("CIRCULATION"))
    // }
}
