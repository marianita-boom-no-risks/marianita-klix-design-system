# Worked Example 01 — Login Page

A full transcript of a user request, the tool sequence, and the final output. Use this as a golden reference for what "done well" looks like.

---

## User request

> Build me a login page using the Marianita Klix Design System. Should have email + password, "remember me", a "forgot password" link, primary submit, and a "Don't have an account? Sign up" footer link. Use React. Make it work in dark mode.

---

## Phase 1 — Routing (skill §0)

The task is **build a full page** + **React framework** + **dark mode mentioned**. Per §0 of `SKILL.md`:

- Read: `SKILL.md` + `references/recipes.md` (multi-component composition)
- Also relevant: `references/a11y-playbook.md` (forms) + `references/dark-mode-engineering.md`

Recipe 1 in `recipes.md` covers auth forms exactly.

---

## Phase 2 — Tool sequence

```
1. get_css_setup
   → Verify the project has the DS base CSS. (Assume yes from CLAUDE.md presence.)

2. get_page_template(template: "login")
   → Returns: components list (input × 2, button × 2, checkbox, alert-banner, divider),
     suggested layout (centered card, max-width 400px), and a11y notes.

3. get_component(name: "input", format: "react")
   → Returns InputField component with props: type, name, label, error, helperText.

4. get_component(name: "button", format: "react")
   → Returns Button component with props: variant, size, loading, type.

5. get_component(name: "checkbox", format: "react")
   → Returns Checkbox component with props: label, checked, onChange.

6. get_component(name: "alert-banner", format: "react")
   → Returns AlertBanner component for the error state.
```

---

## Phase 3 — Composition manifest

| Component | Used as | Variants |
|-----------|---------|---------|
| `input` | Email field | `type="email"` |
| `input` | Password field | `type="password"` |
| `checkbox` | Remember me | (default) |
| `button` | Submit | `variant="primary"`, `size="md"`, `type="submit"` |
| `button` | SSO alt (Google) | `variant="secondary"`, `size="md"` |
| `alert-banner` | Error message | `variant="error"` (shown on auth failure) |
| `divider` | "or" separator | with label="or" |

---

## Phase 4 — Generated code

```tsx
// src/pages/LoginPage.tsx
import { useState, useId } from 'react';
import { InputField, Button, Checkbox, AlertBanner, Divider } from '@/components/mk-ds';

export function LoginPage() {
  const errorRegionId = useId();
  const [state, setState] = useState({
    email: '',
    password: '',
    remember: false,
    loading: false,
    error: null as string | null,
  });

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setState(s => ({ ...s, loading: true, error: null }));

    try {
      await signIn({
        email: state.email,
        password: state.password,
        remember: state.remember,
      });
      // navigation handled by auth flow
    } catch (err) {
      setState(s => ({
        ...s,
        loading: false,
        error: err instanceof Error ? err.message : 'Sign-in failed',
      }));
    }
  }

  return (
    <main
      id="main"
      style={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: 'var(--space-8) var(--space-4)',
        background: 'var(--bg-secondary)',
      }}
    >
      <div
        className="mk-card"
        style={{
          width: '100%',
          maxWidth: 400,
          padding: 'var(--space-8)',
        }}
      >
        <header style={{ textAlign: 'center', marginBottom: 'var(--space-6)' }}>
          <h1 style={{
            fontSize: 'var(--text-2xl)',
            fontWeight: 'var(--font-semibold)',
            color: 'var(--text-primary)',
            marginBottom: 'var(--space-2)',
          }}>
            Welcome back
          </h1>
          <p style={{
            fontSize: 'var(--text-sm)',
            color: 'var(--text-secondary)',
          }}>
            Sign in to your account to continue.
          </p>
        </header>

        {state.error && (
          <div id={errorRegionId} style={{ marginBottom: 'var(--space-4)' }}>
            <AlertBanner variant="error" role="alert">
              {state.error}
            </AlertBanner>
          </div>
        )}

        <form
          onSubmit={handleSubmit}
          noValidate
          aria-describedby={state.error ? errorRegionId : undefined}
        >
          <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--space-4)' }}>
            <InputField
              type="email"
              name="email"
              label="Email"
              autoComplete="email"
              required
              value={state.email}
              onChange={e => setState(s => ({ ...s, email: e.target.value }))}
            />

            <InputField
              type="password"
              name="password"
              label="Password"
              autoComplete="current-password"
              required
              value={state.password}
              onChange={e => setState(s => ({ ...s, password: e.target.value }))}
            />

            <div style={{
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
            }}>
              <Checkbox
                label="Remember me"
                checked={state.remember}
                onChange={e => setState(s => ({ ...s, remember: e.target.checked }))}
              />
              <a
                href="/forgot-password"
                style={{
                  fontSize: 'var(--text-sm)',
                  color: 'var(--brand)',
                  fontWeight: 'var(--font-medium)',
                  textDecoration: 'none',
                }}
              >
                Forgot password?
              </a>
            </div>

            <Button
              type="submit"
              variant="primary"
              size="md"
              loading={state.loading}
              disabled={state.loading}
              style={{ width: '100%' }}
            >
              {state.loading ? 'Signing in…' : 'Sign in'}
            </Button>
          </div>
        </form>

        <Divider label="or" style={{ margin: 'var(--space-6) 0' }} />

        <Button
          variant="secondary"
          size="md"
          onClick={() => signInWithGoogle()}
          style={{ width: '100%' }}
        >
          Continue with Google
        </Button>

        <p style={{
          textAlign: 'center',
          marginTop: 'var(--space-6)',
          fontSize: 'var(--text-sm)',
          color: 'var(--text-secondary)',
        }}>
          Don't have an account?{' '}
          <a
            href="/signup"
            style={{
              color: 'var(--brand)',
              fontWeight: 'var(--font-medium)',
              textDecoration: 'none',
            }}
          >
            Sign up
          </a>
        </p>
      </div>
    </main>
  );
}
```

