import Core
import Foundation

// VÉRIFIER LES PRISES — les promesses de Core/Code/Prises/, en code.
//
// Une seule vérification par prise, utilisée par TOUS ceux qui s'y branchent :
// le faux module (tests du Core) et le vrai module (tests du module). Si les
// deux passent la même vérification, les tests écrits avec le faux restent
// valables avec le vrai.
//
// Chaque fonction rend la liste des promesses non tenues, en français.
// Liste vide = prise respectée. Dans un test :
//
//     let problemes = await VerifierPrise.ocr(OCR())
//     #expect(problemes.isEmpty, "\(problemes)")

public enum VerifierPrise {

    // MARK: - OCR

    public static func ocr(_ module: some PriseOCR, photo: Photo = Exemples.photo) async -> [String] {
        var problemes: [String] = []

        do {
            _ = try await module.lire(Exemples.photoVide, appareil: .moniteur)
            problemes.append("photo vide : aucune erreur, ErreurOCR.photoVide attendue")
        } catch let erreur as ErreurOCR where erreur == .photoVide {
            // promesse tenue
        } catch {
            problemes.append("photo vide : lance \(error), ErreurOCR.photoVide attendue")
        }

        for appareil in Appareil.allCases {
            let mesures: [Mesure]
            do {
                mesures = try await module.lire(photo, appareil: appareil)
            } catch {
                problemes.append("\(appareil.nom) : lance \(error) sur la photo d'exemple")
                continue
            }

            var dejaVus = Set<Parametre>()
            for mesure in mesures {
                let nom = mesure.parametre.abreviation
                if !appareil.parametres.contains(mesure.parametre) {
                    problemes.append("\(appareil.nom) : \(nom) n'appartient pas à cet appareil")
                }
                if !dejaVus.insert(mesure.parametre).inserted {
                    problemes.append("\(appareil.nom) : \(nom) rendu deux fois")
                }
                if !(0.0 ... 1.0).contains(mesure.confiance) {
                    problemes.append("\(appareil.nom) : confiance de \(nom) = \(mesure.confiance), doit être entre 0 et 1")
                }
                if mesure.corrigeeParInfirmiere {
                    problemes.append("\(appareil.nom) : \(nom) marquée corrigée, seule l'infirmière corrige")
                }
            }
        }

        return problemes
    }

    // MARK: - Transcription

    public static func transcription(_ module: some PriseTranscription, audio: Audio = Exemples.audio) async -> [String] {
        var problemes: [String] = []

        do {
            _ = try await module.transcrire(Exemples.audioVide)
            problemes.append("audio vide : aucune erreur, ErreurTranscription.audioVide attendue")
        } catch let erreur as ErreurTranscription where erreur == .audioVide {
            // promesse tenue
        } catch {
            problemes.append("audio vide : lance \(error), ErreurTranscription.audioVide attendue")
        }

        do {
            let texte = try await module.transcrire(audio)
            if texte.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                problemes.append("audio d'exemple : texte vide")
            }
        } catch {
            problemes.append("audio d'exemple : lance \(error)")
        }

        return problemes
    }

    // MARK: - Export

    public static func export(_ module: some PriseExport) -> [String] {
        var problemes: [String] = []

        do {
            _ = try module.exporter(Exemples.dossierNonValide)
            problemes.append("dossier non validé : exporté quand même, ErreurExport.dossierNonValide attendue")
        } catch let erreur as ErreurExport where erreur == .dossierNonValide {
            // promesse tenue
        } catch {
            problemes.append("dossier non validé : lance \(error), ErreurExport.dossierNonValide attendue")
        }

        do {
            let document = try module.exporter(Exemples.dossierValide)
            if document.nomFichier.isEmpty {
                problemes.append("nom de fichier vide")
            }
            if document.contenu.isEmpty {
                problemes.append("contenu vide")
            }
            if let encore = try? module.exporter(Exemples.dossierValide), encore != document {
                problemes.append("le même dossier donne deux documents différents")
            }
        } catch {
            problemes.append("dossier validé : lance \(error)")
        }

        return problemes
    }
}
