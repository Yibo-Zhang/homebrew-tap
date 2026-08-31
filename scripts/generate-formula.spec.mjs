import assert from 'node:assert/strict';
import { execFile } from 'node:child_process';
import { mkdtemp, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { promisify } from 'node:util';
import test from 'node:test';

const execFileAsync = promisify(execFile);

test('generates architecture-specific URLs and checksums', async () => {
  const directory = await mkdtemp(join(tmpdir(), 'homebrew-formula-'));
  const manifestPath = join(directory, 'manifest.json');
  const outputPath = join(directory, 'teeble.rb');
  const armSha = 'a'.repeat(64);
  const intelSha = 'b'.repeat(64);

  await writeFile(
    manifestPath,
    JSON.stringify({
      schemaVersion: 1,
      tool: 'teeble',
      description: 'Standalone CLI for Teeble',
      homepage: 'https://github.com/Yibo-Zhang/homebrew-tap',
      version: '0.0.0-20260831120000',
      binary: 'teeble',
      macos: {
        arm64: { asset: 'teeble_0123456789ab_darwin_arm64.tar.gz', sha256: armSha },
        amd64: { asset: 'teeble_0123456789ab_darwin_amd64.tar.gz', sha256: intelSha },
      },
    })
  );

  await execFileAsync(process.execPath, ['scripts/generate-formula.mjs', manifestPath, outputPath]);
  const formula = await readFile(outputPath, 'utf8');

  assert.match(formula, /^class Teeble < Formula/m);
  assert.match(formula, /on_arm do/);
  assert.match(formula, /teeble_0123456789ab_darwin_arm64\.tar\.gz/);
  assert.match(formula, new RegExp(armSha));
  assert.match(formula, /on_intel do/);
  assert.match(formula, /teeble_0123456789ab_darwin_amd64\.tar\.gz/);
  assert.match(formula, new RegExp(intelSha));
  assert.match(formula, /bin\.install "teeble"/);
});
