#!/usr/bin/env bash
set -euo pipefail

repo_root="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
temp_root=$(mktemp -d)
trap 'rm -rf "$temp_root"' EXIT

for plugin in anti-slop-code anti-slop-comment baseline test-principles; do
  project="$temp_root/$plugin"
  mkdir -p "$project"
  (
    cd "$project"
    apm marketplace add "$repo_root" --name kubosho-skills --ref HEAD
    apm install "$plugin@kubosho-skills" --target agent-skills
  )

  skills_dir="$project/.agents/skills"
  expected="$skills_dir/$plugin/SKILL.md"
  test -f "$expected"
  test "$(find "$skills_dir" -type f -name SKILL.md | wc -l | tr -d ' ')" = 1
  test "$(find "$skills_dir" -type f -name SKILL.md -print)" = "$expected"
done

printf 'individual APM install checks passed\n'
