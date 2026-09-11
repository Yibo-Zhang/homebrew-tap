class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20260911204257"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_dba4da17c507_darwin_arm64.tar.gz"
    sha256 "d848831e028ca5484d2916d5d2c40274e1bade4dd1fe8235091950d3b9f0c8d1"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_dba4da17c507_darwin_amd64.tar.gz"
    sha256 "0a9174673226c16c1cb46311012cfcf00e393471d86a9da0c506598c99151140"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
