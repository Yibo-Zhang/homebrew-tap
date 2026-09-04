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
  assert.match(formula, /license :cannot_represent/);
  assert.doesNotMatch(formula, /depends_on arch:/);
});

async function generate(overrides) {
  const directory = await mkdtemp(join(tmpdir(), 'homebrew-bark-formula-'));
  const manifestPath = join(directory, 'manifest.json');
  const outputPath = join(directory, 'bark-cli.rb');
  await writeFile(manifestPath, JSON.stringify({
    schemaVersion: 1,
    tool: 'bark-cli',
    description: 'Bark notifications',
    homepage: 'https://github.com/Yibo-Zhang/homebrew-tap',
    version: '0.1.0-20260904000000',
    binary: 'bark-cli',
    license: 'MIT',
    macos: { arm64: { asset: 'bark-cli_darwin_arm64.tar.gz', sha256: 'a'.repeat(64) } },
    ...overrides,
  }));
  await execFileAsync(process.execPath, ['scripts/generate-formula.mjs', manifestPath, outputPath]);
  return readFile(outputPath, 'utf8');
}

test('supports an MIT-licensed Apple Silicon-only tool', async () => {
  const formula = await generate({});
  assert.match(formula, /^class BarkCli < Formula/m);
  assert.match(formula, /license "MIT"/);
  assert.match(formula, /depends_on arch: :arm64/);
  assert.match(formula, /bark-cli-latest\/bark-cli_darwin_arm64\.tar\.gz/);
  assert.doesNotMatch(formula, /on_intel|amd64/);
});

test('rejects missing or unsupported architectures, bad hashes and unrecognized licenses', async () => {
  for (const overrides of [
    { macos: {} },
    { macos: { x86: { asset: 'a.tar.gz', sha256: 'a'.repeat(64) } } },
    { macos: { arm64: { asset: '../a.tar.gz', sha256: 'a'.repeat(64) } } },
    { macos: { arm64: { asset: 'a.tar.gz', sha256: 'invalid' } } },
    { license: 'custom-ruby-expression' },
  ]) {
    await assert.rejects(generate(overrides));
  }
});

test('treats Ruby interpolation in manifest text as literal text', async () => {
  const formula = await generate({ description: '#{system("unexpected")} #@variable #$global' });
  assert.ok(formula.includes('\\#{system('));
  assert.ok(formula.includes('\\#@variable'));
  assert.ok(formula.includes('\\#$global'));
});
