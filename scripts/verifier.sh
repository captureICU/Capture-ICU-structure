#!/usr/bin/env bash
# LA commande de l'équipe. Même chose sur votre ordinateur et dans la CI.
#
#   bash scripts/verifier.sh
#
# 1. frontière : le Core et les outils de test n'importent aucun framework d'iPhone
# 2. tous les tests (Core, 3 modules, bout en bout)
# 3. matrice de traçabilité exigences → tests
#
# Pour ne lancer que les tests de votre module : bash scripts/tester.sh ocr
set -euo pipefail

cd "$(dirname "$0")/.."

echo "== 1/3 Frontière du Core"
if grep -rEn '^\s*import\s+(UIKit|SwiftUI|Vision|Speech|AVFoundation|CoreGraphics|PDFKit)' Core/Code OutilsDeTest; then
    echo "::error::Le Core ne connaît ni écran ni appareil. Ce code appartient à un module ou à App/."
    exit 1
fi
echo "OK"

echo "== 2/3 Tous les tests"
swift test

echo "== 3/3 Matrice de traçabilité"
bash scripts/tracabilite.sh
