#!/usr/bin/env bash
set -euo pipefail

run_web_checks() {
  (cd web && npm ci && npm run build && npm test)
}

run_dotnet_checks() {
  dotnet build
  for project in $tests; do
    dotnet test "$project" --no-build
  done
}

run_e2e_checks() {
  (cd e2e && npm ci && npx playwright test)
}

stop() {
  echo "ship: $1" >&2
  exit 1
}

if [[ -z "${NO_PUSH:-}" && ! -f "${1:-}" ]]; then
  echo "usage: scripts/ship.sh <file with the pull request description>" >&2
  echo "       TITLE='...' sets the pull request title, NO_PUSH=1 only runs the checks" >&2
  exit 64
fi
body=""
[[ -z "${1:-}" ]] || body="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"

cd "$(git rev-parse --show-toplevel)"

branch=$(git branch --show-current)
[[ -n "$branch" ]] || stop "HEAD is detached. Check out the branch you want to ship."
[[ "$branch" != main ]] || stop "you are on main. Ship from a branch."
[[ -z "$(git status --porcelain)" ]] || stop "the working tree has uncommitted changes. Commit them first."

git fetch -q origin main
if ! git merge-base --is-ancestor origin/main HEAD; then
  git rebase -q origin/main || {
    git rebase --abort
    stop "the rebase on main has conflicts. Rebase by hand and run this again."
  }
fi
sha=$(git rev-parse HEAD)

files=$(git diff --name-only --no-renames origin/main...HEAD)
if [[ -z "$files" ]]; then
  echo "ship: nothing to ship, the branch has no changes on top of main"
  exit 0
fi

selection=$(FILES=$files scripts/select-checks.sh)
web=true e2e=true dotnet=all tests=""
while IFS='=' read -r check value; do
  case "$check" in
    web) web=$value ;;
    e2e) e2e=$value ;;
    dotnet) dotnet=$value ;;
    tests) tests=$value ;;
  esac
done <<<"$selection"

passed=""
if [[ "$web" == true ]]; then
  run_web_checks
  passed+="web "
fi
if [[ "$dotnet" != none ]]; then
  run_dotnet_checks
  passed+="dotnet($dotnet) "
fi
if [[ "$e2e" == true ]]; then
  run_e2e_checks
  passed+="e2e "
fi
passed=${passed% }

[[ "$(git rev-parse HEAD)" == "$sha" ]] || stop "HEAD moved while the checks ran. Run this again."
[[ -z "$(git status --porcelain)" ]] || stop "the checks changed files in the working tree. Commit or remove them and run this again."

if [[ -n "${NO_PUSH:-}" ]]; then
  echo "ship: checks passed for $sha ($passed). NO_PUSH is set, so nothing was pushed."
  exit 0
fi

git push -q -f origin "$sha:refs/heads/$branch"

if [[ -n "$(gh pr list --head "$branch" --state open --json number -q '.[].number')" ]]; then
  gh pr edit "$branch" --body-file "$body" ${TITLE:+--title "$TITLE"}
else
  gh pr create --base main --head "$branch" --body-file "$body" \
    --title "${TITLE:-$(git log --format=%s origin/main..HEAD | tail -1)}"
fi
pr=$(gh pr view "$branch" --json url -q .url)

git push origin "$sha:refs/heads/main"
echo "ship: $sha is on main. The record: $pr"

repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)
gh api "repos/$repo/statuses/$sha" \
  -f state=success \
  -f context=signoff \
  -f description="Local checks passed on $(hostname -s): $passed" >/dev/null
