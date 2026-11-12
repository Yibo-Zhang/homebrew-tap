class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261112144453"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_85e4881586e6_darwin_arm64.tar.gz"
    sha256 "7a34666d3ea7240279caf7c9ba67b90b86b847060b9db201363c937c14f3f30e"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_85e4881586e6_darwin_amd64.tar.gz"
    sha256 "725ce4a635133778ca2ab6bde99d31bbe64cbe4c5fd42398e37c920eea04e1e2"
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
