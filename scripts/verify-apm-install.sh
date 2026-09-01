#!/usr/bin/env bash
set -euo pipefail

repo_root="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
temp_root=$(mktemp -d)
trap 'rm -rf "$temp_root"' EXIT

# Skill names the plugin declares in its own apm.yml, sorted, one per line.
declared_skills() {
  local plugin="$1"
  sed -n 's#^[[:space:]]*-[[:space:]]*skills/\([^/]*\)/SKILL\.md[[:space:]]*$#\1#p' \
    "$repo_root/plugins/$plugin/apm.yml" | sort
}

# Skill names APM actually deployed, sorted, one per line.
deployed_skills() {
  local skills_dir="$1"
  find "$skills_dir" -type f -name SKILL.md -print |
    sed "s#^$skills_dir/##; s#/SKILL\.md\$##" | sort
}

for plugin in anti-slop-code anti-slop-comment baseline spec-driven-development test-principles; do
  project="$temp_root/$plugin"
  mkdir -p "$project"
  (
    cd "$project"
    apm marketplace add "$repo_root" --name kubosho-skills --ref HEAD
    apm install "$plugin@kubosho-skills" --target agent-skills
  )

  skills_dir="$project/.agents/skills"
  test -d "$skills_dir"

  # Guards against a parsing change silently reducing the comparison below to
  # "empty equals empty", which would pass even when nothing was deployed.
  test -n "$(declared_skills "$plugin")"

  # Compare the deployed set with the declared set rather than looking up a
  # single well-known path: a plugin may ship several skills, and the plugin
  # name is not required to match any of them. Set equality still catches a
  # skill leaking in from another plugin, which is what this check exists for.
  if ! diff <(declared_skills "$plugin") <(deployed_skills "$skills_dir"); then
    printf '%s: deployed skills do not match the apm.yml declaration\n' "$plugin" >&2
    exit 1
  fi
done

printf 'individual APM install checks passed\n'
