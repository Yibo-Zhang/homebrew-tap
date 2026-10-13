class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261013193930"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_d0c567d3f37d_darwin_arm64.tar.gz"
    sha256 "e7aa0a1b2e84d5ceee7cc87a362d89831a94a657df90a79012b46d9034115e95"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_d0c567d3f37d_darwin_amd64.tar.gz"
    sha256 "a055c9bba9c900ee52a5e99523619ea846f1c3ff93912522489750bdbd19541b"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
