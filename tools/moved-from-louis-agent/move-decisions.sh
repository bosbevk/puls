#!/usr/bin/env bash
# F166.4 step 2, run once and kept with the move's other commands: the decisions that are Puls's alone come home.
# The three packs' ADRs (0069, 0078, 0082) join 0081 in docs/adr, and Puls's own track joins its plans, from
# louis-agent at the tag puls-moved-out (Louis's pick A of F166.4's finding 2). Their links into louis-agent's
# framework docs point there on GitHub, at the tag; Puls's own docs point at the ADRs here.
#
#   bash tools/moved-from-louis-agent/move-decisions.sh <louis-agent folder> <tag>
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
from=$1
ref=$2
web="https://github.com/bosbevk/louis-agent/blob/$ref"

# Each file as it was at the tag, to its place here.
copy() { mkdir -p "$(dirname "$2")"; git -C "$from" show "$ref:$1" > "$2"; }
for adr in $(git -C "$from" ls-tree --name-only "$ref" packs/docs/adr/ | grep -E '/00(69|78|82)-'); do
    copy "$adr" "docs/adr/$(basename "$adr")"
done
copy src/docs/plans/puls-track.md docs/plans/puls-track.md
for picture in $(git -C "$from" ls-tree --name-only "$ref" src/docs/plans/diagrams/ | grep '/puls-track-'); do
    copy "$picture" "docs/plans/diagrams/$(basename "$picture")"
done

# The ADRs' links: Puls's own page here, the framework's docs at the tag.
perl -pi -e 's{\]\(\.\./\.\./\.\./demos/puls/docs/}{](../}g; s{\]\(\.\./\.\./\.\./src/}{]('"$web"'/src/}g' docs/adr/00{69,78,82}-*.md

# Puls's docs pointed at the three on GitHub; they are here now.
for file in $(grep -rlE "blob/$ref/packs/docs/adr/00(69|78|82)-" docs); do
    rel=$(realpath --relative-to="$(dirname "$file")" docs/adr)
    perl -pi -e 's{\Q'"$web"'\E/packs/docs/adr/(00(?:69|78|82)-)}{'"$rel"'/$1}g' "$file"
done
echo "Puls's decisions moved: $(ls docs/adr | wc -l) ADRs here, and its track in docs/plans."
