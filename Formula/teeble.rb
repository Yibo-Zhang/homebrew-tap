class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20260906194056"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_f6c8abb8339c_darwin_arm64.tar.gz"
    sha256 "4489bb1d6e93476d1a059639405d1e27534f4ecb12063a27fbddc6e1e17d9e9e"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_f6c8abb8339c_darwin_amd64.tar.gz"
    sha256 "5ae4d8f9234b421a9c64d10903b0977efd5abfff1bf6444107192f33eb51a6c7"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
