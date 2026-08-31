# Publishing a CLI

Each source repository owns its build and test process. This public repository
owns only distribution metadata and public release assets.

## Ingestion tag

Create and push a temporary tag named `publish/<tool>` whose commit contains:

```text
.publish/
├── manifest.json
└── assets/
    ├── <versioned archives>
    └── <versioned checksums file>
```

Use a dedicated SSH deploy key attached to this repository with write access.
Store its private key only as an Actions secret in the source repository.

The tagged commit should start from this repository's current `main`. The
publish workflow deletes the tag after a successful release. Use a tag instead
of a branch so GitHub does not show short-lived publisher branches on the
repository home page.

## Manifest

The schema is intentionally small and macOS-focused because the generated file
is a Homebrew formula. Other platform archives may still be included in
`assets/` and will be attached to the public Release.

```json
{
  "schemaVersion": 1,
  "tool": "example",
  "description": "Standalone CLI for Example",
  "homepage": "https://example.com",
  "version": "0.0.0-20260831120000",
  "sourceVersion": "main-0123456",
  "binary": "example",
  "releaseTitle": "Example CLI (latest main)",
  "checksums": "example_0123456789ab_checksums.txt",
  "macos": {
    "arm64": {
      "asset": "example_0123456789ab_darwin_arm64.tar.gz",
      "sha256": "<64 lowercase hex characters>"
    },
    "amd64": {
      "asset": "example_0123456789ab_darwin_amd64.tar.gz",
      "sha256": "<64 lowercase hex characters>"
    }
  }
}
```

Every file in `assets/`, except the checksums file itself, must appear in that
checksums file. Asset names must be versioned so the Formula can be updated
before older rolling-release assets are removed.

## Result

For a tool named `example`, publishing updates:

- release tag `example-latest`
- formula `Formula/example.rb`
- install command `brew install Yibo-Zhang/tap/example`

The workflow serializes publishes for each tool, verifies every checksum,
retains the old release assets until the new Formula is committed, removes
superseded assets, and deletes the ingestion tag.
