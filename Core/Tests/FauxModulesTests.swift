import Core
import OutilsDeTest
import Testing

// Les tests du Core utilisent des faux modules. Ces trois tests prouvent que les
// faux respectent les mêmes prises que les vrais : sans eux, un faux module
// trop gentil ferait passer des tests qui échoueraient avec le vrai.

@Suite("Les faux modules respectent les prises")
struct FauxModulesTests {
    @Test("FauxOCR respecte la prise OCR")
    func fauxOCR() async {
        let problemes = await VerifierPrise.ocr(FauxOCR())
        #expect(problemes.isEmpty, "\(problemes)")
    }

    @Test("FauxTranscription respecte la prise Transcription")
    func fauxTranscription() async {
        let problemes = await VerifierPrise.transcription(FauxTranscription())
        #expect(problemes.isEmpty, "\(problemes)")
    }

    @Test("FauxExport respecte la prise Export")
    func fauxExport() {
        let problemes = VerifierPrise.export(FauxExport())
        #expect(problemes.isEmpty, "\(problemes)")
    }
}
