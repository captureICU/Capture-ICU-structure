# Registre des exigences

Les exigences viennent de la **Spécification des exigences v1.0** (livrable 1,
18 octobre 2026). Leur numéro est celui de la spécification : numéro de section,
trait d'union, référence (`4.2.1-4`). Il ne change jamais (section 9 de la spec).

Un test couvre une exigence quand son titre cite le numéro **entre crochets** :

```swift
@Test("[4.2.1-4] chaque valeur arrive dans le bon champ")
```

`scripts/tracabilite.sh` relit ce registre et tous les tests, et produit la
matrice de traçabilité. On ne la recopie jamais à la main : une exigence sans
test apparaît en **AUCUN TEST**.

Ce registre ne reprend que les exigences testables par du code. Les exigences
d'interface (5.x), de manuel et de formation (6.x) se vérifient par observation,
dans les procédures de tests (livrable 3).

## 4.1.1 Le contexte

| Réf. | Exigence | Test |
|---|---|---|
| 4.1.1-2 | L'application doit permettre l'entrée d'informations pour la note médicale | O |
| 4.1.1-3 | L'application doit permettre l'entrée d'informations pour la note infirmière | O |
| 4.1.1-4 | L'application doit structurer l'information de chaque patient | O |
| 4.1.1-5 | L'application doit pouvoir remplir les champs du logiciel Criticare | O |
| 4.1.1-6 | L'application doit générer une note infirmière | O |

## 4.2.1 Le mandat

| Réf. | Exigence | Test |
|---|---|---|
| 4.2.1-1 | Le produit doit prendre des photos | O |
| 4.2.1-2 | Le produit doit détecter les différents chiffres sur une photo | O |
| 4.2.1-3 | Le produit doit détecter les symboles des signes vitaux | O |
| 4.2.1-4 | Le produit doit associer chaque chiffre à son symbole de signe vital | O |
| 4.2.1-5 | Le produit doit enregistrer une trame audio | O |
| 4.2.1-6 | Le produit doit transcrire la trame audio en texte | O |
| 4.2.1-7 | Le produit doit valider les informations auprès de l'utilisateur | O |
| 4.2.1-8 | Le produit doit imprimer les données collectées | O |
| 4.2.1-9 | Le produit doit protéger les données collectées | O |
| 4.2.1-10 | Le produit doit distinguer les différents patients | O |

## 4.2.2 Les usages

| Réf. | Exigence | Test |
|---|---|---|
| 4.2.2-1 | Le produit doit transcrire les signes vitaux | O |
| 4.2.2-2 | Le produit doit transcrire les observations et signes physiques | O |
| 4.2.2-3 | Le produit doit générer une note médicale | O |
| 4.2.2-4 | Le produit doit générer une note infirmière | O |

## 7 Performance

| Réf. | Exigence | Test |
|---|---|---|
| 7.1-2 | Le traitement d'une image capturée ne doit pas excéder 10 secondes | M |
| 7.1-3 | La transcription d'une note vocale ne doit pas excéder 1 minute après l'enregistrement | M |
| 7.2-1 | Les valeurs affichées sur les appareils doivent être reconnues correctement dans au moins 98 % des cas | M |
| 7.2-3 | Les valeurs doivent être associées au bon paramètre dans au moins 98 % des cas | M |
| 7.2-4 | Les valeurs sous le seuil de confiance doivent laisser les cases vides dans 95 % des cas | M |
| 7.2-5 | Les valeurs hors plage doivent être signalées en rouge dans 99 % des cas | M |
| 7.2-6 | La transcription de la note vocale doit atteindre au moins 90 % d'exactitude | M |
| 7.2-7 | Les valeurs numériques prononcées doivent être transcrites correctement dans au moins 98 % des cas | M |
| 7.3-2 | Une même image ou note vocale analysée plusieurs fois donne des résultats identiques dans au moins 99 % des cas | M |

## 8 Sécurité

| Réf. | Exigence | Test |
|---|---|---|
| 8.1-2 | Aucune personne non autorisée ne doit pouvoir utiliser l'application | O |
| 8.2-1 | Le personnel doit vérifier chaque donnée avant de confirmer sa validité | O |
| 8.2-2 | Une seule personne à la fois peut ajouter, modifier ou supprimer les données d'un patient | O |
| 8.2-3 | Aucune personne non autorisée ne doit pouvoir accéder aux données des patients | O |

## Note sur le squelette

Plusieurs exigences ne sont couvertes que **sur la forme** par le squelette : la
connexion (8.1-2) est factice, l'OCR et la transcription rendent des valeurs
inventées. Les tests vérifient que le parcours respecte ces règles; les modules
réels devront ajouter des tests sur de vraies entrées (photos et audios de test,
jamais de patients). Les taux en % (section 7) se mesurent sur un corpus, au
livrable 4.
