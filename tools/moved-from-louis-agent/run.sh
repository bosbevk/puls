#!/usr/bin/env bash
# F166.3, run once: Puls and its three packs, from louis-agent into this repository, in src/ and tests/ under Puls's own
# names, on the framework's published packages. Louis, 2026-11-21: a fresh start, the history left in louis-agent at
# the tag puls-moved-out; the move done as commands kept as the record, with no tests, as F167's rename was.
#
#   bash tools/moved-from-louis-agent/run.sh <louis-agent folder> <tag> [dry|write]
#
# A dry run prints what would move, how many names and references change, and the words left for a person. A write
# also makes Puls.sln with every project, and a nuget.config that finds the framework on GitHub Packages.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
here=tools/moved-from-louis-agent
from=$1
ref=$2
mode=${3:-dry}

perl "$here/move.pl" "$from" "$ref" "$mode" | tee "$here/report-$mode.txt"
[ "$mode" = write ] || exit 0

dotnet new sln -n Puls --format sln --force > /dev/null
dotnet sln Puls.sln add $(git ls-files --others --exclude-standard 'src/*.csproj' 'tests/*.csproj') > /dev/null
dotnet new nugetconfig --force > /dev/null
dotnet nuget add source https://nuget.pkg.github.com/bosbevk/index.json --name framework --configfile nuget.config \
    --username bosbevk --password '%GITHUB_PACKAGES_TOKEN%' --store-password-in-clear-text > /dev/null
echo "Puls.sln and nuget.config written."
