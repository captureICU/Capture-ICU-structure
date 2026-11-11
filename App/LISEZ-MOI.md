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

## Lancer l'app (sur un Mac)

Le projet Xcode existe : `App/CaptureICU/CaptureICU.xcodeproj`. Il lit
directement les fichiers de `Ecrans/` (un fichier ajouté dans ce dossier entre
tout seul dans l'app) et branche le package local : `Core`, `ModuleOCR`,
`ModuleTranscription`, `ModuleExport`. Jamais `OutilsDeTest`.

1. Ouvrir `App/CaptureICU/CaptureICU.xcodeproj` dans Xcode.
2. Choisir un simulateur iPhone, puis ⌘R. Suivre le parcours INF ci-dessus.
3. ⌘U lance le test d'interface `UITests/ParcoursINFUITests.swift` : il joue
   tout le parcours INF (connexion → photos → formulaire → vérification → PDF)
   et garde une capture d'écran à chaque étape.

En ligne de commande :

```bash
cd App/CaptureICU
xcodebuild test -project CaptureICU.xcodeproj -scheme CaptureICU \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' CODE_SIGNING_ALLOWED=NO
```

La CI lance ce même test sur un simulateur iOS à chaque pull request vers `main`.
