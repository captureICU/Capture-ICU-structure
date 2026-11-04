# Module 2 · Transcription

**Votre travail :** recevoir l'enregistrement de la note dictée par
l'infirmière, rendre le texte.

| | |
|---|---|
| Reçoit | un `Audio` (des octets, par exemple un fichier .m4a) |
| Rend | le texte de la note, gardé **tel quel** |
| Votre code | `Code/Transcription.swift` |
| Vos tests | `Tests/TranscriptionTests.swift` |
| Lancer vos tests | `bash scripts/tester.sh transcription` |
| Votre prise | `Core/Code/Prises/PriseTranscription.swift` |

## Aujourd'hui

`Transcription.swift` n'écoute pas l'audio : il rend toujours la même note
inventée. Tout le parcours fonctionne quand même. Votre travail est de remplacer
cette note par une vraie transcription.

## Les promesses de votre prise

Vérifiées automatiquement par le test « respecte sa prise » :

1. Audio vide → lancer `ErreurTranscription.audioVide`.
2. Sur un audio qui contient de la parole, rendre un texte non vide.

La note est gardée mot pour mot : pas de résumé, pas de chiffres extraits.
Elle finit dans la section « Observations de l'infirmière » de la note.

## Pistes pour la suite

1. **Transcrire avec le framework Speech d'Apple**
   (`SFSpeechRecognizer`, langue `fr-CA`). Speech n'existe que sur les appareils
   Apple : entourez ce code de `#if canImport(Speech)` … `#endif`.
2. **Les permissions** : l'iPhone demande l'accord pour le micro et la
   reconnaissance vocale. Un refus doit lancer `ErreurTranscription.microRefuse`.
3. **Les audios de test** : une voix de synthèse ou un membre de l'équipe qui
   lit une phrase inventée. Jamais un vrai patient.
4. **Les exigences à viser** : 90 % d'exactitude (7.2-6), 98 % sur les chiffres
   dictés (7.2-7), moins d'une minute (7.1-3).
