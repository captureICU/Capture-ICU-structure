#!/usr/bin/env bash
# Produit la matrice de traçabilité exigences → tests, en relisant
# docs/exigences.md et tous les titres de tests du dépôt.
#
# Un test couvre une exigence quand son titre contient son numéro entre
# crochets, par exemple :  @Test("[4.2.1-4] chaque valeur arrive dans le bon champ")
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
DOSSIERS_TESTS=("Core/Tests" "Modules" "BoutEnBout" "App")
STRICT=0
[ "${1:-}" = "--strict" ] && STRICT=1

# Un numéro d'exigence de la spécification : 4.2.1-4, 7.2-5, 8.1-2…
MOTIF_ID='[0-9]+(\.[0-9]+)*-[0-9]+'

if [ ! -f "$REGISTRE" ]; then
    echo "Registre introuvable : $REGISTRE" >&2
    exit 1
fi

# Dossiers de tests réellement présents (App/ peut ne pas en contenir encore).
dossiers=()
for d in "${DOSSIERS_TESTS[@]}"; do
    [ -d "$d" ] && dossiers+=("$d")
done

# Tous les titres de tests actifs (lignes @Test non commentées).
titres_actifs() {
    [ ${#dossiers[@]} -eq 0 ] && return 0
    grep -rh --include='*.swift' '@Test(' "${dossiers[@]}" 2>/dev/null \
        | grep -vE '^[[:space:]]*//' \
        | sed -E 's/.*@Test\("([^"]*)".*/\1/' \
        || true
}

TITRES=$(titres_actifs)

titres_pour() {
    printf '%s\n' "$TITRES" | grep -F "[$1]" || true
}

couvertes=0
orphelines=0
total=0

echo "# Matrice de traçabilité"
echo ""
echo "Générée par \`scripts/tracabilite.sh\`. Ne pas modifier à la main."
echo ""
echo "| Exigence | Description | Tests | Couverture |"
echo "|---|---|---:|---|"

while IFS= read -r ligne; do
    id=$(printf '%s' "$ligne" | grep -oE "^\|[[:space:]]*$MOTIF_ID" | sed -E 's/^\|[[:space:]]*//')
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
done < <(grep -E "^\|[[:space:]]*$MOTIF_ID[[:space:]]*\|" "$REGISTRE")

echo ""
echo "$couvertes exigence(s) couverte(s) sur $total."

# Tests qui citent une exigence absente du registre : faute de frappe, ou
# exigence oubliée dans le registre. Les deux méritent d'être vues.
connus=$(grep -oE "^\|[[:space:]]*$MOTIF_ID" "$REGISTRE" | sed -E 's/^\|[[:space:]]*//' | sort -u)
cites=$(printf '%s\n' "$TITRES" | grep -oE "\[$MOTIF_ID\]" | tr -d '[]' | sort -u || true)
inconnus=$(comm -13 <(printf '%s\n' "$connus") <(printf '%s\n' "$cites") | grep . || true)

if [ -n "$inconnus" ]; then
    echo ""
    echo "Exigences citées dans des tests mais absentes du registre :"
    printf '%s\n' "$inconnus" | sed 's/^/- /'
fi

if [ "$STRICT" -eq 1 ] && [ "$orphelines" -gt 0 ]; then
    echo ""
    echo "Échec : $orphelines exigence(s) sans aucun test." >&2
    exit 1
fi
