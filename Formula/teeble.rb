class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20260917203607"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_7ec32274e4d0_darwin_arm64.tar.gz"
    sha256 "c37f18fda82e1346b9aec9bf380bbcf2d7a43004e7b5ee99b7af67b10e9b5968"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_7ec32274e4d0_darwin_amd64.tar.gz"
    sha256 "e7bf44e35372677732936f15ed6d4d853ca63cf73de3f8edee318dfc2eed92f2"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
