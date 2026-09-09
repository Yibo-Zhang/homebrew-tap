import { readFile, writeFile } from 'node:fs/promises';

const [manifestPath, outputPath] = process.argv.slice(2);

if (!manifestPath || !outputPath) {
  throw new Error('Usage: node scripts/generate-cask.mjs <manifest.json> <output.rb>');
}

const manifest = JSON.parse(await readFile(manifestPath, 'utf8'));

const requireString = (value, name, pattern) => {
  if (typeof value !== 'string' || !value || (pattern && !pattern.test(value))) {
    throw new Error(`Invalid ${name}`);
  }
  return value;
};

if (manifest.schemaVersion !== 1) throw new Error('Unsupported schemaVersion');

const token = requireString(manifest.token, 'token', /^[a-z][a-z0-9-]*$/);
const version = requireString(manifest.version, 'version', /^\d+(?:\.\d+){2}(?:[-+][0-9A-Za-z.-]+)?$/);
const sha256 = requireString(manifest.sha256, 'sha256', /^[a-f0-9]{64}$/);
const repository = requireString(
  manifest.repository,
  'repository',
  /^[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+$/
);
const name = requireString(manifest.name, 'name');
const description = requireString(manifest.description, 'description');
const app = requireString(manifest.app, 'app', /^[A-Za-z0-9][A-Za-z0-9 ._-]*\.app$/);
const assetPrefix = requireString(
  manifest.assetPrefix,
  'assetPrefix',
  /^[A-Za-z0-9][A-Za-z0-9._-]*$/
);
const minimumMacOS = requireString(
  manifest.minimumMacOS,
  'minimumMacOS',
  /^(?:sonoma|sequoia|tahoe)$/
);
const homepage = `https://github.com/${repository}`;
const releaseTagPrefix = requireString(
  manifest.releaseTagPrefix ?? 'v',
  'releaseTagPrefix',
  /^[A-Za-z0-9][A-Za-z0-9._-]*$/
);

const rubyString = (value) => JSON.stringify(value).replace(/#(?=[{@$])/g, '\\#');
const releaseURL = `https://github.com/${repository}/releases/download/${releaseTagPrefix}\#{version}/${assetPrefix}-\#{version}-arm64.zip`;

const cask = `cask ${rubyString(token)} do
  version ${rubyString(version)}
  sha256 ${rubyString(sha256)}

  url "${releaseURL}"
  name ${rubyString(name)}
  desc ${rubyString(description)}
  homepage ${rubyString(homepage)}

  depends_on arch: :arm64
  depends_on macos: ">= :${minimumMacOS}"

  app ${rubyString(app)}

  caveats <<~EOS
    ${name} is currently ad-hoc signed and is not notarized.
    If macOS blocks the first launch, right-click ${app} in Applications and choose Open.
  EOS
end
`;

await writeFile(outputPath, cask, 'utf8');
