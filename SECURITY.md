# Security Policy

## Reporting a vulnerability

If you find a security issue in MK-DS (the design system itself, the MCP server, or the install/audit scripts), please **do not open a public issue**.

Email me at `mariana@marianita-klix.dev` with:

- A description of the issue
- Steps to reproduce
- The affected version (commit SHA is fine)
- Any proof-of-concept code, if applicable

I aim to respond within 72 hours. For confirmed vulnerabilities, I'll work with you on disclosure timing — typically a patch within 14 days, then public disclosure after that, but it depends on severity and complexity.

## Scope

In scope:

- The MCP server (`mcp/index.js`) — particularly anything that could allow code execution or data exfiltration via crafted inputs.
- The audit script — false negatives that miss real violations are bugs, not security issues, but a false positive that crashes or hangs the script is worth reporting.
- The HTML pages — XSS or content injection via crafted URLs (though the pages are static, so this is unlikely).

Out of scope:

- The `auth-guard.js` demo password protection. It's a toy. Do not use it for real auth.
- Anti-features by design (e.g., the Tailwind CDN is not under our control).

## Supported versions

I support the latest tagged release and the current `main`. Older versions are best-effort.

— Mariana
