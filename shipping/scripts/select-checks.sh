#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

projects=$(find src tests -name '*.csproj' 2>/dev/null | sort)

report() {
  local tests="" project
  for project in $projects; do
    [[ "$project" == tests/* ]] || continue
    [[ "$3" != all && "$affected" != *" $(basename "$project") "* ]] || tests+="$project "
  done
  local dotnet=$3
  [[ -n "$tests" ]] || dotnet=none
  printf 'web=%s\ne2e=%s\ndotnet=%s\ntests=%s\n' "$1" "$2" "$dotnet" "${tests% }"
  exit 0
}

everything() {
  report true true all
}

project_of() {
  local folder candidate
  folder=$(dirname "$1")
  while [[ "$folder" != . && "$folder" != / ]]; do
    for candidate in "$folder"/*.csproj; do
      if [[ -f "$candidate" ]]; then
        basename "$candidate"
        return 0
      fi
    done
    folder=$(dirname "$folder")
  done
  return 1
}

references_of() {
  { grep -o 'ProjectReference Include="[^"]*"' "$1" || true; } |
    sed -e 's/.*Include="//' -e 's/"$//' -e 's|\\|/|g' -e 's|.*/||'
}

affected=" "
[[ -z "${ALL:-}" ]] || everything

files=${FILES:-$(git diff --name-only --no-renames origin/main...HEAD)}
[[ -n "$files" ]] || everything

web=false
e2e=false

while IFS= read -r file; do
  case "$file" in
    docs/* | *.md | LICENSE)
      ;;
    web/*)
      web=true
      e2e=true
      ;;
    e2e/*)
      e2e=true
      ;;
    tests/Shared/* | Directory.*.props | *.sln | global.json | scripts/* | .github/*)
      everything
      ;;
    src/*/*)
      project=$(project_of "$file") || everything
      affected+="$project "
      e2e=true
      ;;
    tests/*/*)
      project=$(project_of "$file") || everything
      affected+="$project "
      ;;
    *)
      everything
      ;;
  esac
done <<<"$files"

grew=true
while [[ "$grew" == true ]]; do
  grew=false
  for project in $projects; do
    name=$(basename "$project")
    [[ "$affected" != *" $name "* ]] || continue
    for reference in $(references_of "$project"); do
      if [[ "$affected" == *" $reference "* ]]; then
        affected+="$name "
        grew=true
        break
      fi
    done
  done
done

report "$web" "$e2e" some
