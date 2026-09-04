{ lib, buildGoModule }:
buildGoModule (finalAttrs: {
  pname = "bark-cli";
  version = lib.strings.trim (builtins.readFile ./VERSION);
  src = lib.cleanSource ./.;
  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];
  __darwinAllowLocalNetworking = true;

  meta = {
    description = "Small JSON command-line client for Bark notifications";
    homepage = "https://github.com/Yibo-Zhang/homebrew-tap/tree/main/tools/bark-cli";
    license = lib.licenses.mit;
    mainProgram = "bark-cli";
    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
})
