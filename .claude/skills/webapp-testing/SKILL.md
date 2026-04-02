---
name: webapp-testing
description: Test web applications using Playwright. Covers visual inspection via screenshots, DOM element discovery, form interaction, and end-to-end user flow verification. Use for e2e tests and UI debugging.
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
---

# Skill: Web App Testing

## Purpose
Test web applications systematically using Playwright. Covers both interactive debugging (screenshot → inspect → act) and automated e2e test creation.

## When to Use
- Writing e2e tests for a web application
- Debugging UI behavior that can't be reproduced from code alone
- Verifying frontend changes after implementation
- Testing user flows end-to-end (auth, forms, navigation)

## Prerequisites
```bash
# Check if Playwright is installed
npx playwright --version 2>/dev/null || echo "MISSING: install with 'npx playwright install'"
```

## Workflow

### Decision Tree
```
Is it static HTML?
  → YES: Read the file directly, find selectors, write test
  → NO: Is a dev server already running?
    → YES: Reconnaissance (screenshot → DOM → selectors → test)
    → NO: Start server first, then reconnaissance
```

### Step 1 — Start the Application
```bash
# Start dev server in background
npm run dev &
DEV_PID=$!

# Wait for server to be ready
npx wait-on http://localhost:3000 --timeout 30000
```

For multiple servers (e.g., API + frontend):
```bash
npm run dev:api &
npm run dev:web &
npx wait-on http://localhost:3001 http://localhost:3000
```

### Step 2 — Reconnaissance
**CRITICAL: Wait for the page to fully load before inspecting.**

```typescript
import { chromium } from 'playwright';

const browser = await chromium.launch();
const page = await browser.newPage();
await page.goto('http://localhost:3000');
await page.waitForLoadState('networkidle');  // ← ALWAYS wait for this

// Screenshot for visual inspection
await page.screenshot({ path: '/tmp/page-screenshot.png', fullPage: true });

// Get page structure
const title = await page.title();
const headings = await page.$$eval('h1, h2, h3', els => els.map(e => e.textContent));
const links = await page.$$eval('a', els => els.map(e => ({ text: e.textContent, href: e.href })));
const buttons = await page.$$eval('button, [role="button"]', els => els.map(e => e.textContent));
const forms = await page.$$eval('form', els => els.map(e => e.id || e.action));
const inputs = await page.$$eval('input, select, textarea', els =>
  els.map(e => ({ type: e.type, name: e.name, id: e.id, placeholder: e.placeholder }))
);

console.log({ title, headings, links, buttons, forms, inputs });
```

### Step 3 — Find Selectors
Priority order for reliable selectors:
1. **`data-testid`** — most stable: `[data-testid="login-button"]`
2. **`role` + name** — accessible: `getByRole('button', { name: 'Login' })`
3. **`aria-label`** — accessible: `[aria-label="Close dialog"]`
4. **`id`** — stable if present: `#submit-form`
5. **Text content** — fragile but readable: `getByText('Submit')`
6. **CSS selector** — last resort: `.form-container > button:first-child`

**Avoid:** XPath, positional selectors, auto-generated class names.

### Step 4 — Write Tests

```typescript
import { test, expect } from '@playwright/test';

test.describe('User Authentication', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login');
    await page.waitForLoadState('networkidle');
  });

  test('successful login redirects to dashboard', async ({ page }) => {
    await page.getByLabel('Email').fill('user@example.com');
    await page.getByLabel('Password').fill('password123');
    await page.getByRole('button', { name: 'Sign in' }).click();

    await page.waitForURL('/dashboard');
    await expect(page.getByRole('heading', { name: 'Dashboard' })).toBeVisible();
  });

  test('invalid credentials show error', async ({ page }) => {
    await page.getByLabel('Email').fill('wrong@example.com');
    await page.getByLabel('Password').fill('wrong');
    await page.getByRole('button', { name: 'Sign in' }).click();

    await expect(page.getByText('Invalid credentials')).toBeVisible();
    await expect(page).toHaveURL('/login');  // stays on login page
  });

  test('empty form shows validation errors', async ({ page }) => {
    await page.getByRole('button', { name: 'Sign in' }).click();

    await expect(page.getByText('Email is required')).toBeVisible();
    await expect(page.getByText('Password is required')).toBeVisible();
  });
});
```

### Step 5 — Common Patterns

**Wait for API response before asserting:**
```typescript
await Promise.all([
  page.waitForResponse(resp => resp.url().includes('/api/users') && resp.status() === 200),
  page.getByRole('button', { name: 'Save' }).click(),
]);
await expect(page.getByText('Saved successfully')).toBeVisible();
```

**File upload:**
```typescript
const fileInput = page.locator('input[type="file"]');
await fileInput.setInputFiles('test-data/document.pdf');
```

**Dialog handling:**
```typescript
page.on('dialog', dialog => dialog.accept());
await page.getByRole('button', { name: 'Delete' }).click();
```

**Screenshot on failure (auto in Playwright config):**
```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    screenshot: 'only-on-failure',
    trace: 'on-first-retry',
  },
});
```

**Console log monitoring:**
```typescript
const errors: string[] = [];
page.on('console', msg => {
  if (msg.type() === 'error') errors.push(msg.text());
});
// ... run test ...
expect(errors).toHaveLength(0);
```

### Step 6 — Run and Verify
```bash
# Run all tests
npx playwright test

# Run specific test file
npx playwright test tests/auth.spec.ts

# Run with UI mode (for debugging)
npx playwright test --ui

# Show HTML report
npx playwright show-report
```

## Test Categories Checklist

| Category | Tests to Write |
|---|---|
| **Auth flows** | Login, logout, register, forgot password, session expiry |
| **CRUD operations** | Create, read, update, delete for each resource |
| **Form validation** | Empty, invalid, boundary values, special characters |
| **Navigation** | All routes reachable, breadcrumbs, back button |
| **Responsive** | Mobile viewport, tablet, desktop |
| **Error states** | 404 page, API errors, network offline |
| **Loading states** | Skeleton screens, spinners, disabled buttons during submit |
| **Accessibility** | Keyboard navigation, focus management, screen reader |

## Anti-Patterns
- Hardcoded `setTimeout` instead of `waitForLoadState` or `waitForSelector`
- Testing implementation details (CSS classes, internal state) instead of user behavior
- Tests that depend on specific data — use fixtures or seed data
- Flaky selectors based on position or auto-generated classes
- Missing cleanup (server processes, test data)

## Completion Criteria
- [ ] Dev server starts and is reachable
- [ ] Page reconnaissance completed (screenshot + DOM structure)
- [ ] Selectors use stable attributes (data-testid, role, aria-label)
- [ ] Happy path tested for each user flow
- [ ] Error paths tested (invalid input, API errors)
- [ ] Tests pass consistently (no flaky tests)
- [ ] Cleanup: server processes killed after tests
