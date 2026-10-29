#!/usr/bin/env bash
# Produit la matrice de traçabilité exigences → tests, en relisant
# docs/exigences.md et tous les titres de tests du dépôt.
#
# La matrice n'est jamais recopiée à la main, donc elle ne peut pas être périmée.
#
#   bash scripts/tracabilite.sh              affiche la matrice
#   bash scripts/tracabilite.sh --strict     échoue si une exigence n'a aucun test
#
# En intégration continue, la matrice est écrite dans le résumé du job.
set -euo pipefail

cd "$(dirname "$0")/.."

REGISTRE="docs/exigences.md"
DOSSIERS_TESTS=("Core/Tests" "App")
STRICT=0
[ "${1:-}" = "--strict" ] && STRICT=1

if [ ! -f "$REGISTRE" ]; then
    echo "Registre introuvable : $REGISTRE" >&2
    exit 1
fi

# Dossiers de tests réellement présents (App/ peut ne pas exister encore).
dossiers=()
for d in "${DOSSIERS_TESTS[@]}"; do
    [ -d "$d" ] && dossiers+=("$d")
done

titres_pour() {
    local id="$1"
    [ ${#dossiers[@]} -eq 0 ] && return 0
    grep -rh --include='*.swift' -F "$id" "${dossiers[@]}" 2>/dev/null \
        | grep -F '@Test' \
        | grep -vE '^[[:space:]]*//' \
        | sed -E 's/.*@Test\("([^"]*)".*/\1/' \
        || true
}

couvertes=0
orphelines=0
total=0

echo "# Matrice de traçabilité"
echo ""
echo "Générée par \`scripts/tracabilite.sh\` — ne pas modifier à la main."
echo ""
echo "| Exigence | Description | Tests | Couverture |"
echo "|---|---|---:|---|"

# Chaque ligne de tableau du registre qui commence par un identifiant EX-###.
while IFS= read -r ligne; do
    id=$(printf '%s' "$ligne" | sed -E 's/^\|[[:space:]]*(EX-[0-9]+).*/\1/')
    description=$(printf '%s' "$ligne" | awk -F'|' '{print $3}' | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')

    titres=$(titres_pour "$id")
    if [ -z "$titres" ]; then
        nombre=0
    else
        nombre=$(printf '%s\n' "$titres" | grep -c .)
    fi

    total=$((total + 1))
    if [ "$nombre" -gt 0 ]; then
        couvertes=$((couvertes + 1))
        marque="oui"
    else
        orphelines=$((orphelines + 1))
        marque="**AUCUN TEST**"
    fi

    echo "| $id | $description | $nombre | $marque |"
done < <(grep -E '^\|[[:space:]]*EX-[0-9]+[[:space:]]*\|' "$REGISTRE")

echo ""
echo "$couvertes exigence(s) couverte(s) sur $total."

# Tests qui citent une exigence absente du registre : faute de frappe, ou
# exigence qu'on a oublié d'inscrire. Les deux méritent d'être vues.
if [ ${#dossiers[@]} -gt 0 ]; then
    connus=$(grep -oE '\bEX-[0-9]+\b' "$REGISTRE" | sort -u)
    cites=$(grep -rhoE '\bEX-[0-9]+\b' --include='*.swift' "${dossiers[@]}" 2>/dev/null | sort -u || true)
    inconnus=$(comm -13 <(printf '%s\n' "$connus") <(printf '%s\n' "$cites") || true)

    if [ -n "$inconnus" ]; then
        echo ""
        echo "Exigences citées dans des tests mais absentes du registre :"
        printf '%s\n' "$inconnus" | sed 's/^/- /'
    fi
fi

if [ "$STRICT" -eq 1 ] && [ "$orphelines" -gt 0 ]; then
    echo ""
    echo "Échec : $orphelines exigence(s) sans aucun test." >&2
    exit 1
fi
