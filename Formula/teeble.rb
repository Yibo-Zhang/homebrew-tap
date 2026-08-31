class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20260831120136"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_ea07b70cef4b_darwin_arm64.tar.gz"
    sha256 "57a9257b3bfe0b95558c5d8300298712b773d6649ae656edc0ef722cd4082cc8"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_ea07b70cef4b_darwin_amd64.tar.gz"
    sha256 "a42296169ae9e86a6fab3d2abb603153cc54adbc3d49272810ab5ae6153d87a6"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
