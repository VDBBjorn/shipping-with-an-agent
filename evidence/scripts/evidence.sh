#!/usr/bin/env bash
set -euo pipefail

if [[ ! -d "${1:-}" ]]; then
  echo "usage: scripts/evidence.sh <folder with screenshots and videos>" >&2
  exit 64
fi
source_folder=$(cd "$1" && pwd)

root=$(git rev-parse --show-toplevel)
cd "$root"
branch=$(git branch --show-current)
repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)
target="${branch:-detached}/$(date +%Y%m%d-%H%M%S)"

worktree=$(mktemp -d)
start_branch="evidence-start-$$"
cleanup() {
  cd "$root"
  git worktree remove --force "$worktree" >/dev/null 2>&1 || true
  git branch -q -D "$start_branch" >/dev/null 2>&1 || true
}
trap cleanup EXIT

git worktree add -q --detach "$worktree"
cd "$worktree"
if git fetch -q origin evidence 2>/dev/null; then
  git switch -q --detach FETCH_HEAD
else
  git switch -q --orphan "$start_branch"
fi

mkdir -p "$target"
find "$source_folder" -maxdepth 1 -type f \
  \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.gif' -o -name '*.webm' -o -name '*.mp4' \) |
  sort |
  while IFS= read -r file; do
    name=$(basename "$file")
    cp "$file" "$target/${name// /-}"
  done

if [[ -z "$(ls "$target")" ]]; then
  echo "evidence: no screenshots or videos in $source_folder" >&2
  exit 1
fi

git add "$target"
git commit -q -m "Evidence for ${branch:-a detached HEAD}"
git push -q origin "HEAD:refs/heads/evidence"
commit=$(git rev-parse HEAD)

for file in "$target"/*; do
  name=$(basename "$file")
  url="https://github.com/$repo/blob/$commit/$target/$name?raw=true"
  case "$name" in
    *.webm | *.mp4) echo "[${name%.*} (video)]($url)" ;;
    *) echo "![${name%.*}]($url)" ;;
  esac
done
