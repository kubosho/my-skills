# Claude Code Extension Decision Guide

How to decide where a new instruction, procedure, or knowledge should live in a Claude Code setup. This document is self-contained: a fresh session with no prior context can read it and arrive at the same decisions. Field-level details (exact frontmatter names, accepted values, numeric limits) are deferred to the References at the end and may evolve.

## Why this guide exists

Claude Code offers many ways to add behavior: `CLAUDE.md`, skills, subagents, hooks, MCP servers, path-specific rules, output styles. Without a framework, it is easy to:

- Pile everything into `CLAUDE.md` and bloat the always-loaded context.
- Build a "skill" that is really an MCP integration in disguise.
- Define a subagent for a job that a forking skill would solve more cheaply.
- Re-discover the same answer (`/commit` versus a skill, hook versus skill) every time.

## Background facts you must know first

1. **Skills are the canonical extension format.** A skill can be invoked by the user as `/name` or loaded automatically by Claude based on its description. Skills support a directory of supporting files, invocation control, and per-skill configuration.
2. **Skills load lazily but stay resident.** Descriptions are always listed in context so Claude can choose. Full bodies load only on invocation and remain for the rest of the session.
3. **`CLAUDE.md` is read once at session start and resides in the conversation for the whole session.** Sub-directory `CLAUDE.md` files load lazily when Claude reads files in those directories, and `/compact` re-injects the root file from disk. Every token committed there occupies the context window for the rest of the session, so reserve it for facts that apply across the whole session.
4. **Subagents run in an isolated context** with no view of the main conversation, and return a single summary to the caller.
5. **Hooks are deterministic.** They fire on tool or session events regardless of what the model would choose, so they are the lever when behavior must be enforced rather than encouraged.
6. **MCP servers expose typed tools and resources.** Use them when the integration needs structured arguments and authenticated remote access, not when the work can be done with a shell command in a skill.

## The decision tree

Read top to bottom. Stop at the first matching question.

1. **Is this a fact that applies across the whole project on every turn?**
   Examples: tech stack, directory layout, naming conventions, available subagents and skills users should know about.
   → `CLAUDE.md` (project root) or `~/.claude/CLAUDE.md` (personal).

2. **Is this a fact or rule that applies only when working on certain file paths?**
   Examples: "components in `src/components/**` must be functional React components", "files in `docs/**` use English".
   → Path-specific rules in `CLAUDE.md` (see `/en/memory#path-specific-rules`), or a skill with the `paths` frontmatter field if the rule has supporting examples or procedures.

3. **Must this behavior be enforced no matter what the model decides?**
   Examples: block `git commit` in a `jj` repo and redirect to `jj describe`, auto-format on save, run lint after edits, notify on session start.
   → Hooks in `.claude/settings.json`. See `/en/hooks`.

4. **Is this an integration with an authenticated external service or a typed tool surface?**
   Examples: Jira, Slack, GitHub Enterprise, an internal API that needs OAuth.
   → MCP server. Skills can call MCP tools, but the integration itself belongs in MCP.

5. **Is this a procedure or knowledge body the user invokes by name, with possible arguments?**
   Examples: `/commit`, `/deploy`, `/summarize-changes`, `/pr-description`, a coding style reference Claude should consult.
   → **Skill.** Pick the sub-pattern below.

6. **Is this a specialist role that needs its own isolated context, its own tool set, or that should run in parallel with other work?**
   Examples: "code reviewer that reads many files and returns a verdict", "research agent that explores the codebase without polluting the main context".
   → Subagent. See "Subagent vs forking skill" below for the tiebreaker.

7. **Is this only about how Claude talks to the user (tone, persona, formatting), not what it does?**
   → Output style. See `/en/output-styles`.

## Skill sub-patterns

A skill is the right answer for most extensions. Four sub-patterns cover the common cases.

### A. Task skill, user-triggered only

The user types `/name [args]` and the skill runs. Claude must not auto-invoke it, because the side effect is committed only when the user asks.

Use for: deploy, commit, push, send message, create PR.

Configure the skill so that:
- Only the user can invoke it (Claude cannot auto-load).
- The tools the skill needs are pre-approved while the skill is active, so the user is not prompted mid-run.

### B. Reference skill, Claude auto-invokes

A body of knowledge or convention Claude should consult when the topic comes up. Claude decides when to load it based on the description.

Use for: API conventions, coding style, domain glossary, framework patterns.

Design points:
- Write the description with trigger keywords in the first sentence. Claude matches user requests against this text, so vague descriptions reduce auto-invocation.
- If the knowledge applies only to files under specific paths, scope auto-loading by glob.

### C. Procedure skill, both can invoke

A multi-step procedure that is safe for Claude to run when relevant, and that the user may also trigger explicitly.

Use for: `/summarize-changes`, `/explain-error`, `/review-diff`.

Design points:
- The skill body can include **dynamic context injection**. A line like `` !`git diff HEAD` `` runs the command before Claude sees the skill content, and the output replaces the placeholder. This lets the procedure operate on live state instead of stale assumptions.
- Leave invocation unrestricted so Claude can auto-load the skill when the description matches the user's request.

### D. Background-knowledge skill, Claude-only

Knowledge Claude should have available, but that is not a meaningful command for users to type.

Use for: "how the legacy billing system works", "platform-specific gotchas".

Design points:
- Hide the skill from the `/` menu so it does not clutter user-facing autocomplete. Claude still sees the description and can load it automatically when the topic comes up.

## Subagent vs forking skill

Both run work in an isolated context. The difference is what you author and what loads at startup.

