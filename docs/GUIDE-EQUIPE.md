# Guide de l'équipe

Tout ce qu'il faut pour travailler sur votre module, même si vous débutez.
Lisez d'abord [ARCHITECTURE.md](ARCHITECTURE.md) (5 minutes).

## 1. Ouvrir le projet

Le code est en Swift. Choisissez **une** des trois façons :

**A. GitHub Codespaces (recommandé sur Windows, rien à installer)**
1. Sur la page du dépôt GitHub : bouton vert **Code** → onglet **Codespaces** →
   **Create codespace on main**.
2. Attendre quelques minutes la première fois : un éditeur s'ouvre dans le
   navigateur, avec Swift déjà installé.
3. Le terminal est en bas de l'écran. C'est là qu'on tape les commandes.

**B. Le Mac mini de l'équipe**, par SSH (voir le guide de connexion Tailscale),
puis `git clone` du dépôt.

**C. Votre propre Mac**, avec Xcode installé, puis `git clone` du dépôt.

## 2. Lancer les tests

Dans le terminal, à la racine du dépôt :

```bash
bash scripts/tester.sh ocr            # seulement les tests de votre module
bash scripts/verifier.sh              # tout, avant d'ouvrir une pull request
```

Remplacez `ocr` par `transcription`, `export`, `core` ou `bout-en-bout`.

À la fin, Swift affiche le résultat :

```
✔ Test "[4.2.1-2] le moniteur donne une fréquence cardiaque" passed
✔ Suite "Module OCR" passed
```

Un **✘** veut dire qu'un test échoue. Le message en dessous dit lequel,
dans quel fichier, à quelle ligne, et ce qui était attendu.

## 3. Lire un test

Ouvrez `Modules/<votre module>/Tests/`. Chaque test a la même forme :

```swift
@Test("[4.2.1-2] le moniteur donne une fréquence cardiaque")   // titre + exigence
func moniteurDonneUneFrequence() async throws {
    let photo = Exemples.photo                                   // 1. préparer
    let mesures = try await OCR().lire(photo, appareil: .moniteur) // 2. agir
    #expect(mesures.contains(where: { $0.parametre == .frequenceCardiaque })) // 3. vérifier
}
```

- `[4.2.1-2]` est le numéro de l'exigence dans la spécification
  ([exigences.md](exigences.md)). Il remplit la matrice de traçabilité
  automatiquement.
- `#expect(...)` veut dire « je m'attends à ce que ce soit vrai ».
- `try #require(...)` veut dire « ceci doit exister, sinon on arrête le test ».

## 4. Écrire votre code, test d'abord

C'est la méthode de l'équipe, à chaque changement :

1. **Écrire le test** de ce que vous voulez obtenir. En bas de votre fichier de
   tests, un modèle commenté « VOTRE PROCHAIN TEST » est prêt à copier.
2. **Le lancer et le voir échouer.** S'il passe déjà, il ne teste rien de neuf.
3. **Écrire le code** dans `Modules/<votre module>/Code/`, jusqu'à ce que le
   test passe.
4. **Relancer tous les tests de votre module.** Les anciens doivent toujours passer.

Le test « respecte sa prise » doit **toujours** passer. S'il échoue, votre
module ne se branche plus sur le Core, et son message dit pourquoi.

## 5. Proposer votre code (pull request)

On ne pousse jamais directement sur `main`. Chaque changement passe par une
branche et une *pull request* (PR) :

```bash
git switch -c ocr-lire-saturation        # 1. nouvelle branche, nom court
# ... coder, tester ...
git add Modules/OCR                      # 2. choisir ce qu'on envoie
git commit -m "OCR : lire la saturation" # 3. enregistrer, avec un message clair
git push -u origin ocr-lire-saturation   # 4. envoyer sur GitHub
```

Puis sur GitHub : **Compare & pull request**. Remplissez le gabarit (les cases
à cocher). La CI relance tous les tests automatiquement. Quand elle est verte
et qu'une personne a approuvé, on fusionne.

Une PR = une seule chose. Mieux vaut trois petites PR qu'une grosse.

## 6. Les règles

- **Votre dossier, c'est `Modules/<votre module>/`.** Vous y faites ce que vous voulez.
- **Les prises (`Core/Code/Prises/`) ne changent pas sans accord.** Si votre
  module a besoin de recevoir ou de rendre autre chose : ouvrir une *issue* sur
  GitHub qui explique le besoin, avant d'écrire du code. Thomas valide, puis
  une seule PR met à jour la prise, sa vérification, le faux module et les
  vrais modules.
- **On ne modifie pas un test existant pour le faire passer.** Si un test vous
  semble faux, dites-le dans la PR.
- **Aucune vraie donnée patient.** Pas de photo prise à l'hôpital, pas d'audio
  d'un vrai patient, pas de nom. Les photos de test sont fabriquées ou
  photographiées sur un écran de démonstration.
- **IA générative : permise et à citer.** Si un outil d'IA a écrit du code,
  dites-le dans la PR (exigence du cours GBM8970).

## 7. Quand ça bloque

| Message | Ce que ça veut dire |
|---|---|
| `error: cannot find 'X' in scope` | `X` n'existe pas ici : faute de frappe, ou un `import` manque en haut du fichier |
| `Expectation failed: ...` | un `#expect` est faux : le message montre la valeur obtenue |
| `[photo vide] aucune erreur...` | une promesse de la prise n'est pas tenue : relire la prise de votre module |
| `Frontière du Core` en erreur | un `import` d'iPhone (SwiftUI, Vision…) est entré dans `Core/` |

Toujours bloqué après 20 minutes ? Écrivez sur le canal de l'équipe avec le
message d'erreur complet (copié, pas en capture d'écran).
