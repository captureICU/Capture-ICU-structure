# Registre des exigences

Chaque exigence porte un identifiant `EX-###` qui ne change jamais et ne se
réutilise pas. Cet identifiant est le fil qui relie les quatre livrables :

```
énoncé du client  →  EX-###  →  élément de design  →  test  →  résultat de test
   (livrable 1)                    (livrable 2)     (livrable 3) (livrable 4)
```

Un test cite l'exigence qu'il couvre dans son titre :

```swift
@Test("EX-001 : lit la fréquence cardiaque étiquetée FC")
```

`scripts/tracabilite.sh` relit ce registre et tous les tests, et produit la
matrice de traçabilité. La matrice n'est donc jamais à recopier à la main, et
elle ne peut pas mentir : une exigence sans test le dit.

> **Statut : provisoire.** Ces exigences sont des amorces destinées à faire
> fonctionner le harnais. Elles seront remplacées par les exigences réelles
> issues du document de spécifications (livrable 1). Les numéros déjà utilisés
> dans les tests devront suivre.

## Exigences fonctionnelles

| ID | Exigence | Source | Statut |
|---|---|---|---|
| EX-001 | Extraire la fréquence cardiaque d'une photo de moniteur de chevet. | à confirmer | provisoire |
| EX-002 | Extraire la tension artérielle systolique et diastolique. | à confirmer | provisoire |
| EX-003 | Extraire la saturation en oxygène. | à confirmer | provisoire |
| EX-004 | Aucune valeur n'est finalisée sans confirmation explicite du clinicien. | énoncé du client | provisoire |
| EX-005 | Une valeur hors des bornes physiologiques plausibles est signalée au clinicien. | à confirmer | provisoire |
| EX-006 | Extraire les signes vitaux d'une dictée vocale. | à confirmer | provisoire |
| EX-007 | Exporter une capture dans un format structuré et versionné (JSON), relisible sans perte. | énoncé du client (format XML/JSON), à confirmer | provisoire |

## Exigences non fonctionnelles

| ID | Exigence | Source | Statut |
|---|---|---|---|
| EX-101 | Aucune donnée identifiable ne quitte l'appareil. | à confirmer avec le client | provisoire |
| EX-102 | La lecture d'une photo de moniteur prend moins de 3 secondes. | à confirmer avec le client | provisoire |

## Comment ajouter une exigence

1. Prendre le prochain numéro libre (100+ pour les non fonctionnelles). Ne jamais
   réutiliser un numéro retiré : la traçabilité historique en dépend.
2. Écrire l'exigence en une phrase, au présent, vérifiable. « L'app est rapide »
   n'est pas une exigence; « l'extraction d'une photo prend moins de 3 secondes »
   en est une.
3. Nommer la source : quelle phrase de l'énoncé, quelle réunion avec le client.
4. Écrire au moins un test qui la cite. Une exigence sans test apparaît en rouge
   dans la matrice.
