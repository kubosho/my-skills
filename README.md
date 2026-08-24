# kubosho-skills

A [Claude Code plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces) providing skills for everyday development workflows.

## Skills

| Skill | Description |
|-------|-------------|
| `anti-slop-code` | Write intentional, minimal code that avoids generic AI-generated patterns |
| `anti-slop-comment` | Write only code comments that carry information the code and tests cannot |
| `baseline` | Check Baseline status of web features via Web Platform Status API |
| `test-principles` | Principles for writing high-quality automated tests, based on Kent Beck, Kent C. Dodds, and t-wada |

## Install with Claude Code

Add the marketplace and install individual plugins:

```shell
/plugin marketplace add kubosho/my-skills
/plugin install anti-slop-code@kubosho-skills
/plugin install anti-slop-comment@kubosho-skills
/plugin install baseline@kubosho-skills
/plugin install test-principles@kubosho-skills
```

## Install with APM

Register the marketplace and install each plugin individually for the shared
agent-skills target:

```shell
apm marketplace add kubosho/my-skills --name kubosho-skills
apm install anti-slop-code@kubosho-skills --target agent-skills
apm install anti-slop-comment@kubosho-skills --target agent-skills
apm install baseline@kubosho-skills --target agent-skills
apm install test-principles@kubosho-skills --target agent-skills
```

## Install for Codex CLI

Use the same marketplace with Codex as the installation target:

```shell
apm marketplace add kubosho/my-skills --name kubosho-skills
apm install anti-slop-code@kubosho-skills --target codex
apm install anti-slop-comment@kubosho-skills --target codex
apm install baseline@kubosho-skills --target codex
apm install test-principles@kubosho-skills --target codex
```

## Manual Claude skill links

Alternatively, clone the repository and symlink individual skills:

```shell
git clone https://github.com/kubosho/my-skills.git

# Symlink each skill you want to use
ln -s /path/to/my-skills/plugins/anti-slop-code ~/.claude/skills/anti-slop-code
ln -s /path/to/my-skills/plugins/anti-slop-comment ~/.claude/skills/anti-slop-comment
ln -s /path/to/my-skills/plugins/baseline ~/.claude/skills/baseline
ln -s /path/to/my-skills/plugins/test-principles ~/.claude/skills/test-principles
```

## License

[MIT](LICENSE)
