# AGENTS.md

This repository is a Claude Code plugin marketplace.

## Structure

- `.claude-plugin/marketplace.json` - Marketplace catalog (version is managed here)
- `skills/<skill-name>/` - Each skill is an independent plugin
  - `.claude-plugin/plugin.json` - Plugin manifest (no version field; marketplace.json manages versions)
  - `SKILL.md` - Skill definition with frontmatter (`name`, `description`)

## Adding a New Skill

1. Create a directory under `skills/<skill-name>/`
2. Add a `SKILL.md` with frontmatter (`name`, `description`) and skill instructions
3. Add `.claude-plugin/plugin.json` with `name`, `description`, and `author`
4. Add a plugin entry to `.claude-plugin/marketplace.json` and bump the `version` there