| Approach | You author | System prompt at run time | Notes |
| --- | --- | --- | --- |
| Skill that forks into a subagent | The task itself, in `SKILL.md` | Comes from the chosen subagent type | Read-only or planning-style subagents typically skip `CLAUDE.md` to stay lean |
| Custom subagent that preloads skills | A persona and instructions in `.claude/agents/<name>.md` | The subagent's body | `CLAUDE.md` and any preloaded skills are injected at startup |

Decision rule:

- If the unit of work is a **task with one entry point**, write a skill that forks into a subagent. The task lives in `SKILL.md`. Pick the subagent type that fits the job: read-only investigation, planning, or free-form.
- If the unit of work is a **role that the main agent delegates many different tasks to**, write a subagent. The role lives in `.claude/agents/<name>.md` and can preload supporting skills.

Heuristic: "research this topic" is a one-shot task and belongs in a forking skill. "Be the code reviewer for this repo and look at whatever the main agent hands you" is a recurring role and belongs in a subagent.

## What goes in `CLAUDE.md`

`CLAUDE.md` is injected into the conversation at session start and stays there until the session ends. Every line occupies context-window space for the rest of the session, so put in it only what must apply across the whole session.

Good `CLAUDE.md` content:

- Product purpose and primary tech stack.
- Top-level directory layout.
- Data shapes and naming conventions that the model must respect by default.
- Pointers to important subagents and skills (name, one-line purpose, when to use). The skill descriptions themselves are auto-listed by Claude Code, but a short orientation here raises the chance the model picks them.
- Coding style preferences that apply to all files.

Bad `CLAUDE.md` content (move it out):

- Long procedures. Move to a skill so they load only when needed.
- Path-specific rules. Use a path-specific block, or a skill with `paths:`.
- Persona or tone instructions. Move to an output style.
- Tutorials. Move to `docs/` (this directory) and link from a skill.

## Common pitfalls

- **Treating "command" and "skill" as different things.** They are the same construct. A skill whose invocation is restricted to the user behaves like an old-style command. A skill that Claude can auto-invoke behaves like background knowledge. Pick the invocation mode, not the construct.
- **Putting a procedure in `CLAUDE.md` to make sure Claude remembers it.** Once the procedure exceeds a few lines, a skill is cheaper because it loads only when invoked.
- **Using a subagent for a single bounded task.** A forking skill gives the same isolation with less ceremony.
- **Using a skill to enforce behavior.** Skills are advisory. If the behavior must hold regardless of what the model decides, use a hook.
- **Skipping `description` keywords.** Claude matches user requests against the `description`. Vague descriptions reduce auto-invocation. Put the concrete trigger phrases in the first 200 characters.
- **Bloating `SKILL.md`.** Keep the main file focused on what is needed up front. Move details to sibling files (`reference.md`, `examples.md`) and link from `SKILL.md`. Claude reads siblings on demand.
- **Forgetting that a loaded skill stays loaded.** Skill content remains in context for the rest of the session after first invocation. Write its body as standing guidance, not one-shot steps.

## File locations cheat sheet

| Construct | Personal | Project | Plugin |
| --- | --- | --- | --- |
| Memory file | `~/.claude/CLAUDE.md` | `<repo>/CLAUDE.md` | n/a |
| Skill | `~/.claude/skills/<name>/SKILL.md` | `<repo>/.claude/skills/<name>/SKILL.md` | `<plugin>/skills/<name>/SKILL.md` |
| Subagent | `~/.claude/agents/<name>.md` | `<repo>/.claude/agents/<name>.md` | `<plugin>/agents/<name>.md` |
| Hook config | `~/.claude/settings.json` | `<repo>/.claude/settings.json` | `<plugin>/hooks/` |
| Output style | `~/.claude/output-styles/<name>.md` | `<repo>/.claude/output-styles/<name>.md` | `<plugin>/output-styles/<name>.md` |
| MCP config | `~/.claude/settings.json` `mcpServers` | `<repo>/.mcp.json` | `<plugin>/mcp/` |

Precedence when names collide: enterprise > personal > project. Plugin skills use a `plugin:skill` namespace and cannot collide with other levels.

## Worked examples

**"I want every commit message in this repo to follow Conventional Commits."**
A rule that applies across the project on every turn → `CLAUDE.md`. If the rule needs examples and counter-examples, promote it to a skill named `commit-message` with `description` keyed on "commit message", and reference it from `CLAUDE.md`.

**"I want `/commit` to stage, run lint, and commit."**
User-triggered task with side effects → task skill (Pattern A): user-only invocation with the required tools pre-approved.

**"When the user asks what changed, summarize the diff."**
Auto-invoked procedure → procedure skill (Pattern C) that injects `git diff HEAD` into its prompt.

**"Block `git commit` in `jj` repos and redirect to `jj describe`."**
Deterministic enforcement → PreToolUse hook.

**"Give me a code reviewer I can delegate any diff to."**
A reusable role the main agent calls many times → subagent in `.claude/agents/code-reviewer.md`.

**"Run a one-off codebase exploration without polluting my main context."**
Bounded task with isolation → a skill that forks into a read-only investigation subagent (see the Subagent vs forking-skill section).

**"Talk to me like a pirate this session."**
Tone change, not behavior change → output style.

**"Pull Jira tickets into the conversation."**
Authenticated remote integration with typed inputs → MCP server.

## References

Official docs (verify if anything in this file looks stale):

- Skills: <https://code.claude.com/docs/en/skills>
- Subagents: <https://code.claude.com/docs/en/sub-agents>
- Hooks: <https://code.claude.com/docs/en/hooks>
- Memory and `CLAUDE.md`: <https://code.claude.com/docs/en/memory>
- Plugins: <https://code.claude.com/docs/en/plugins>
- Permissions: <https://code.claude.com/docs/en/permissions>
- Output styles: <https://code.claude.com/docs/en/output-styles>
- Commands reference: <https://code.claude.com/docs/en/commands>
