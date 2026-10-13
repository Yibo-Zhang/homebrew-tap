class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261013203658"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_50d312441e51_darwin_arm64.tar.gz"
    sha256 "d3b8a7f52dd75625aac17be42e6852b4a0a285144a46316a479f9c60a48b390d"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_50d312441e51_darwin_amd64.tar.gz"
    sha256 "95a728ff5c7215b26edf9a4513f1f4d0eeaf5fc61e44f1ef02c717de835378c6"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
