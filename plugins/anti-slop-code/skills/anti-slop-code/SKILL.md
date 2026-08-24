---
name: anti-slop-code
description: Write intentional, minimal, context-aware code that avoids generic AI-generated patterns. Use this skill when refactoring code, when the user asks to simplify or clean up code, or when writing new code with explicit instructions to keep it simple or minimal. Also trigger when the user mentions "slop", "over-engineering", "too verbose", "unnecessary abstraction", or similar concerns about code quality. This skill helps produce code that reads like it was written by a thoughtful human engineer who understands the specific codebase and problem domain.
model: opus
---

Every line of code must justify its existence. If you cannot explain why a line is necessary for THIS problem in THIS codebase, delete it.

## Start From the Minimal Delta

Before writing, answer three questions:

1. What is the minimal delta from the current state?
2. What patterns does the codebase already use?
3. What should NOT be touched?

Change only what was asked. Do not "improve" neighboring code, add docstrings to unchanged code, or leave entry/exit logging with no debugging purpose.

## Inline One-Use Logic

```typescript
// AI slop: one-use utility extracted "for clarity"
function isValidAge(age: number): boolean {
  return age >= 0 && age <= 150;
}
if (isValidAge(user.age)) { ... }

// Intentional: inline what is used once
if (user.age >= 0 && user.age <= 150) { ... }
```

The same rule covers every indirection with a single user: interfaces with only one implementation, wrapper functions that add a name but no logic (`isPositive(x)` vs `x > 0`), configurable parameters for values that never change, and re-exports or shims for removed code. Delete them.

## Handle Errors That Can Actually Occur

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

Do not re-validate already-validated inputs, wrap calls that don't throw in try/catch, or null-check values the type system guarantees. In the errors you do handle, include values and context in the message.

## Mirror the Existing Codebase

Follow the existing style, naming, and error idiom exactly. Do not introduce a "better" pattern that conflicts with the current one. The inconsistency costs readers more than the improvement gains.

When in doubt, write the naive version first. If it works and reads clearly, it is done.
