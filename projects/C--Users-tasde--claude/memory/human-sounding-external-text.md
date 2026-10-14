---
name: human-sounding-external-text
description: "User wants text going to external/public places (GitHub issues, PRs, etc.) to read as human-written, not AI-generated"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: f755f859-32b8-442c-b5c2-2c0a46a3062e
  modified: 2026-08-16T18:49:24.515Z
---

When drafting text meant to be posted externally under the user's name (GitHub issue/PR bodies, public comments), rewrite it to sound like the user wrote it themselves: no em-dashes, no overly polished/structured "AI" phrasing, more casual/first-person tone, contractions okay, less rigid section transitions. Keep all technical content and accuracy the same, only change the surface style.

**Why:** user explicitly asked to strip "yapay zeka izleri" (AI tells) like em-dashes before a GitHub issue went out under their name, worried about it reading as obviously AI-written.
**How to apply:** proactively apply this style (no em-dashes, casual tone) to any user-attributed external-facing text (issues, PR descriptions, public comments, emails signed by the user) without waiting to be asked again, in this and other projects. Internal-only docs/commit messages are not covered unless the user says so.
