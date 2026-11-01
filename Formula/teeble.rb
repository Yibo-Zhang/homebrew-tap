class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261101015054"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_c5612c69f438_darwin_arm64.tar.gz"
    sha256 "a35de63a73e71129a35cab7cb894f98399a672a86e6bf8fa757dc3a791fd7539"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_c5612c69f438_darwin_amd64.tar.gz"
    sha256 "ac6fe028f8fd07d0b45126c75708ebd85a408f5841b7ce53fce707b2f59e395a"
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
