# App — à créer

Le projet Xcode n'existe pas encore. La CI le sait et saute le job macOS; elle
s'activera toute seule au premier commit contenant `App/CaptureICU.xcodeproj`.

## Créer le projet (une fois, sur un Mac)

1. Xcode → **File ▸ New ▸ Project ▸ iOS ▸ App**
2. Product Name **`CaptureICU`**, SwiftUI, Swift, cocher **Include Tests**
3. Enregistrer dans **`App/`** → on doit obtenir `App/CaptureICU.xcodeproj` (chemin exact attendu par la CI)
4. **File ▸ Add Package Dependencies ▸ Add Local…** → choisir `Core/`, ajouter la bibliothèque `Core` à la cible de l'app, et **`CoreTestKit` à la cible de tests seulement**
5. `xcodebuild test` passe en local → PR

## Ce qui va ici

Écrans, appel à Vision (OCR), appel à Speech, stockage, PDF. `App/` traduit le
monde réel en types du noyau et affiche ce que le noyau renvoie.

**Aucune règle métier.** Une expression régulière ou une borne physiologique dans
un `View` est au mauvais endroit : elle devient intestable en une minute et coûte
dix minutes de runner macOS. Si votre code peut s'écrire sans mentionner d'écran
ni d'appareil, il va dans `Core/`.

## Brancher un adaptateur réel

Les protocoles existent déjà dans `Core/Sources/Core/Contrats/`. Un adaptateur
traduit un framework Apple vers ce protocole, et rien de plus. Esquisse pour
l'OCR (non compilée, à valider sur le Mac) :

```swift
import Core
import Vision

struct VisionTextRecognizer: TextRecognizer {
    func recognizeText(in image: CapturedImage) async throws -> [OCRTextBlock] {
        guard !image.data.isEmpty else { throw TextRecognitionError.emptyImage }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["fr-CA", "en-US"]
        do {
            try VNImageRequestHandler(data: image.data).perform([request])
        } catch {
            throw TextRecognitionError.unreadableImage
        }

        return (request.results ?? []).compactMap { observation in
            guard let best = observation.topCandidates(1).first else { return nil }
            let box = observation.boundingBox // origine en bas à gauche chez Vision
            return OCRTextBlock(
                text: best.string,
                confidence: Double(best.confidence),
                boundingBox: NormalizedRect(x: box.minX, y: box.minY, width: box.width, height: box.height)
            )
        }
    }
}
```

Son test de contrat, dans la cible de tests de l'app. L'image est **générée
dans le test** (texte « FC 90 » dessiné avec `UIGraphicsImageRenderer`), jamais
une photo de patient :

```swift
import Core
import CoreTestKit
import Testing
@testable import CaptureICU

@Test("EX-102 : l'OCR Vision respecte le contrat")
func visionHonoursContract() async {
    let violations = await TextRecognizerContract.check(VisionTextRecognizer(), sample: imageSynthetique("FC 90"))
    #expect(violations.isEmpty, "\(violations)")
}
```

Même chose pour la parole : `SpeechTranscriber` + `SpeechTranscriberContract`,
avec un fichier audio produit par synthèse vocale.

L'app construit les pipelines avec les vrais adaptateurs :
`MonitorCapturePipeline(recognizer: VisionTextRecognizer())`. Les aperçus SwiftUI
et les tests de ViewModel leur passent les bouchons.

## À prévoir dès le départ

- **Les autres services externes derrière un protocole** (caméra, stockage),
  injectés par `init`, avec une version bouchon pour les tests.
- **Un bouton d'export des blocs OCR** dans un écran de débogage, qui écrit le
  `blocks.json` du corpus de fixtures. Sans lui, les fixtures se transcrivent à
  la main et perdent le bruit réel de l'OCR.
