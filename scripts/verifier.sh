#!/usr/bin/env bash
# LA commande de l'équipe. Même chose en local et en intégration continue.
#
#   bash scripts/verifier.sh
#
# 1. frontière du noyau : Core/ n'importe aucun framework Apple d'interface ou d'appareil
# 2. tous les tests du noyau (unitaires, contrats, pipelines, corpus, format d'export)
# 3. matrice de traçabilité exigences → tests
set -euo pipefail

cd "$(dirname "$0")/.."

echo "== 1/3 Frontière du noyau"
if grep -rEn '^\s*import\s+(UIKit|SwiftUI|Vision|Speech|AVFoundation|CoreGraphics)' Core/Sources; then
    echo "::error::Core/ ne connaît ni interface ni appareil. Ce code appartient à App/."
    exit 1
fi
echo "OK"

echo "== 2/3 Tests du noyau"
(cd Core && swift test)

echo "== 3/3 Matrice de traçabilité"
bash scripts/tracabilite.sh
