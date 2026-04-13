---
applyTo: "**/*.{test,spec}.{js,jsx,ts,tsx}"
---

<!--
File contents are added to GitHub Copilot's context in VS Code and Copilot code reviews when files in the context match the `applyTo`.

Docs: https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions
-->

## Tech Stack & Tools

- **Framework:** React, TypeScript, Vitest, React Testing Library.
- **Test Runner:** `yarn test` or `./node_modules/.bin/vitest` (Run in `app/frontend/app` directory).
- **Mocking:** Use `vi.fn()` / `vi.mock()` (Vitest) instead of `jest.fn()`.

## Test Naming Convention

Follow the `[Subject] [Action] [Target] [Result]` structure.

**Formats:**

```tsx
describe("area/component", () => {
    it("[Subject] [Action] ?[Target] ?[Result]", () => {});
    it("[Target] ?[Result] ?[Action] [Subject]", () => {});
});
```

Examples:

✅ it("Sales User redirects from Assigned Insights page to the home page", ...)

✅ it("Submit Button is disabled when form is invalid", ...)

## Rules

### General

- **Cleanup:** Never manually call `cleanup()`. It is handled automatically.
- **Console:** Do not globally mock `console`. If needed, mock it only inside a specific `it` block.
- **Mocks:** Ensure all `vi.mock` calls are at the top level of the file.

### Modern Testing Standards (New Files Only)

Use these rules ONLY when creating new files or when a file already follows these patterns:

- **Scope:** Use `screen` for all queries. Do not destructure `render`.
- **Queries:** Prioritize `getByRole` or `findByRole`.
- **User Events:** Use `@testing-library/user-event` v14+.
    - _Pattern:_ `const user = userEvent.setup(); await user.click(element);`
- **Assertions:** Use `jest-dom` matchers (e.g., `.toBeInTheDocument()`, `.toBeDisabled()`).

### Legacy Adaptation (Existing Files)

**CRITICAL:** Before writing code, check existing imports and patterns.

- **Consistency:** If the file uses `fireEvent` or destructures `render`, match that style exactly.
- **No Stealth Refactors:** Do not update legacy patterns to modern standards unless specifically instructed to "refactor"
