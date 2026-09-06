class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20260906185012"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_9b79cb1896af_darwin_arm64.tar.gz"
    sha256 "bfaefa41d978816cce5a14bc9c9bb0be0ac27b387aee1d4e0b2e5113e87be3fd"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_9b79cb1896af_darwin_amd64.tar.gz"
    sha256 "329e8ece9d96e91e5ac99284445fbd71897ddd1b0ee1293088d40861258217db"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
