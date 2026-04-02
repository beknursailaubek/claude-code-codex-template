---
name: frontend-design
description: Create distinctive, production-grade frontend interfaces with high design quality. Avoids generic AI aesthetics. Use when building web components, pages, dashboards, or landing pages.
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
---

# Skill: Frontend Design

## Purpose
Create frontend interfaces that are visually distinctive, production-grade, and avoid the "generic AI slop" aesthetic. Every component should look intentionally designed, not template-generated.

## When to Use
- Building a new page, component, or layout
- Redesigning or improving existing UI
- Creating a landing page, dashboard, or form
- Any frontend work where visual quality matters

## Core Principle

> **Commit to a BOLD aesthetic direction before writing code.**

Do not start coding until you have decided: What should this look and feel like? Generic defaults produce generic results.

## Design Process

### Step 1 — Understand Context
Before any code, answer these four questions:

| Dimension | Question |
|---|---|
| **Purpose** | What problem does this solve? Who is the user? |
| **Tone** | What aesthetic? (brutalist, retro-futuristic, minimal, corporate, playful, etc.) |
| **Constraints** | Tech stack, performance budget, responsive requirements, accessibility |
| **Differentiation** | What makes this memorable? What would a screenshot look like? |

### Step 2 — Choose an Aesthetic Direction
Pick one and commit. DO NOT blend everything into a safe middle ground.

| Direction | Characteristics |
|---|---|
| **Minimalist** | Whitespace, restraint, one accent color, large typography |
| **Bold corporate** | Strong grid, sharp contrast, data-forward, confident spacing |
| **Brutalist** | Raw, exposed structure, monospace type, high contrast |
| **Warm organic** | Rounded corners, earthy palette, soft shadows, natural textures |
| **Dashboard-dense** | Compact, data-rich, dark mode, subtle borders, information hierarchy |
| **Editorial** | Magazine layout, strong typography hierarchy, pull quotes, whitespace |

### Step 3 — Implement with Attention to Detail

**Typography** (most impactful, cheapest to fix):
- Choose a distinctive font pairing — NEVER default to Arial, Inter, or system fonts without intention
- Establish clear hierarchy: display → heading → subheading → body → caption
- Line height: 1.2–1.3 for headings, 1.5–1.7 for body
- Letter spacing: tighter for large text, normal for body

**Color** (second most impactful):
- Start with 1 primary + 1 accent + neutrals
- Use HSL for consistency — vary lightness, keep hue/saturation stable
- Dark mode: don't just invert — reduce contrast, adjust saturation
- Test: screenshot at 50% zoom — can you still see the hierarchy?

**Spacing and Layout**:
- Use a consistent spacing scale (4, 8, 12, 16, 24, 32, 48, 64)
- Asymmetric layouts are more interesting than centered everything
- Group related elements with proximity, separate with whitespace
- Card grids: vary sizes for visual interest

**Motion** (use purposefully, not decoratively):
- Entrance animations: subtle fade + translate (150–300ms)
- Hover states: scale, shadow, or color shift (100–200ms)
- Page transitions: shared element morphing or cross-fade
- NEVER: bouncing, spinning, or attention-grabbing without purpose

**Backgrounds and Atmosphere**:
- Gradients: subtle, 2–3 stops, mesh gradients for depth
- Textures: noise overlays, grain, subtle patterns
- Layering: use z-depth with shadows and opacity to create depth

## Stack-Specific Rules

### Next.js + Mantine
- Use Mantine's theme system — extend, don't fight it
- Custom theme: override `primaryColor`, `fontFamily`, `spacing`, `radius`
- Use `createTheme()` and `MantineProvider` — consistent across app
- Server Components by default — client only for interactivity
- Use Mantine's responsive props (`visibleFrom`, `hiddenFrom`)

### Tailwind CSS
- Define theme colors in `tailwind.config` — use semantic names (`primary`, `surface`, `muted`)
- Use `@apply` sparingly — prefer utility classes in JSX
- Custom animations in `extend.keyframes`
- Dark mode: `dark:` variant with intentional color choices

### Raw CSS/HTML
- CSS custom properties for theming: `--color-primary`, `--space-md`
- Use `clamp()` for fluid typography: `clamp(1rem, 2vw + 0.5rem, 1.5rem)`
- Container queries over media queries when supported
- Grid for layout, Flexbox for alignment

## Anti-Patterns to AVOID

| Bad | Why | Instead |
|---|---|---|
| Arial/Inter everywhere | Looks template-generated | Choose a distinctive font pair |
| `#007bff` blue buttons | Bootstrap default = generic | Define your own primary color |
| Equal padding everywhere | No visual hierarchy | Vary spacing by importance |
| Centered everything | Static, boring composition | Use asymmetric layouts |
| Rainbow gradients | Noisy, unprofessional | 2-color subtle gradients |
| Animations on everything | Distracting | Only on user-initiated actions |
| White cards on gray | Default Material UI | Use color, texture, or depth |
| Stock illustrations | Screams "template" | Custom icons, shapes, or photos |

## Accessibility (Non-Negotiable)
- Color contrast: 4.5:1 for text, 3:1 for large text (WCAG AA)
- Focus indicators: visible, styled, not browser default
- Semantic HTML: use `<nav>`, `<main>`, `<section>`, `<article>`
- Keyboard navigation: all interactive elements reachable via Tab
- Screen readers: meaningful `alt` text, `aria-label` where needed
- Motion: respect `prefers-reduced-motion`

## Expected Output
- Visually distinctive implementation that matches chosen aesthetic
- Responsive across mobile/tablet/desktop
- Accessible (WCAG AA minimum)
- Performance-conscious (lazy loading, optimized images, minimal JS)
- Consistent with project's existing design system if one exists

## Completion Criteria
- [ ] Aesthetic direction chosen and documented
- [ ] Typography hierarchy established (not default fonts)
- [ ] Color palette intentional (not default blue)
- [ ] Spacing consistent (using a scale)
- [ ] Responsive on 3 breakpoints
- [ ] Accessibility: contrast, focus, semantic HTML
- [ ] Motion: purposeful or absent (not decorative)
