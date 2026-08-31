# AGENTS.md

This repository is the public binary distribution and Homebrew tap for CLI
tools whose source repositories may be private.

## Boundaries

- Never copy private application source, credentials, build logs, or source
  repository metadata into this repository or its Releases.
- Public contents are limited to formula definitions, packaging automation,
  documentation, compiled archives, and checksums.
- A public repository is not an open-source grant. Keep proprietary formulas at
  `license :cannot_represent` unless the tool owner explicitly selects another
  license.
- Each private source repository must use a dedicated write deploy key attached
  only to this repository. Never reuse personal access tokens for publishing.

## Publishing

- Source repositories own compilation, tests, and versioned archives.
- Ingestion uses short-lived `publish/<tool>` tags following
  `docs/PUBLISHING.md`.
- `.github/workflows/publish-cli.yml` validates checksums, updates the rolling
  `<tool>-latest` Release, generates `Formula/<tool>.rb`, verifies installation
  on Apple Silicon and Intel macOS, and removes the ingestion tag.
- Keep asset names versioned. Upload new assets and commit the new formula
  before removing superseded assets so Brew never points at a missing archive.
- Extend `scripts/generate-formula.mjs` and its tests for shared packaging
  behavior instead of hand-editing generated formulas.

## Validation

Run these checks after changing publishing automation:

```sh
node --test scripts/generate-formula.spec.mjs
nix shell nixpkgs#actionlint --command actionlint .github/workflows/publish-cli.yml
```

For an end-to-end change, publish a real source-repository payload and require
both macOS architecture jobs to pass `brew install` and `brew test`.
