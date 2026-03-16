# AGENTS.md

This repository is a Claude Code plugin marketplace.

## Structure

- `.claude-plugin/marketplace.json` - Marketplace catalog listing all plugins
- `plugins/<plugin-name>/` - Each plugin is an isolated directory
  - `.claude-plugin/plugin.json` - Plugin manifest (`name`, `description`, `version`, `author`)
  - `skills/<skill-name>/SKILL.md` - Skill definition with frontmatter (`name`, `description`)

## Adding a New Skill

1. Create a directory under `plugins/<skill-name>/`
2. Create `.claude-plugin/plugin.json` with `name`, `description`, `version`, and `author`
3. Create `skills/<skill-name>/SKILL.md` with frontmatter (`name`, `description`) and skill instructions
4. Add a plugin entry to `.claude-plugin/marketplace.json` with `source` pointing to the plugin directory, then bump `metadata.version`
