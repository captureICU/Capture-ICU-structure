# Corpus de fixtures

Une photo de moniteur devient un test permanent. **Aucun Swift à écrire** : un
dossier, deux fichiers JSON.

```
Fixtures/
  moniteur-philips-mx800-01/
    blocks.json      ce que l'OCR a lu
    expected.json    ce que l'extraction doit en tirer
```

Nom du dossier : `moniteur-` ou `pompe-`, puis marque, modèle, numéro. Minuscules,
tirets, pas d'accent.

## 1. `blocks.json`

```json
{
  "description": "Philips MX800, écran en contre-jour, photo de trois quarts",
  "source": "Photo prise à l'ICM le 2026-10-14. Recadrée sur l'écran, aucune donnée patient visible.",
  "blocks": [
    { "text": "FC 90", "confidence": 0.96, "boundingBox": { "x": 0.05, "y": 0.14, "width": 0.18, "height": 0.11 } },
    { "text": "PA 111/51", "confidence": 0.91, "boundingBox": null }
  ]
}
```

- `description` : ce qui rend la photo **difficile** (reflet, angle, écran masqué).
- `source` : d'où elle vient, comment elle a été anonymisée. Obligatoire.
- `blocks` : un par bloc de texte, dans l'ordre à l'écran. `boundingBox` peut être
  `null`. Recopié à la main pour commencer; plus tard, exporté depuis l'app.

## 2. `expected.json` — les sept champs, toujours

```json
{
  "heartRate": 90,
  "systolicBP": 111,
  "diastolicBP": 51,
  "meanArterialPressure": null,
  "oxygenSaturation": null,
  "respiratoryRate": null,
  "temperatureCelsius": null
}
```

Une valeur = l'extraction doit la produire. **`null` = l'extraction ne doit rien
produire pour ce champ** — c'est une assertion à part entière, pas « on s'en
fiche ». Une clé manquante ou mal écrite fait échouer le test avec un message
clair.

## 3. `cd Core && swift test`

Le cas apparaît tout seul dans le rapport.

## Deux règles

- **`blocks.json` ne se modifie jamais.** C'est une observation. Si l'OCR change, on
  ajoute un cas.
- **`expected.json` ne change que pour une raison écrite dans la PR** : un champ
  vient d'être implémenté (`null` devient une valeur), ou la valeur était mal lue.
  Sinon, c'est le code qui est faux.

## Vie privée

Texte seulement, jamais d'image. Rien qui identifie un patient : ni nom, ni
numéro de dossier, ni date de naissance, ni numéro de chambre. En cas de doute,
on ne met pas le cas.
