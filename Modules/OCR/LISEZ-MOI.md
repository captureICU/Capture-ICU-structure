# Module 1 · OCR

**Votre travail :** recevoir la photo d'un appareil, rendre les valeurs lues
dessus, chacune dans le bon champ.

| | |
|---|---|
| Reçoit | une `Photo` (des octets JPEG) et l'`Appareil` photographié (moniteur, pompe ou ventilateur) |
| Rend | une liste de `Mesure` : paramètre (FC, SpO2…), valeur, confiance entre 0 et 1 |
| Votre code | `Code/OCR.swift` |
| Vos tests | `Tests/OCRTests.swift` |
| Lancer vos tests | `bash scripts/tester.sh ocr` |
| Votre prise | `Core/Code/Prises/PriseOCR.swift` |

## Aujourd'hui

`OCR.swift` ne lit pas la photo : il rend toujours les mêmes valeurs inventées
(FC 88, TAS 118…). Tout le parcours fonctionne quand même. Votre travail est de
remplacer ces valeurs par une vraie lecture.

## Les promesses de votre prise

Vérifiées automatiquement par le test « respecte sa prise » :

1. Photo vide → lancer `ErreurOCR.photoVide`.
2. Ne rendre que des paramètres de l'appareil photographié (pas de FiO2 sur un moniteur).
3. Pas deux fois le même paramètre.
4. Une confiance entre 0 et 1 pour chaque valeur.
5. Ne jamais marquer une valeur « corrigée par l'infirmière ».

**Pas sûr d'une valeur ?** Rendez-la quand même, avec une confiance basse. Le
Core videra la case lui-même sous 0,8 et demandera à l'infirmière de la remplir.

## Pistes pour la suite

1. **Lire le texte de la photo** avec le framework Vision d'Apple
   (`VNRecognizeTextRequest`). Vision n'existe que sur les appareils Apple :
   entourez ce code de `#if canImport(Vision)` … `#endif` pour que les tests
   continuent de tourner partout.
2. **Séparer la lecture des règles.** Vision rend du texte (« FC 88 »). Les
   règles qui transforment ce texte en `Mesure` sont du Swift ordinaire : mettez-les
   dans un fichier à part, et testez-les avec du texte écrit à la main, sans photo.
3. **Les pièges connus** : « SpO2 » contient le chiffre 2; la tension s'écrit
   « 118/72 (87) », avec la moyenne entre parenthèses.
