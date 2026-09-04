# AGENTS.md

This repository hosts public CLI distribution, Homebrew formulas, and small
open-source tools maintained under `tools/`. Other tools may have private
source repositories.

## Boundaries

- Never copy private application source, credentials, build logs, or source
  repository metadata into this repository or its Releases.
- New open-source tools may keep their source, tests, and an explicit license
  under `tools/<tool>/`. This does not authorize publishing private source.
- Other public contents are formula definitions, packaging automation,
  documentation, compiled archives, and checksums.
- A public repository is not an open-source grant. Keep proprietary formulas at
  `license :cannot_represent` unless the tool owner explicitly selects another
  license.
- Each private source repository must use a dedicated write deploy key attached
  only to this repository. Never reuse personal access tokens for publishing.

## Publishing

- External source repositories own compilation, tests, and versioned archives.
- External ingestion uses short-lived `publish/<tool>` tags following
  `docs/PUBLISHING.md`.
- Changes to `tools/bark-cli/` on `main` run tests and build archives in this
  repository, then use the same publishing steps as external tools.
- `.github/workflows/publish-cli.yml` validates checksums, updates the rolling
  `<tool>-latest` Release, generates `Formula/<tool>.rb`, and verifies each
  macOS architecture declared in the payload. Bark CLI supports Apple Silicon
  macOS and Linux amd64/arm64; it does not publish Intel macOS builds.
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

For Bark CLI changes, also run `go test ./...` and `go vet ./...` from
`tools/bark-cli`, plus `nix build .#bark-cli` for package changes. Use local
mock HTTP servers and dummy keys in tests; never send real notifications.

Keep Bark's complete agent-facing reference in `tools/bark-cli/help.txt`, which
is embedded in `--help`. Preserve one JSON result, meaningful exit codes and
credential-free diagnostics. Batch success requires every input recipient to
have a matching successful result; test reordered and partial responses.
Encryption changes need an upstream-compatible test vector and checks that
plaintext fields never leak into the outer request.

For an end-to-end change, publish a real payload and require all declared
macOS architecture jobs to pass `brew install` and `brew test`.
