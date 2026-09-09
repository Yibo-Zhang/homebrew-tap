# Publishing a CLI

External source repositories own their build and test process. This repository
also owns the source and build process for open-source tools under `tools/`.

## Halo cask

Halo's private source repository owns its app build and tests. A version tag
such as `v1.0.0` saves an immutable private release and pushes a binary-only
payload here using the dedicated write deploy key and `publish-cask/halo` tag.
The tagged commit starts from tap main and includes `.publish/manifest.json`
and `.publish/assets/Halo-<version>-arm64.zip`.

`publish-cask.yml` verifies the archive checksum, publishes it on this public
repository under `halo-v<version>`, generates `Casks/halo.rb`, and tests a clean
Homebrew install before deleting the temporary tag. Existing release assets
must match byte-for-byte on a retry. The manifest uses repository
`Yibo-Zhang/homebrew-tap` and `releaseTagPrefix: "halo-v"`; it contains no
private source revision or repository metadata. Never point a public cask at a
private source release.

The Halo repository stores that private key as the
`HOMEBREW_TAP_DEPLOY_KEY` Actions secret. Its public key must be registered as
a write-enabled deploy key on this repository and must not be reused by other
publishers. Changes under `Casks/` trigger a clean Homebrew installation test.

Halo is currently ad-hoc signed rather than Developer ID signed and notarized.
The cask preserves macOS quarantine and tells users how to approve the first
launch; publishing automation must not remove or bypass Gatekeeper metadata.

## Bark CLI

Push changes to `tools/bark-cli/`, `scripts/build-bark-cli.sh`, the formula
generator, or the publish workflow to `main`. The publish workflow builds and
tests Bark CLI automatically. It can also be run manually on `main` using
`workflow_dispatch`. No deploy key or separate source repository is needed for
this path.

The build script generates the same payload contract described below. It emits
macOS arm64 and Linux amd64/arm64 archives, with the tool's MIT license and
README included. Versions combine `tools/bark-cli/VERSION` with the source
commit's UTC timestamp; archive names also include the source revision. Raising
the base version is optional for routine fixes and appropriate for interface
changes.

To build and inspect a payload locally (Go, Node, GNU tar, gzip and sha256sum):

```sh
bash scripts/build-bark-cli.sh /tmp/bark-cli-payload
node scripts/generate-formula.mjs /tmp/bark-cli-payload/manifest.json /tmp/bark-cli.rb
```

Use an empty output directory. The workflow keeps Bark's older versioned
assets available so clients with older tap metadata can still install them.
Re-running a published source revision reuses identical assets. If an asset's
bytes differ (for example after a Go compiler update), publication fails before
overwriting it; publish a new source revision to produce new asset names.
Publishing runs for the same tool are serialized without canceling an active
publication. Homebrew installation is verified on the architectures present
in `macos`; Bark CLI declares only Apple Silicon.

The generated formula update does not retrigger the source build. A consuming
Nix configuration updates this repository's flake input and deploys separately.
That deployment does not publish a Homebrew release.

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
is a Homebrew formula. `macos` must include `arm64`, `amd64`, or both. Other
platform archives may still be included in `assets/` and will be attached to
the public Release. An optional `license` may be `MIT`, `Apache-2.0`,
`BSD-2-Clause`, or `BSD-3-Clause`; omit it for proprietary binaries. Do not
assign an open-source license to an existing proprietary tool without its
owner's explicit authorization.

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
superseded external-tool assets, and deletes external ingestion tags.
