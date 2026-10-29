# Sous-systèmes — où brancher votre pièce

Quatre sous-systèmes, une règle : **chacun vit derrière un contrat.** Un contrat
dit ce qui entre, ce qui sort et ce qui arrive en cas d'échec. Tant que vous le
respectez, vous changez tout ce que vous voulez à l'intérieur de votre pièce,
et rien d'autre ne casse.

Les contrats sont dans `Core/Sources/Core/Contrats/`. Lisez celui de votre
sous-système en premier : c'est un seul fichier, commenté.

## La carte

| Sous-système | Contrat | Ce que vous écrivez | Où | Bouchon pour les autres | Responsable |
|---|---|---|---|---|---|
| **Reconnaissance de caractères** (OCR) | `TextRecognizer` | l'adaptateur Vision | `App/` | `FakeTextRecognizer` | *À REMPLIR* |
| | | les règles de lecture (« FC 90 » → 90) | `Core/Sources/Core/Reconnaissance/` | — | *À REMPLIR* |
| **Parole** (audio → texte) | `SpeechTranscriber` | l'adaptateur Speech | `App/` | `FakeSpeechTranscriber` | *À REMPLIR* |
| **Voix / dictée** (texte → signes vitaux) | `DictationInterpreter` | l'interprète | `Core/Sources/Core/Dictee/` | — (code pur, on teste le vrai) | *À REMPLIR* |
| **Compatibilité des données** (export) | `RecordCodec` | le format JSON, son versionnage | `Core/Sources/Core/Donnees/` | — (code pur) | *À REMPLIR* |
| Contrats, modèles, pipelines, CI | — | — | `Contrats/`, `Modeles/`, `Pipelines/`, `CoreTestKit/` | — | Thomas |

Les pipelines (`Core/Sources/Core/Pipelines/`) sont l'endroit où les pièces
s'emboîtent : photo → OCR → extraction → validation, et audio → transcription →
interprétation → validation. Ils ne connaissent que les contrats.

## Le principe des bouchons

Un **bouchon** (en anglais *fake*) est une fausse implémentation d'un contrat :
`FakeTextRecognizer(lines: ["FC 90"])` « lit » toujours « FC 90 », sans image.

C'est ce qui vous rend indépendants. L'équipe dictée teste son interprète sans
micro. L'équipe extraction teste ses règles sans Vision. Personne n'attend
personne, et tout tourne sous Linux en quelques secondes.

Les bouchons sont dans `Core/Sources/CoreTestKit/`, avec des entrées toutes
prêtes (`SampleInputs.image`, `SampleInputs.audio`, `SampleInputs.record`).

## Quatre sortes de tests

| Sorte | Question posée | Exemple | Fichier |
|---|---|---|---|
| **Unitaire** | Ma fonction fait-elle la bonne chose ? | « FC 90 » donne 90 | `MonitorExtractorTests.swift` |
| **Contrat** | Mon implémentation tient-elle les promesses du contrat ? | image vide → erreur `emptyImage` | `ContractTests.swift` |
| **Intégration avec bouchons** | Ma pièce s'emboîte-t-elle avec les autres ? | photo « FC 300 » → anomalie signalée | `PipelineTests.swift` |
| **Corpus et format figé** | Rien de ce qui marchait n'a-t-il régressé ? | `moniteur-*/`, `export/v1-exemple.json` | `MonitorCorpusTests.swift`, `RecordFormatTests.swift` |

Les tests de bout en bout sur un vrai iPhone viennent après, peu nombreux, dans `App/`.

## Brancher votre implémentation, pas à pas

1. **Lire le contrat** de votre sous-système dans `Contrats/`.
2. **Écrire votre implémentation** (un `struct` qui adopte le protocole).
3. **Lui faire passer la vérification de contrat.** Une ligne, toujours la même :

   ```swift
   @Test("EX-102 : l'OCR Vision respecte le contrat")
   func visionHonoursContract() async {
       let violations = await TextRecognizerContract.check(VisionTextRecognizer(), sample: imageDeTest)
       #expect(violations.isEmpty, "\(violations)")
   }
   ```

   Vérifications disponibles : `TextRecognizerContract`, `SpeechTranscriberContract`,
   `DictationInterpreterContract`, `RecordCodecContract`. Chacune renvoie la
   liste des promesses non tenues, en français.
4. **Écrire vos tests unitaires** (règles internes) : `docs/TESTS.md`.
5. **Lancer la commande de l'équipe**, puis ouvrir la PR :

   ```bash
   bash scripts/verifier.sh
   ```

Le bouchon passe la même vérification que votre vrai service. C'est ce qui
garantit que les tests des autres équipes, écrits avec le bouchon, restent vrais
avec votre code.

## Changer un contrat

Un contrat est partagé : le modifier touche tout le monde. Donc :

1. Ouvrir une *issue* qui explique le besoin, avant d'écrire du code.
2. Le responsable des contrats (Thomas) valide. GitHub l'impose : `.github/CODEOWNERS`
   exige son approbation sur `Contrats/`, `Modeles/`, `CoreTestKit/` et `Package.swift`.
3. Une seule PR met à jour, ensemble : le contrat, sa vérification dans
   `CoreTestKit`, le bouchon, et toutes les implémentations.

**Cas particulier, le format d'export.** Ajouter un champ optionnel est
compatible. Renommer, retirer ou changer le type d'un champ demande une nouvelle
version : incrémenter `CaptureRecord.currentSchemaVersion`, ajouter
`export/v2-exemple.json`, et **ne jamais modifier `v1-exemple.json`**. Les
documents v1 déjà exportés doivent rester lisibles.
