---
name: spec-implementation-check
description: Check the current implementation diff against a spec. Use before committing a completed AC, or when asked to run spec-implementation-check.
argument-hint: "<docs/specs/spec-file.md or GitHub Issue URL>"
---

Check the current implementation diff against the given spec.

If no spec path is provided, ask for it.

Read the entire spec and identify the target AC-N task, whose acceptance-criterion bullets are all part of this check. Follow the existing spec compatibility rules in `../spec-driven-development/SKILL.md` for old-format specs, without rewriting their structure.

1. Run the project's narrowest relevant tests or existence checks covering all acceptance criteria of the target task. Compare the results and implementation with the task's opening explanation, common technical constraints, task-specific technical constraints, and explicitly referenced definitions and reasons. Follow further references as needed. Check that dependencies and operational start conditions were satisfied, not merely that dependency tasks were marked complete. Report contradictions or uncovered requirements rather than treating passing tests as sufficient. Include affected existing behavior protected by other tasks in the check, without requiring unrelated unfinished tasks to be implemented. Report these results under Axis A.
2. Read the current diff against those requirements, including requirements that cannot be verified by running tests alone.
3. Ask `negative-requirements-reviewer` to compare the diff with the spec's negative requirements. Provide the entire spec, the target task identifier, and the diff, not just the target task's section. The review includes common requirements, the target task, explicit reference destinations, and prohibitions in other tasks that protect behavior affected by the diff. Report its candidates under Axis B.
4. Run `spec-scope-check.sh <spec-path>` to compare the current diff with the spec's scope limit. The script sits in the same directory as this SKILL.md.
5. Report Axis A, Axis B, Axis C, and the final judgement.

If no project-defined test command exists, mark Axis A skipped only for documentation-only work or with user approval.

Do not create Agent Teams, dependency-order blockers, or front-matter consistency tools. Report findings in the reply instead of opening new GitHub Issues.

When the judgement is a return, classify the failure:

- 変換エラー: the spec is right and the code mistranscribed it. Fix locally and stay in implementation.
- 仕様欠陥: implementation revealed an ambiguity or error in the spec. Return to spec-authoring, fix the spec in its own commit, then re-implement.

A human makes the final call on Axis B and Axis C candidates, so report them as human judgement needed instead of deciding alone. For an Axis C overflow, say that it may signal the design grew during implementation and the spec was not settled, and leave the call to the user.

Report:

- Axis A: passed / failed / skipped
- Axis B: no candidates / candidates / skipped
- Axis C: no candidates / candidates / skipped
- Judgement: commit allowed / human judgement needed / return to implementation (変換エラー) / return to spec (仕様欠陥)
