# Yibo's Homebrew Tap

Homebrew formulas, compiled CLI releases, and small open-source tools.

Publishing a binary here makes that binary publicly downloadable. It does not
publish the corresponding source code or grant an open-source license. Unless a
tool says otherwise, its binaries remain proprietary and all rights are
reserved. Tools maintained here under `tools/` declare their own licenses;
[`bark-cli`](tools/bark-cli) is open source under MIT.

## Install

Install a formula directly:

```sh
brew install Yibo-Zhang/tap/teeble
brew install Yibo-Zhang/tap/bark-cli
```

Or add the tap first:

```sh
brew tap Yibo-Zhang/tap
brew install teeble
```

Upgrade installed tools with the normal Homebrew flow:

```sh
brew update
brew upgrade teeble
```

## Available tools

| Formula | Description | Source / license |
| --- | --- | --- |
| `teeble` | Standalone CLI for Teeble | External / proprietary |
| `bark-cli` | JSON command-line client for Bark notifications | [Source and usage](tools/bark-cli) / MIT |

Bark CLI supports Apple Silicon macOS and Linux amd64/arm64. Homebrew installs
the macOS binary; Linux archives are available from the `bark-cli-latest`
Release. Nix users can run or install the same source package:

```sh
nix run github:Yibo-Zhang/homebrew-tap#bark-cli -- --help
```

## Publishing model

External source repositories compile and test their own binaries, then push a
short-lived `publish/<tool>` tag here using a repository-scoped deploy key.
This repository validates the payload, updates the tool's rolling GitHub
Release, generates `Formula/<tool>.rb`, and deletes the ingestion tag.

Changes to Bark CLI source on `main` automatically run Go tests, compile all
three supported targets, publish versioned archives, generate its Homebrew
formula, and verify installation on Apple Silicon. Updating only a generated
formula does not start another build. Nix deployments install the version
selected by the consuming configuration's flake lock; they do not trigger
Homebrew builds.

See [docs/PUBLISHING.md](docs/PUBLISHING.md) for triggers and the payload contract.
