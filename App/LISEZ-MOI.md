# App/ — les écrans iPhone

Les écrans du squelette sont dans `Ecrans/` :

| Fichier | Étape |
|---|---|
| `CaptureICUApp.swift` | point d'entrée; c'est ici qu'on choisit les modules branchés |
| `EcranConnexion.swift` | 1 · connexion (factice : demo / demo) |
| `EcranPatients.swift` | 2 · choix du patient |
| `EcranSession.swift` | 3 à 6 · photos, note vocale, validation, PDF |

Pour l'instant, les boutons envoient des photos et un audio factices. Brancher
la vraie caméra et le vrai micro viendra avec les modules OCR et Transcription.

> Ces écrans n'ont pas encore été compilés : le projet Xcode n'existe pas
> encore. La première compilation sur le Mac mini dira ce qui est à corriger.

## Créer le projet Xcode (une seule fois, sur un Mac)

1. Xcode → **File → New → Project… → iOS → App**.
   Nom : `CaptureICU`. Interface : SwiftUI. Langage : Swift. Tests : cochés.
   Enregistrer **dans ce dossier `App/`**, sans créer de dépôt git (le dépôt existe déjà).
   Xcode crée `App/CaptureICU/`, avec `CaptureICU.xcodeproj` dedans.
2. Supprimer les deux fichiers générés (`CaptureICUApp.swift`, `ContentView.swift`).
   Glisser les quatre fichiers de `Ecrans/` dans le projet (sans « Copy items »).
3. **File → Add Package Dependencies… → Add Local…** → choisir la **racine du
   dépôt** (le dossier qui contient `Package.swift`). Cocher les bibliothèques
   `Core`, `ModuleOCR`, `ModuleTranscription` et `ModuleExport` pour la cible
   `CaptureICU`. Jamais `OutilsDeTest`.
4. Lancer sur le simulateur (⌘R). Parcours : demo / demo → P-001 → trois photos
   → dicter → valider → partager le PDF.
5. Faire une PR avec `App/CaptureICU/`. Dès qu'il existe, la CI lance
   aussi les tests de l'app sur un simulateur iOS.