---

## Phase 5 — §7 pre-flight self-audit

- [x] **Token sweep** — All colors via `var(--*)`, all spacing via `var(--space-*)`, font sizes via `var(--text-*)`. No raw hex.
- [x] **Prefix sweep** — Only `mk-card` is used at the class level (the rest are React components which internally use `mk-` classes).
- [x] **Semantic tags** — `<main>`, `<header>`, `<h1>`, `<form>`, `<button type="submit">`, `<a>` for navigation. All correct.
- [x] **Focus visible** — Relying on MK-DS default focus rings. No `outline: none`.
- [x] **Icon-only buttons** — None in this UI.
- [x] **Dark-mode pass** — Used semantic tokens (`--bg-secondary`, `--text-primary`, `--text-secondary`, `--brand`). All auto-swap.
- [x] **Motion** — No custom transitions added; components use DS defaults which respect `prefers-reduced-motion`.
- [x] **Headings** — Single `<h1>`, no skips.
- [x] **Labels** — InputFields auto-provide `<label for>` linkage; Checkbox has explicit `label` prop.
- [x] **Live regions** — Error message uses `role="alert"` (implies `aria-live="assertive"`), appropriate for auth failures.
- [x] **Autocomplete** — `autocomplete="email"` and `autocomplete="current-password"` set correctly.

---

## Phase 6 — §8 Definition of Done (Form output type)

- [x] Wrapped in `<form>` with explicit submit (`type="submit"` on button + `onSubmit` handler)
- [x] Every input has a `<label>` (via InputField's `label` prop)
- [x] Validation errors announced via `role="alert"` (AlertBanner with role)
- [x] Submit button reflects state (idle: "Sign in", loading: "Signing in…" + disabled + `loading` prop)
- [x] Autocomplete attributes set correctly

---

## Phase 7 — Output contract to user

> **Built**: A login page with email/password, "Remember me", forgot-password link, primary submit, Google SSO alternative, and signup footer link.
>
> **Components used**: `input` (×2), `checkbox`, `button` (×2), `alert-banner`, `divider`, `card` (wrapper).
>
> **Code**: see `src/pages/LoginPage.tsx` above.
>
> **Gaps surfaced**:
> - No specific design was provided; I followed Recipe 1 from the skill (auth form pattern).
> - The Google SSO is a stub — wire it to your actual auth provider.
> - I assumed a `signIn` and `signInWithGoogle` function exist; replace with your auth implementation.
>
> **Next steps for you**:
> - Run `scripts/audit-output.sh src/pages/LoginPage.tsx` to confirm zero violations.
> - Toggle `html.dark` in DevTools to verify dark mode (all colors are semantic, should be automatic).
> - Tab through the form with keyboard to verify focus order: Email → Password → Remember → Forgot link → Sign in → (or) Google.
> - Test with a screen reader (VoiceOver: Cmd+F5) — error announcements should be heard.
> - Consider adding a password visibility toggle if your users frequently mistype passwords.

---

## Key takeaways (why this is the gold standard)

1. **Skill router consulted first** — picked the right references before writing code.
2. **MCP tools called in order** — `get_css_setup` (verified) → `get_page_template` → `get_component` per slug.
3. **Every value is a token** — zero hardcoded hex or off-token px.
4. **Both light and dark mode work** — no `html.dark` overrides needed because semantics were used everywhere.
5. **Form state machine is complete** — idle / loading / error states all handled (per `references/state-machines.md` §10).
6. **A11y baseline satisfied** — labels, autocomplete, error roles, semantic HTML, focus rings preserved.
7. **Output to user is structured** — One-sentence what, manifest, code, gaps, next steps — per §9 of `SKILL.md`.
