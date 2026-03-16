# AGENTS.md

This repository is a Claude Code plugin marketplace.

## Structure

- `.claude-plugin/marketplace.json` - Marketplace catalog (`strict: false`; all plugin definitions live here)
- `skills/<skill-name>/SKILL.md` - Skill definition with frontmatter (`name`, `description`)

## Adding a New Skill

1. Create a directory under `skills/<skill-name>/`
2. Add a `SKILL.md` with frontmatter (`name`, `description`) and skill instructions
3. Add a plugin entry to `.claude-plugin/marketplace.json` with `strict: false` and `skills` array pointing to the skill directory, then bump `metadata.version`
