{
  description = "Yibo's small open-source command-line tools";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }: {
    packages =
      nixpkgs.lib.genAttrs
        [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-linux"
        ]
        (system: {
          bark-cli = nixpkgs.legacyPackages.${system}.callPackage ./tools/bark-cli/package.nix { };
          default = self.packages.${system}.bark-cli;
        });
  };
}
