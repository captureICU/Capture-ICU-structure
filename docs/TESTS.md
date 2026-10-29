# Écrire un test

Pour toute l'équipe, y compris ceux qui n'en ont jamais écrit. Lecture : cinq minutes.

## Pourquoi

- Le livrable 3 = procédures de tests, le livrable 4 = résultats de tests, et la
  matrice de traçabilité est évaluée deux fois. Chaque test écrit aujourd'hui est
  une ligne qu'on n'inventera pas en février.
- On est cinq sur le même code. Un test rouge, c'est apprendre en deux minutes que
  quelqu'un a cassé quelque chose, plutôt qu'en décembre devant le client.
- Une partie du code sera écrite avec une IA. Plausible n'est pas correct; les
  tests sont ce qui fait la différence sans relire chaque ligne.

## Essayer

```bash
bash scripts/verifier.sh
```

(Ou seulement les tests : `cd Core && swift test`.)

Ouvrez `Core/Tests/CoreTests/MonitorExtractorTests.swift`, changez `90` en `91`,
relancez. Lisez le message d'échec. Remettez `90`. C'est tout ce qu'un test fait.

## Anatomie

```swift
@Test("EX-001 : lit la fréquence cardiaque étiquetée FC")
func readsFrenchHeartRateLabel() {
    let text = "FC 90"                                  // 1. une entrée
    let vitals = MonitorExtractor().extract(from: text) // 2. on appelle le code
    #expect(vitals.heartRate.value == 90)               // 3. on vérifie
}
```

- Le **titre** est en français, au présent, et commence par le numéro de l'exigence
  couverte (`docs/exigences.md`). C'est ce qui apparaît dans le rapport de CI et
  dans la matrice de traçabilité.
- Le **nom de fonction** est en anglais comme le code. Il ne sert qu'au compilateur.
- `#expect(...)` vérifie. Faux = le test échoue et montre les valeurs réelles.

`MonitorExtractorTests.swift` est commenté pour servir de gabarit : copiez-le.

Assertions utiles :

```swift
#expect(x == 90)                    // égalité
#expect(x == nil)                   // absence — aussi importante qu'une valeur
#expect(issues.isEmpty)             // liste vide
#expect(observation.requiresReview) // booléen
```

Plusieurs valeurs sans copier-coller :

```swift
@Test("EX-005 : saturation hors bornes", arguments: [0, 49, 101])
func outOfRange(value: Int) { ... }
```

## Où va mon test ?

| Je teste… | Où | Coût |
|---|---|---|
| une règle de lecture, de validation, de mise en forme | `Core/Tests/CoreTests/` | 1 min, partout |
| que mon implémentation respecte son contrat | une ligne : `XxxContract.check(...)` — voir [`SOUS-SYSTEMES.md`](SOUS-SYSTEMES.md) | 1 min |
| que ma pièce s'emboîte avec les autres | `PipelineTests.swift`, avec les bouchons de `CoreTestKit` | 1 min, partout |
| une photo de moniteur qui doit donner telles valeurs | `Core/Tests/CoreTests/Fixtures/` — **aucun code**, deux JSON | 1 min |
| un écran, un bouton | `App/` (tests Xcode) | 10 min, macOS, sur PR |

Dans le doute : le noyau. Si un test a besoin d'un écran pour exister, la logique
est probablement au mauvais endroit.

**Le corpus de photos est le test le plus fréquent du projet** et ne demande pas
de Swift : → [`Fixtures/LISEZ-MOI.md`](../Core/Tests/CoreTests/Fixtures/LISEZ-MOI.md).

## Le cycle

```
1. git checkout -b extraction-tension
2. écrire le test  → swift test → ROUGE   ← obligatoire
3. écrire le code  → swift test → VERT
4. push, pull request, coller la sortie des tests
5. quelqu'un d'autre relit et fusionne
```

**Voir le rouge une fois n'est pas facultatif.** Un test qu'on n'a jamais vu
échouer ne prouve rien — il peut ne rien vérifier du tout. C'est le piège
classique du test écrit après coup, et surtout du test écrit par une IA.

## La matrice de traçabilité se génère

```bash
bash scripts/tracabilite.sh
```

Relit `docs/exigences.md` et tous les titres de tests, et sort le tableau
exigence → nombre de tests. Aussi dans le résumé de chaque exécution de CI.
Jamais recopiée à la main, donc jamais périmée. Une exigence sans test apparaît
en rouge.

## Trois règles

1. **On ne modifie pas un test existant pour faire passer la CI.** Devant un
   rouge, la tentation est d'ajuster la valeur attendue. Deux raisons légitimes
   seulement, à écrire dans la PR : un champ vient d'être implémenté, ou la
   valeur attendue était fausse. Sinon, c'est le code qui est faux.
2. **Pas de code sans test.** Si vous ne pouvez pas écrire un test qui échoue
   avant votre changement, le changement ne fait rien ou est au mauvais endroit.
3. **Rien d'identifiable dans le dépôt.** Pas de photo, pas de nom, pas de numéro
   de dossier, ni dans le code, ni dans les fixtures, ni dans une capture d'écran.

## Pas encore là, volontairement

Projet Xcode (`App/LISEZ-MOI.md`), lint/format automatiques, tests d'interface,
tests de mutation. Dans cet ordre, quand le besoin arrivera.
