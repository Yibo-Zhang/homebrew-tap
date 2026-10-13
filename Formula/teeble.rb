class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261013144627"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_71bdb22503b1_darwin_arm64.tar.gz"
    sha256 "2bbeb33f26b291c4de40a5ed5fa74a01fa51c8d6e159782f4f4b58393042c959"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_71bdb22503b1_darwin_amd64.tar.gz"
    sha256 "df75e5142c23f661b34513aef195ac42c09a98e95d24b626adfd5295983ace33"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
