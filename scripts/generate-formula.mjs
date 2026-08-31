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
const armAsset = requireString(manifest.macos?.arm64?.asset, 'macos.arm64.asset', assetPattern);
const armSha = requireString(
  manifest.macos?.arm64?.sha256,
  'macos.arm64.sha256',
  checksumPattern
);
const intelAsset = requireString(
  manifest.macos?.amd64?.asset,
  'macos.amd64.asset',
  assetPattern
);
const intelSha = requireString(
  manifest.macos?.amd64?.sha256,
  'macos.amd64.sha256',
  checksumPattern
);

const formulaClass = tool
  .split(/[-_]/)
  .map((part) => `${part[0].toUpperCase()}${part.slice(1)}`)
  .join('');
const releaseBase = `https://github.com/Yibo-Zhang/homebrew-tap/releases/download/${tool}-latest`;
const rubyString = (value) => JSON.stringify(value);

const formula = `class ${formulaClass} < Formula
  desc ${rubyString(description)}
  homepage ${rubyString(homepage)}
  version ${rubyString(version)}
  license :cannot_represent

  depends_on :macos

  on_arm do
    url ${rubyString(`${releaseBase}/${armAsset}`)}
    sha256 ${rubyString(armSha)}
  end

  on_intel do
    url ${rubyString(`${releaseBase}/${intelAsset}`)}
    sha256 ${rubyString(intelSha)}
  end

  def install
    bin.install ${rubyString(binary)}
  end

  test do
    assert_match \"\\\"ok\\\":true\", shell_output(\"#{bin}/${binary} --version\")
  end
end
`;

await writeFile(outputPath, formula, 'utf8');
