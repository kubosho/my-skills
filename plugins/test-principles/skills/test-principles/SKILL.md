---
name: test-principles
description: Principles for writing high-quality automated tests, based on Kent Beck, Kent C. Dodds, and t-wada. This skill MUST be used whenever writing or modifying implementation code — tests are part of implementation, not a separate step. Also use when writing tests, asked to "write tests", "add tests", "test this", reviewing or auditing existing tests, "review tests", "check test quality", "テストを書いて", or "テスト原則". If you are implementing a feature or fixing a bug, this skill applies.
---

# Automated Test Principles

HOW to write tests (verification), not WHAT to test (validation). Which behaviors to cover is a human decision.

## Tests Are Part of Implementation

When implementing features or fixing bugs, write tests in the same change. Red → Green → Refactor:

1. Write a failing test that describes the desired behavior
2. Write the minimum implementation to make it pass
3. Refactor — the test guards the behavior
4. Add edge case tests in a separate section

AI agents tend to write all implementation first and bolt on tests afterward. Tests written this way unconsciously verify what was just built rather than what the code should do. Interleave instead.

If the user asks only for implementation without mentioning tests, still write them. Say so briefly: "Adding tests alongside the implementation to keep them behavior-focused."

## Assert the Result, Not the Process

Verify "a delicious nikujaga was made," not "the knife moved at 3cm intervals." If you only verify process, you might accidentally make curry and the tests still pass.

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

|                | Integration          | Unit                                |
| -------------- | -------------------- | ----------------------------------- |
| Behavior       | Highest value        | Useful, but misses integration bugs |
| Implementation | Don't test this      | Don't test this                     |

## Name Tests as Mini-Specifications

The test name states the scenario and expected result. If the name is accurate, the assertion is almost redundant.

```typescript
// Describes the mechanism — you must read the assertion to know the outcome
test('parses key=value pairs', () => { ... });
test('decodes URI-encoded characters', () => { ... });

// Describes the result — the reader knows the expected behavior from the name alone
test('?foo=1 returns { foo: "1" }', () => { ... });
test('%E5%BA%83 in value decodes to 広', () => { ... });
test('key without = maps to empty string', () => { ... });
test('20% coupon on $100 order results in $80 total', () => { ... });
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

Reserve `toBeTruthy` for functions whose contract is boolean.

## Separate Edge Cases Visually

```typescript
describe('applyDiscount', () => {
  describe('percentage discount', () => {
    it('10% off $200 yields $180', () => { ... });
    it('100% off yields $0', () => { ... });
  });

  describe('edge cases', () => {
    it('empty cart returns 0 regardless of rule', () => { ... });
    it('discount exceeding subtotal floors at 0', () => { ... });
    it('maxDiscount caps a larger percentage', () => { ... });
  });
});
```

## Constraints

- **Fast**: slow tests break the feedback loop — you stop running them and start deferring fixes. Eliminate slow dependencies where the behavior under test doesn't cross that boundary.
- **Deterministic**: a flaky test erodes trust in the entire suite. No time-dependent logic, unseeded randomness, or shared mutable state.
- **Independent**: if test B fails only when test A runs first, that's a hidden dependency bug. Each test produces the same result regardless of execution order.
- **Not the only safety net**: automated tests catch regressions during development. Complement with real browser testing, monitoring, and manual QA.

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
