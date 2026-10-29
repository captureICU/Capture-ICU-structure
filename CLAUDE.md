# Capture ICU — règles du dépôt

- `Core/` ne connaît **ni interface ni appareil** : pas de `SwiftUI`, `UIKit`, `Vision`, `Speech`. Ce code va dans `App/`.
- Tests : Swift Testing (`@Test`, `#expect`). Titre en français, commençant par l'exigence couverte : `@Test("EX-001 : ...")`. Registre : `docs/exigences.md`.
- **Ne jamais modifier un test existant ni un `expected.json` existant** pour faire passer la suite. Si l'attente doit changer, le dire à l'humain et attendre.
- Écrire le test avant le code, et le voir échouer.
- Une branche = une chose. Pas de renommage ni de réorganisation non demandés.
- Rien d'identifiable dans le dépôt : ni photo, ni nom, ni numéro de dossier.
- Chaque sous-système vit derrière un protocole de `Core/Sources/Core/Contrats/`. Ne jamais modifier un contrat, un modèle ni `CoreTestKit` sans accord explicite de l'humain (`docs/SOUS-SYSTEMES.md`).
- Toute implémentation d'un contrat a un test qui appelle sa vérification (`TextRecognizerContract.check`, etc.). Les tests utilisent les bouchons de `CoreTestKit`; `CoreTestKit` n'est jamais lié à l'app livrée.
- `Fixtures/export/v1-exemple.json` est figé. Changer le format = nouvelle version + nouvel exemple.
- Une valeur clinique est un `CapturedObservation`, jamais un nombre nu. `requiresReview` reste `true` sans geste du clinicien.

Commande : `bash scripts/verifier.sh` (frontière + tests + matrice)
Guides : `docs/SOUS-SYSTEMES.md` · `docs/TESTS.md`
