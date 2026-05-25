---
name: test-principles
description: Principles for writing high-quality automated tests, based on Kent Beck, Kent C. Dodds, and t-wada. This skill MUST be used whenever writing or modifying implementation code — tests are part of implementation, not a separate step. Also use when writing tests, asked to "write tests", "add tests", "test this", reviewing or auditing existing tests, "review tests", "check test quality", "テストを書いて", or "テスト原則". If you are implementing a feature or fixing a bug, this skill applies.
---

# Automated Test Principles

HOW to write tests (verification), not WHAT to test (validation). Which behaviors to cover is a human decision.

## Tests Are Part of Implementation

When implementing features or fixing bugs, write tests in the same change. Red → Green → Refactor:

1. Write a failing test that describes the desired behavior
2. Write the minimum implementation that passes
3. Refactor with the behavior guarded
4. Add edge cases in a separate section

Interleave tests with implementation. Tests bolted on afterward tend to verify what was built, not what the code should do.

If the user asks only for implementation without mentioning tests, still write them. Say so briefly: "Adding tests alongside the implementation to keep them behavior-focused."

## Assert the Result, Not the Process

Assert observable behavior, not internal mechanics.

```typescript
// Breaks if you refactor from reduce to for-loop
it('should call reduce internally', () => {
  const spy = vi.spyOn(items, 'reduce');
  applyDiscount(items, { type: 'fixed', value: 10 });
  expect(spy).toHaveBeenCalled();
});

// Survives any internal refactor
it('fixed $10 discount on $100 item yields $90', () => {
  const items = [{ name: 'Shirt', price: 100, quantity: 1 }];
  expect(applyDiscount(items, { type: 'fixed', value: 10 })).toBe(90);
});
```

Prefer integration tests when behavior crosses module boundaries. Use unit tests for isolated domain rules. Do not test implementation details in either.

## Name Tests as Mini-Specifications

Test names state the scenario and expected result.

```typescript
// Weak: mechanism, not outcome
test('parses key=value pairs', () => { ... });
test('decodes URI-encoded characters', () => { ... });

// Better: scenario and result
test('?foo=1 returns { foo: "1" }', () => { ... });
test('%E5%BA%83 in value decodes to 広', () => { ... });
test('key without = maps to empty string', () => { ... });
```

`'handles X'` or `'processes Y'` describes the implementation, not the behavior.

## Make Failures Self-Diagnosing

```typescript
// Failure says "expected true, received false"
expect(result === 160).toBe(true);
expect(result).toBeTruthy();

// Failure says "expected 160, received 140"
expect(result).toBe(160);
```

Reserve `toBeTruthy` for boolean contracts.

## Separate Edge Cases Visually

Group primary behavior and edge cases separately. Boundary tests should be easy to find without scanning the happy path.

## Constraints

- **Fast**: eliminate slow dependencies when the behavior under test does not cross that boundary.
- **Deterministic**: a flaky test erodes trust in the entire suite. No time-dependent logic, unseeded randomness, or shared mutable state.
- **Independent**: each test produces the same result regardless of execution order.
- **Not the only safety net**: complement automated tests with real browser testing, monitoring, and manual QA.

## Review Checklist

**Each test:**
- [ ] Asserts the result, not the process?
- [ ] Failure message is self-diagnosing?
- [ ] Name states the scenario and expected result?
- [ ] Connected to the problem domain, not generic AI slop?

**What's missing:**
- [ ] Boundary conditions? (empty input, zero, max values, off-by-one)
- [ ] Error paths or edge cases?
- [ ] Combinations that matter? (feature A + feature B together)

Flag issues with a concrete fix. For missing coverage, suggest specific test cases with expected values.
