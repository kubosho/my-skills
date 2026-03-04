# AGENTS.md

This repository is a Claude Code plugin marketplace.

## Structure

- `.claude-plugin/marketplace.json` - Marketplace catalog
- `.claude-plugin/plugin.json` - Plugin manifest
- `skills/` - Skill definitions (each subdirectory contains a `SKILL.md`)

## Adding a New Skill

1. Create a directory under `skills/<skill-name>/`
2. Add a `SKILL.md` with frontmatter (`name`, `description`) and skill instructions
3. Bump the `version` in both `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`
