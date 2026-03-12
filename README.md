# kubosho-skills

A [Claude Code plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces) providing skills for everyday development workflows.

## Skills

| Skill | Description |
|-------|-------------|
| `anti-slop-code` | Write intentional, minimal code that avoids generic AI-generated patterns |
| `baseline` | Check Baseline status of web features via Web Platform Status API |
| `pr-description` | Write narrative-driven PR descriptions with Summary, Changes, Test plan structure |
| `test-principles` | Principles for writing high-quality automated tests, based on Kent Beck, Kent C. Dodds, and t-wada |

## Install

Install via the Claude Code plugin marketplace:

```shell
/plugin marketplace add kubosho/my-skills
/plugin install kubosho-skills@my-skills
```

Or clone the repository and symlink individual skills:

```shell
git clone https://github.com/kubosho/my-skills.git

# Symlink each skill you want to use
ln -s /path/to/my-skills/skills/anti-slop-code ~/.claude/skills/anti-slop-code
ln -s /path/to/my-skills/skills/baseline ~/.claude/skills/baseline
ln -s /path/to/my-skills/skills/pr-description ~/.claude/skills/pr-description
ln -s /path/to/my-skills/skills/test-principles ~/.claude/skills/test-principles
```

## License

[MIT](LICENSE)
