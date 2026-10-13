class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261013013441"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_c9abd987fba7_darwin_arm64.tar.gz"
    sha256 "85af7eaa41ef99e99ccf1072b94af06030d2d44f5383923a56563637ea14cfd6"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_c9abd987fba7_darwin_amd64.tar.gz"
    sha256 "a5c0cf274fe23e9657b3953219b87778cb28022e3513debb361f55493ec3da79"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
