#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(git rev-parse --show-toplevel)"
source_dir="$repo_dir/tools/bark-cli"
output_dir="${1:?Usage: scripts/build-bark-cli.sh <empty-output-directory>}"
mkdir -p "$output_dir"
output_dir="$(cd "$output_dir" && pwd)"
if [[ -e "$output_dir/assets" || -e "$output_dir/manifest.json" ]]; then
  echo 'The output directory already contains a publish payload' >&2
  exit 1
fi

revision="$(git rev-parse --short=12 HEAD)"
timestamp="$(TZ=UTC git show -s --date=format-local:%Y%m%d%H%M%S --format=%cd HEAD)"
epoch="$(git show -s --format=%ct HEAD)"
version="$(tr -d '\n' < "$source_dir/VERSION")-$timestamp"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+-[0-9]{14}$ ]]

build_dir="$(mktemp -d)"
trap 'rm -rf "$build_dir"' EXIT
mkdir -p "$output_dir/assets"

(
  cd "$source_dir"
  go test ./...
  go vet ./...
)

for target in darwin/arm64 linux/amd64 linux/arm64; do
  target_os="${target%/*}"
  target_arch="${target#*/}"
  archive="bark-cli_${version}_${revision}_${target_os}_${target_arch}.tar.gz"
  mkdir -p "$build_dir/$target"
  (
    cd "$source_dir"
    CGO_ENABLED=0 GOOS="$target_os" GOARCH="$target_arch" go build \
      -trimpath -buildvcs=false -ldflags "-s -w -X main.version=$version" \
      -o "$build_dir/$target/bark-cli" .
  )
  cp "$source_dir/LICENSE" "$source_dir/README.md" "$build_dir/$target/"
  tar --sort=name --mtime="@$epoch" --owner=0 --group=0 --numeric-owner \
    -C "$build_dir/$target" -cf - bark-cli LICENSE README.md |
    gzip -n > "$output_dir/assets/$archive"
done

(
  cd "$output_dir/assets"
  sha256sum ./*.tar.gz | sed 's| \./| |' > "bark-cli_${version}_${revision}_checksums.txt"
)

node --input-type=module - "$output_dir" "$version" "$revision" <<'JS'
import { readFile, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
const [directory, version, revision] = process.argv.slice(2);
const checksums = `bark-cli_${version}_${revision}_checksums.txt`;
const checksumText = await readFile(join(directory, 'assets', checksums), 'utf8');
const hashes = new Map(checksumText.trim().split('\n').map((line) => {
  const [sha256, asset] = line.trim().split(/\s+/);
  return [asset, sha256];
}));
const asset = `bark-cli_${version}_${revision}_darwin_arm64.tar.gz`;
await writeFile(join(directory, 'manifest.json'), `${JSON.stringify({
  schemaVersion: 1,
  tool: 'bark-cli',
  description: 'Small JSON command-line client for Bark notifications',
  homepage: 'https://github.com/Yibo-Zhang/homebrew-tap/tree/main/tools/bark-cli',
  license: 'MIT',
  version,
  sourceVersion: `main-${revision}`,
  binary: 'bark-cli',
  releaseTitle: 'Bark CLI (latest main)',
  checksums,
  macos: { arm64: { asset, sha256: hashes.get(asset) } },
}, null, 2)}\n`);
JS
