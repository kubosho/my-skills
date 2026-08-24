---
name: anti-slop-comment
description: Write only code comments that carry information the code and tests cannot. Use this skill when writing or reviewing code comments, when the user asks to clean up, reduce, or audit comments, or when deciding whether a comment is worth keeping. Also trigger when the user mentions redundant comments, restating comments, "comment slop", or asks what deserves a comment.
model: opus
---

Comments pass no checks. Code goes through the compiler, tests, and the linter, so a wrong line is rejected in minutes. A wrong comment survives until someone happens to reread it. Nothing removes unnecessary comments later, so the only control point is whether you write them.

## Keep Only Decisions No Test Protects

Keep a comment when both conditions hold:

1. It records a decision: two or more implementations were viable and you chose one. A future editor could rewrite the code to the rejected alternative, and to them it would look like an ordinary change.
2. No test fails when that rewrite happens.

```go
// AI slop: paraphrases the call directly below
// Return default settings when the user has none
if !ok {
    settings = NewDefaultSettings()
}

// Intentional: records a decision a future editor could silently reverse
// NOTE: email is UNIQUE, so use Only instead of First
// and treat multiple matching users as an error
u, err := client.User.Query().
    Where(user.EmailEQ(email)).
    Only(ctx)
```

Business rules, trade-offs, and workarounds pass the same test: they explain a choice the code cannot show. If a test already catches the reversal, delete the comment and trust the test.

## Delete Comments That Paraphrase the Code Below

```python
# AI slop: restating the code
# Check if user is admin
if user.role == "admin":
    # Grant admin access
    grant_access(user, "admin")

# Intentional: comment explains the non-obvious
# Admin tokens expire in 5 min, not the default 60, to shorten
# the window a leaked admin token stays usable (SEC-1234)
if user.role == "admin":
    grant_access(user, "admin", ttl=300)
```

A paraphrasing comment records how the writer reached the line, not what a reader needs. If it compensates for an unclear name or an unexplained return value, fix the name, not the comment.

## Keep Each Fact at Its Source Layer

Before writing down a fact that took effort to verify (a schema constraint, a return value's meaning), check where it is defined: the interface doc comment, the schema, the type. If it already lives there, do not repeat it at the call site. The effort it cost you to verify a fact is not evidence that the reader needs it here, and a repeated fact is a copy that can drift.

## Verify Claims Before Writing Them

Never write a claim of correspondence ("matches the table in docs/...") that you have not checked. A comment states its claim without evidence, so readers accept it without re-checking. A false claim hides the very mismatch it appears to rule out.

## Size Comments by the Caller's Contract

```go
// AI slop: paraphrases the signature, narrates the implementation,
// and is three lines because the neighboring method's comment is
// GetUsageStats reads one aggregate record per user.
// Users with no activity have no record, which is the initial
// state rather than an error, so existence is returned as a bool.
GetUsageStats(ctx context.Context, userID string) (*UsageStats, bool, error)

// Intentional: states only the contract the caller relies on
// GetUsageStats Users with no activity have no aggregate record. This is the initial state, not an error
GetUsageStats(ctx context.Context, userID string) (*UsageStats, bool, error)
```

Decide each comment's content from what the caller relies on, not from the length or structure of the neighboring declaration's comment. Symmetry with the neighbor produces signature paraphrases and implementation narration.

## Make Each Sentence One Precise Claim

```go
// AI slop: em dash joins two claims. "still work" is vague.
// Old cursors without an ID still work — they just lose the tie-breaker.

// Intentional: each sentence makes one precise claim
// Cursors without an ID are accepted for backward compatibility
// but may skip or duplicate rows on timestamp collisions.
```

```go
// AI slop: imprecise term ("split" vs what SplitN returns)
// caps the split at 2 parts

// Intentional: describes the actual behavior
// limits the returned slice to 2 elements
```

Use terms that match what the code actually does. Do not chain claims with em dashes or semicolons.

## Constraints

- **No section headers**: reorganize the code instead of labeling it (`// Validation`).
- **No TODO comments** for things to implement now.

When in doubt, delete the comment. If the deletion loses a decision that no test protects, that is the comment to keep.
