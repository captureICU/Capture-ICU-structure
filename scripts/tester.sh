#!/usr/bin/env bash
# Lance les tests d'une seule partie du projet.
#
#   bash scripts/tester.sh ocr
#   bash scripts/tester.sh transcription
#   bash scripts/tester.sh export
#   bash scripts/tester.sh core
#   bash scripts/tester.sh bout-en-bout
#   bash scripts/tester.sh tout
#
# Avant d'ouvrir une pull request, lancez quand même tout : bash scripts/verifier.sh
set -euo pipefail

cd "$(dirname "$0")/.."

case "${1:-tout}" in
    ocr)            cible="ModuleOCRTests" ;;
    transcription)  cible="ModuleTranscriptionTests" ;;
    export)         cible="ModuleExportTests" ;;
    core)           cible="CoreTests" ;;
    bout-en-bout)   cible="BoutEnBoutTests" ;;
    tout)           swift test; exit 0 ;;
    *)
        echo "Partie inconnue : $1"
        echo "Choix possibles : ocr, transcription, export, core, bout-en-bout, tout"
        exit 1
        ;;
esac

swift test --filter "$cible"
