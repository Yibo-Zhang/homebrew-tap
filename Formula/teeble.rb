class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261027125607"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_114fc77629a8_darwin_arm64.tar.gz"
    sha256 "d294e81163af85c8cbfc04508707febe89f4a5f15e3aaaf5e358550d0de5d5a0"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_114fc77629a8_darwin_amd64.tar.gz"
    sha256 "a088bad5989bc76bdf8f9a503400068dd36cc62452a738aaebc0707f158b5079"
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
