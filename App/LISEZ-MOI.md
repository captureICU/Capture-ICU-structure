# App/ — les écrans iPhone

Les écrans suivent le Figma **project-v2** (style, textes traduits en français).
Ce que le squelette exige et que le Figma n'avait pas a été **ajouté dans le
même style**, sans rien retirer du Figma. Chaque ajout est marqué `AJOUTÉ` en
commentaire dans le code.

| Fichier | Figma | Ajouts |
|---|---|---|
| `Style.swift` | couleurs, boutons, champs, cartes, bandeau de démo | — |
| `CaptureICUApp.swift` | — | point d'entrée, modules branchés, état de l'app |
| `EcranConnexion.swift` | Login | indice « demo / demo » |
| `EcranCreerCompte.swift` | Create account | — |
| `EcranChoixRole.swift` | Choose a demo role | — |
| `EcranAccueilINF.swift` | INF home | carte **Patient**, carte **Vérifier et créer la note** |
| `EcranCamera.swift` | Camera capture, Photo review | appareil à photographier, « Pas de … ici », « + Ajouter une pompe » |
| `EcranFormulaire.swift` | INF form, M form sheet, Audio recording | — |
| `EcranVerification.swift` | — | **écran ajouté** : valeurs, rouge hors plage, cases à remplir, validation |
| `EcranTermine.swift` | Upload complete | variante **note infirmière** avec partage du PDF |
| `EcranAccueilM.swift` | M home | liste des formulaires téléversés |

Parcours INF : connexion (ou « Essayer sans compte ») → rôle INF → patient →
« Prendre des photos » (moniteur, pompe 1, ventilateur) → « Remplir un
formulaire » (information + audio) → « Vérifier et créer la note » → PDF.

Le rôle M est une **démo** : son formulaire n'est gardé qu'en mémoire, aucune
note médicale n'est encore produite.

Pour l'instant, la caméra et le micro sont factices (photos et audio inventés).
Les brancher viendra avec les modules OCR et Transcription.

> Ces écrans n'ont pas encore été compilés : le projet Xcode n'existe pas
> encore. La première compilation sur le Mac mini dira ce qui est à corriger.

## Créer le projet Xcode (une seule fois, sur un Mac)

1. Xcode → **File → New → Project… → iOS → App**.
   Nom : `CaptureICU`. Interface : SwiftUI. Langage : Swift. Tests : cochés.
   Enregistrer **dans ce dossier `App/`**, sans créer de dépôt git (le dépôt existe déjà).
   Xcode crée `App/CaptureICU/`, avec `CaptureICU.xcodeproj` dedans.
2. Supprimer les deux fichiers générés (`CaptureICUApp.swift`, `ContentView.swift`).
   Glisser tous les fichiers de `Ecrans/` dans le projet (sans « Copy items »).
3. **File → Add Package Dependencies… → Add Local…** → choisir la **racine du
   dépôt** (le dossier qui contient `Package.swift`). Cocher les bibliothèques
   `Core`, `ModuleOCR`, `ModuleTranscription` et `ModuleExport` pour la cible
   `CaptureICU`. Jamais `OutilsDeTest`.
4. Lancer sur le simulateur (⌘R) et suivre le parcours INF ci-dessus.
5. Faire une PR avec `App/CaptureICU/`. Dès qu'il existe, la CI lance
   aussi les tests de l'app sur un simulateur iOS.
