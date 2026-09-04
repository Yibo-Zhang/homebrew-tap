import { readFile, writeFile } from 'node:fs/promises';

const [manifestPath, outputPath] = process.argv.slice(2);

if (!manifestPath || !outputPath) {
  throw new Error('Usage: node scripts/generate-formula.mjs <manifest.json> <output.rb>');
}

const manifest = JSON.parse(await readFile(manifestPath, 'utf8'));

const requireString = (value, name, pattern) => {
  if (typeof value !== 'string' || !value || (pattern && !pattern.test(value))) {
    throw new Error(`Invalid ${name}`);
  }
  return value;
};

if (manifest.schemaVersion !== 1) throw new Error('Unsupported schemaVersion');

const tool = requireString(manifest.tool, 'tool', /^[a-z][a-z0-9_-]*$/);
const description = requireString(manifest.description, 'description');
const homepage = requireString(manifest.homepage, 'homepage', /^https:\/\//);
const version = requireString(manifest.version, 'version', /^[0-9A-Za-z][0-9A-Za-z.+_-]*$/);
const binary = requireString(manifest.binary, 'binary', /^[A-Za-z0-9][A-Za-z0-9._-]*$/);
const assetPattern = /^[A-Za-z0-9][A-Za-z0-9._-]*\.(?:tar\.gz|zip)$/;
const checksumPattern = /^[a-f0-9]{64}$/;
const architectures = Object.keys(manifest.macos ?? {});
if (architectures.length === 0 || architectures.some((arch) => !['arm64', 'amd64'].includes(arch))) {
  throw new Error('macos must contain arm64 and/or amd64 assets');
}
const license = manifest.license ?? null;
if (license !== null && !['MIT', 'Apache-2.0', 'BSD-2-Clause', 'BSD-3-Clause'].includes(license)) {
  throw new Error('Unsupported license');
}

const formulaClass = tool
  .split(/[-_]/)
  .map((part) => `${part[0].toUpperCase()}${part.slice(1)}`)
  .join('');
const releaseBase = `https://github.com/Yibo-Zhang/homebrew-tap/releases/download/${tool}-latest`;
const rubyString = (value) => JSON.stringify(value).replace(/#(?=[{@$])/g, '\\#');
const architectureBlocks = ['arm64', 'amd64'].filter((arch) => architectures.includes(arch)).map((arch) => {
  const asset = requireString(manifest.macos[arch].asset, `macos.${arch}.asset`, assetPattern);
  const sha = requireString(manifest.macos[arch].sha256, `macos.${arch}.sha256`, checksumPattern);
  return `  on_${arch === 'arm64' ? 'arm' : 'intel'} do
    url ${rubyString(`${releaseBase}/${asset}`)}
    sha256 ${rubyString(sha)}
  end`;
}).join('\n\n');
const architectureDependency = architectures.length === 1
  ? `\n  depends_on arch: :${architectures[0] === 'arm64' ? 'arm64' : 'x86_64'}`
  : '';

const formula = `class ${formulaClass} < Formula
  desc ${rubyString(description)}
  homepage ${rubyString(homepage)}
  version ${rubyString(version)}
  license ${license === null ? ':cannot_represent' : rubyString(license)}

  depends_on :macos${architectureDependency}

${architectureBlocks}

  def install
    bin.install ${rubyString(binary)}
  end

  test do
    assert_match \"\\\"ok\\\":true\", shell_output(\"#{bin}/${binary} --version\")
  end
end
`;

await writeFile(outputPath, formula, 'utf8');
