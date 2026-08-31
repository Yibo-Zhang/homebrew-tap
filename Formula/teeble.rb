class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20260831120544"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_ea07b70cef4b_darwin_arm64.tar.gz"
    sha256 "c4c263fe6e56391bbdc18d49a3d8d4e8d87d11f3d8148db57fb89c9bdb2f3e44"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_ea07b70cef4b_darwin_amd64.tar.gz"
    sha256 "20ad06f3a3ba347c67575b4f1debdda6b4a31923e0ea086e18ea09bb436c4181"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
