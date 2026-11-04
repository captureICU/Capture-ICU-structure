# Capture ICU — règles du dépôt

Architecture : un Core + 3 modules branchés par des prises. Lire `docs/ARCHITECTURE.md`.

- `Core/Code/` et `OutilsDeTest/` ne connaissent **ni écran ni appareil** : pas de `SwiftUI`, `UIKit`, `Vision`, `Speech`, `AVFoundation`. Les modules peuvent les utiliser, seulement dans `#if canImport(...)`.
- Les modules ne s'importent jamais entre eux. Tout passe par les prises de `Core/Code/Prises/`.
- Ne jamais modifier une prise, un modèle (`Core/Code/Modeles/`), `OutilsDeTest/` ni `Package.swift` sans accord explicite de l'humain. Une prise change avec sa vérification (`VerifierLesPrises.swift`), son faux module et tous les vrais modules, dans la même PR.
- Tests : Swift Testing (`@Test`, `#expect`). Titre en français commençant par l'exigence de la spécification entre crochets : `@Test("[4.2.1-4] ...")`. Registre : `docs/exigences.md`.
- Tout module a un test qui appelle `VerifierPrise.<module>(...)`. Les tests du Core utilisent les faux modules; le test `BoutEnBout/` utilise les vrais.
- **Ne jamais modifier un test existant** pour faire passer la suite. Si l'attente doit changer, le dire à l'humain et attendre.
- Écrire le test avant le code, et le voir échouer.
- Une branche = une chose. Pas de renommage ni de réorganisation non demandés.
- Rien d'identifiable dans le dépôt : ni photo, ni audio, ni nom, ni numéro de dossier.
- L'équipe débute en programmation : code et commentaires en français, simples, sans astuce.

Commandes : `bash scripts/verifier.sh` (tout) · `bash scripts/tester.sh <ocr|transcription|export|core|bout-en-bout>`
