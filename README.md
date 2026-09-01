# kubosho-skills

A [Claude Code plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces) providing skills for everyday development workflows.

## Plugins

| Plugin | Skills | Description |
|--------|--------|-------------|
| `anti-slop-code` | `anti-slop-code` | Write intentional, minimal code that avoids generic AI-generated patterns |
| `anti-slop-comment` | `anti-slop-comment` | Write only code comments that carry information the code and tests cannot |
| `baseline` | `baseline` | Check Baseline status of web features via Web Platform Status API |
| `spec-driven-development` | `spec-driven-development`, `spec-authoring`, `spec-implement`, `spec-implementation-check` | Run spec-driven development: author a spec, implement one acceptance criterion, and check the diff against it |
| `test-principles` | `test-principles` | Principles for writing high-quality automated tests, based on Kent Beck, Kent C. Dodds, and t-wada |

`spec-driven-development` bundles skills that depend on each other, so they ship as one plugin. It also bundles a `negative-requirements-reviewer` subagent that `spec-implementation-check` calls.

## Install with Claude Code

Add the marketplace and install individual plugins:

```shell
/plugin marketplace add kubosho/my-skills
/plugin install anti-slop-code@kubosho-skills
/plugin install anti-slop-comment@kubosho-skills
/plugin install baseline@kubosho-skills
/plugin install spec-driven-development@kubosho-skills
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
apm install spec-driven-development@kubosho-skills --target agent-skills
apm install test-principles@kubosho-skills --target agent-skills
```

The `agent-skills` target deploys skills only. `spec-driven-development` also
ships a subagent, so install it with `--target claude` or `--target codex` to
get `negative-requirements-reviewer` as well.

## Install for Codex CLI

Use the same marketplace with Codex as the installation target:

```shell
apm marketplace add kubosho/my-skills --name kubosho-skills
apm install anti-slop-code@kubosho-skills --target codex
apm install anti-slop-comment@kubosho-skills --target codex
apm install baseline@kubosho-skills --target codex
apm install spec-driven-development@kubosho-skills --target codex
apm install test-principles@kubosho-skills --target codex
```

## Manual Claude skill links

Alternatively, clone the repository and symlink individual skills:

```shell
git clone https://github.com/kubosho/my-skills.git

# Symlink each skill you want to use
ln -s /path/to/my-skills/plugins/anti-slop-code/skills/anti-slop-code ~/.claude/skills/anti-slop-code
ln -s /path/to/my-skills/plugins/anti-slop-comment/skills/anti-slop-comment ~/.claude/skills/anti-slop-comment
ln -s /path/to/my-skills/plugins/baseline/skills/baseline ~/.claude/skills/baseline
ln -s /path/to/my-skills/plugins/test-principles/skills/test-principles ~/.claude/skills/test-principles

# spec-driven-development ships several skills plus a subagent
ln -s /path/to/my-skills/plugins/spec-driven-development/skills/spec-driven-development ~/.claude/skills/spec-driven-development
ln -s /path/to/my-skills/plugins/spec-driven-development/skills/spec-authoring ~/.claude/skills/spec-authoring
ln -s /path/to/my-skills/plugins/spec-driven-development/skills/spec-implement ~/.claude/skills/spec-implement
ln -s /path/to/my-skills/plugins/spec-driven-development/skills/spec-implementation-check ~/.claude/skills/spec-implementation-check
ln -s /path/to/my-skills/plugins/spec-driven-development/agents/negative-requirements-reviewer.md ~/.claude/agents/negative-requirements-reviewer.md
```

## License

[MIT](LICENSE)
