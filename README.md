# Capture ICU

App iPhone qui aide le personnel des soins intensifs à documenter les signes
vitaux : photo du moniteur (OCR sur l'appareil) ou dictée, extraction des
valeurs, révision par le clinicien, note clinique en français.

**Assistant de documentation, pas outil de diagnostic.** Aucune valeur ne se
finalise sans confirmation du clinicien.

Projet intégrateur GBM8970 — Polytechnique Montréal, A2026-H2027.
Client : Institut de Cardiologie de Montréal.

## Structure

```
Core/      toute la logique — package Swift pur, testable sans Mac
  Sources/Core/
    Contrats/         un contrat par sous-système (OCR, parole, dictée, export)
    Modeles/          types partagés (VitalSigns, CapturedObservation…)
    Reconnaissance/   règles de lecture d'un moniteur
    Dictee/           texte dicté → signes vitaux
    Donnees/          format d'export JSON versionné
    Validation/       bornes physiologiques
    Pipelines/        où les sous-systèmes s'emboîtent
  Sources/CoreTestKit/  bouchons + vérifications de contrat, pour tous les tests
  Tests/CoreTests/    tests + corpus de fixtures (une photo = un test)
App/       l'app SwiftUI — écrans, Vision, Speech (à créer, voir App/LISEZ-MOI.md)
docs/      sous-systèmes, guide de tests, registre des exigences
```

**Chaque sous-système vit derrière un contrat** et a un bouchon : chaque équipe
travaille et teste sa pièce sans attendre les autres. Carte et marche à suivre :
[`docs/SOUS-SYSTEMES.md`](docs/SOUS-SYSTEMES.md).

**Une règle d'architecture, vérifiée par la CI :** `Core/` ne connaît ni
interface ni appareil. Ce qui a besoin de Vision, Speech ou SwiftUI vit dans
`App/` et passe au noyau des types simples (`OCRTextBlock`, `VitalSigns`).
C'est ce qui permet de tester toute l'intelligence du projet sous Linux, en une
minute, gratuitement.

## Démarrer

```bash
bash scripts/verifier.sh
```

Frontière du noyau, tous les tests, matrice de traçabilité : la même commande
qu'en intégration continue. Pas besoin de Mac pour le noyau — Swift s'installe sur Windows et Linux
([swift.org/install](https://www.swift.org/install/)).

## À lire

- **[`docs/SOUS-SYSTEMES.md`](docs/SOUS-SYSTEMES.md)** — qui fait quoi, où brancher sa pièce. À lire en premier.
- **[`docs/TESTS.md`](docs/TESTS.md)** — écrire un test.
- [`Core/Tests/CoreTests/Fixtures/LISEZ-MOI.md`](Core/Tests/CoreTests/Fixtures/LISEZ-MOI.md) — ajouter une photo au corpus, sans code.
- [`docs/exigences.md`](docs/exigences.md) — le registre `EX-###`.

## Vie privée

Aucune donnée patient dans ce dépôt, jamais : pas de photo, pas de nom, pas de
numéro de dossier. Le corpus ne contient que du texte anonymisé. Le `.gitignore`
refuse les images.
