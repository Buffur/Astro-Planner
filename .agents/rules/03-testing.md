# Testing Rules

- What to run, and when, is decided only by the Verification Policy in
  `CLAUDE.md` ("Post-Roadmap Workflow Governance"): verification follows the
  change class (V1), a broader passing check satisfies a narrower one (V2), and
  passing evidence is reused while its inputs are unchanged (V3).
- Add focused tests for domain calculations, repositories, migrations, and
  critical UI behavior.
- Do not claim a build, test, or device verification passed unless it actually
  ran and passed; when reusing evidence, say which run and why it still holds.
