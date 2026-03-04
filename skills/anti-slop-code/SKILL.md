---
name: anti-slop-code
description: Write intentional, minimal, context-aware code that avoids generic AI-generated patterns. Use this skill when refactoring code, when the user asks to simplify or clean up code, or when writing new code with explicit instructions to keep it simple or minimal. Also trigger when the user mentions "slop", "over-engineering", "too verbose", "unnecessary abstraction", or similar concerns about code quality. This skill helps produce code that reads like it was written by a thoughtful human engineer who understands the specific codebase and problem domain.
---

Every line of code must justify its existence. If you cannot explain why a line is necessary for THIS problem in THIS codebase, delete it.

## Before Writing

- What is the minimal delta from the current state?
- What patterns does the codebase already use? Follow them exactly.
- What should NOT be touched?

## Principles

| Principle | Do | Don't |
|---|---|---|
| Minimalism | Inline one-use logic. Flat conditionals. | Extract one-use helpers. Strategy pattern for one case. |
| Coherence | Mirror existing style, naming, error idiom. | Introduce a "better" pattern that conflicts with the current one. |
| Error handling | Handle errors that can actually occur. Include values and context in messages. | Re-validate already-validated inputs. Guard against what the type system guarantees. |
| Comments | Explain WHY: business rules, trade-offs, workarounds. Use precise terms that match what the code does. One point per sentence. | Restate WHAT the code does. Add section headers (`// Validation`). Chain points with em dashes or semicolons. Use vague terms when a precise one exists. |
| Scope | Change what was asked. | "Improve" neighboring code. Add docstrings to unchanged code. |
| Tests | Test observable behavior from the user's perspective. Integration tests over mock-heavy unit tests. | Test getters/setters/framework wiring. Assert that a mock was called with specific arguments. |

## Avoid These Patterns

- try/catch around calls that don't throw
- Null checks on type-guaranteed values
- Section-header comments — reorganize, don't label
- One-use `utils/helpers` — inline them
- Configurable parameters for values that never change
- Entry/exit logging with no debugging purpose
- Interfaces with only one implementation
- `TODO` comments for things to implement now
- Wrapper functions that add a name but no logic (`isPositive(x)` vs `x > 0`)
- Re-exports or shims for removed code

## Examples

Sloppy comment style (Go):
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

Restating comments (Python):
```python
# AI slop: restating the code
# Check if user is admin
if user.role == "admin":
    # Grant admin access
    grant_access(user, "admin")

# Intentional: comment explains the non-obvious
# Admin tokens expire in 5 min, not 60 min (SEC-1234)
if user.role == "admin":
    grant_access(user, "admin", ttl=300)
```

Phantom error handling (Go):
```go
// AI slop: guarding against the impossible
func process(items []Item) error {
    if items == nil {
        return errors.New("nil items")
    }
    ...
}

// Intentional: trust the contract, handle what actually fails
func process(items []Item) error {
    for _, item := range items {
        if err := item.Validate(); err != nil {
            return fmt.Errorf("item %s: %w", item.ID, err)
        }
    }
}
```

Unnecessary abstraction (TypeScript):
```typescript
// AI slop: one-use utility extracted "for clarity"
function isValidAge(age: number): boolean {
  return age >= 0 && age <= 150;
}
if (isValidAge(user.age)) { ... }

// Intentional: inline what is used once
if (user.age >= 0 && user.age <= 150) { ... }
```

When in doubt, write the naive version first. If it works and reads clearly, it is done.
