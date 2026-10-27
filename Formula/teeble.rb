class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261027121614"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_a6a477c80069_darwin_arm64.tar.gz"
    sha256 "0f2e115ea7f80f97cc35f6e68aaf432a1d8e9bfd989760c03ffb350958435e70"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_a6a477c80069_darwin_amd64.tar.gz"
    sha256 "21f9ee73a7c64b97c553e04c6251927ad8cb76f18cca16b0f4605c3687c8df67"
  end

  def install
    bin.install "teeble"
    bin.install_symlink "teeble" => "leno"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
    assert_match "\"ok\":true", shell_output("#{bin}/leno --version")
  end
end
