# Module 3 · Données & export

**Votre travail :** organiser le dossier validé du patient et produire la note
infirmière en PDF.

| | |
|---|---|
| Reçoit | un `Dossier` validé : patient, valeurs de chaque appareil, note dictée, qui a validé |
| Rend | un `DocumentExporte` : nom de fichier, type, contenu (le PDF) |
| Votre code | `Code/ExportNoteInfirmiere.swift` (et `Code/PDFSimple.swift`) |
| Vos tests | `Tests/ExportTests.swift` |
| Lancer vos tests | `bash scripts/tester.sh export` |
| Votre prise | `Core/Code/Prises/PriseExport.swift` |

## Aujourd'hui

`ExportNoteInfirmiere.swift` produit déjà un vrai PDF, mais très simple : une
liste de lignes (patient, valeurs, note). `PDFSimple.swift` fabrique le PDF;
vous n'avez pas besoin de comprendre son intérieur pour vous en servir.

## Les promesses de votre prise

Vérifiées automatiquement par le test « respecte sa prise » :

1. Dossier pas encore validé → lancer `ErreurExport.dossierNonValide`.
2. Un nom de fichier et un contenu non vides.
3. Le même dossier donne toujours exactement le même document.

## Pistes pour la suite

1. **Suivre le formulaire ICM211** (« Notes d'observations de l'infirmière »,
   soins intensifs chirurgicaux) : sections Neuro, Respiratoire, Circulation,
   Urinaire, Gastro-intestinale, signes vitaux horaires, observations. Le
   formulaire vierge est dans le dossier de l'équipe (pas dans ce dépôt).
2. **Un format structuré** en plus du PDF (JSON), pour l'envoi futur vers
   Criticare. Le `Dossier` sait déjà se convertir en JSON (`Codable`).
3. **Un plus beau PDF** : dans l'app, `UIGraphicsPDFRenderer` permet des
   tableaux et des cases à cocher. Gardez `PDFSimple` pour les tests qui
   tournent sans iPhone.
