import assert from 'node:assert/strict';
import { execFile } from 'node:child_process';
import { mkdtemp, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { promisify } from 'node:util';
import test from 'node:test';

const execFileAsync = promisify(execFile);

async function generate(overrides = {}) {
  const directory = await mkdtemp(join(tmpdir(), 'homebrew-cask-'));
  const manifestPath = join(directory, 'manifest.json');
  const outputPath = join(directory, 'halo.rb');
  await writeFile(manifestPath, JSON.stringify({
    schemaVersion: 1,
    token: 'halo',
    version: '1.0.0',
    sha256: 'a'.repeat(64),
    repository: 'Yibo-Zhang/halo',
    name: 'Halo',
    description: 'AI, transcription, notes, and scratchpad utility',
    app: 'Halo.app',
    assetPrefix: 'Halo',
    minimumMacOS: 'sonoma',
    ...overrides,
  }));
  await execFileAsync(process.execPath, ['scripts/generate-cask.mjs', manifestPath, outputPath]);
  return readFile(outputPath, 'utf8');
}

test('generates an arm64 Sonoma cask for a versioned GitHub release', async () => {
  const cask = await generate();

  assert.match(cask, /^cask "halo" do/m);
  assert.match(cask, /version "1\.0\.0"/);
  assert.match(cask, /sha256 "a{64}"/);
  assert.match(cask, /releases\/download\/v#\{version\}\/Halo-#\{version\}-arm64\.zip/);
  assert.match(cask, /depends_on arch: :arm64/);
  assert.match(cask, /depends_on macos: ">= :sonoma"/);
  assert.match(cask, /app "Halo\.app"/);
  assert.match(cask, /ad-hoc signed and is not notarized/);
});

test('rejects invalid versions, hashes, repositories, app names and macOS releases', async () => {
  for (const overrides of [
    { version: '../latest' },
    { sha256: 'invalid' },
    { repository: 'https://github.com/Yibo-Zhang/halo' },
    { app: '../Halo.app' },
    { minimumMacOS: 'ventura' },
  ]) {
    await assert.rejects(generate(overrides));
  }
});

test('escapes Ruby interpolation in human-readable manifest fields', async () => {
  const cask = await generate({ description: '#{system("unexpected")} #@value #$global' });

  assert.ok(cask.includes('\\#{system('));
  assert.ok(cask.includes('\\#@value'));
  assert.ok(cask.includes('\\#$global'));
});
