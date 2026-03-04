---
name: baseline
description: |
  Check Baseline status of web features using the Web Platform Status API.
  Triggers: "baseline", "ベースライン", "ブラウザ対応状況", "browser support", "web feature status"
  Use cases: (1) check if a web feature is widely/newly available, (2) check browser support for a feature, (3) find features not available in a specific browser
argument-hint: "<feature name, structured query, or natural language, e.g. 'popover', 'Promise.withResolvers', 'not:firefox', 'Safariで使えないCSS機能'>"
---

# Baseline Web Feature Status Skill

Query the Web Platform Status API to check browser Baseline status of web features.

## Query Building

**Endpoint**: `GET https://api.webstatus.dev/v1/features?q={query}`

### Operators

| Operator | Example |
|----------|---------|
| `available_date:<browser>:<start>..<end>` | `available_date:chrome:2023-01-01..2024-01-01` |
| `available_on:<browser>` | `available_on:chrome` |
| `baseline_date:<start>..<end>` | `baseline_date:2023-01-01..2024-01-01` |
| `baseline_status:<status>` | `baseline_status:widely` |
| `group:<group>` | `group:css` |
| `name:<keyword>` | `name:grid` |
| `snapshot:<snapshot>` | `snapshot:ecmascript-5` |
| (plain text) | `grid` |

- **Statuses**: `widely`, `newly`, `limited`, `no_data`
- **Browsers**: `chrome`, `edge`, `firefox`, `safari`
- **AND**: separate with spaces
- **OR**: join with `+OR+`
- **Negate**: prefix with `-`

### Natural Language Translation

Translate the user's intent into operators. Show the translated query so the user can learn the syntax.

| User input | API query |
|------------|-----------|
| `popover` | `name:popover` |
| `css nesting` | `name:nesting` |
| `Promise.withResolvers` | `name:promise-withresolvers` |
| `not:safari` | `-available_on:safari` |
| `Safariで使えるけどFirefoxで使えない機能` | `available_on:safari -available_on:firefox` |
| `dialogかpopoverの対応状況` | `name:dialog+OR+name:popover` |

## Output Format

Adapt to result count: detail for 5 or fewer, summary table for more.

### Example (single feature)

```
## Feature: Popover API

**Baseline status**: Newly available — supported in all major browsers, but some users may not have updated yet.

**Support dates**:
- Newly available: 2024-04-17

**Browser support**:
- Chrome: 114 (2023-05-30)
- Edge: 114 (2023-06-02)
- Firefox: 125 (2024-04-16)
- Safari: 17 (2023-09-18)

**Daily usage (Chrome)**: 8.2%
```

For 5+ results, use a summary table (feature name + baseline status). Limit to first 20, showing total count.

## Constraints

- If the API returns empty results or an error, suggest alternative queries
- If argument is empty, ask the user for a feature name or query
- Usage `daily` is a fraction (0–1); display as percentage
- Timeout after 10 seconds
- Maximum 3 concurrent API requests
