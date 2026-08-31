# Yibo's Homebrew Tap

Public Homebrew formulas and compiled CLI releases for tools whose source code
may live in private repositories.

Publishing a binary here makes that binary publicly downloadable. It does not
publish the corresponding source code or grant an open-source license. Unless a
tool says otherwise, its binaries remain proprietary and all rights are
reserved.

## Install

Install a formula directly:

```sh
brew install Yibo-Zhang/tap/teeble
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

| Formula  | Description                  |
| -------- | ---------------------------- |
| `teeble` | Standalone CLI for Teeble    |

## Publishing model

Private source repositories compile and test their own binaries, then push a
short-lived `publish/<tool>` tag here using a repository-scoped deploy key.
This repository validates the payload, updates the tool's rolling GitHub
Release, generates `Formula/<tool>.rb`, and deletes the ingestion tag.

See [docs/PUBLISHING.md](docs/PUBLISHING.md) for the payload contract.
