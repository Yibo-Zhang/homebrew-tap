class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20260906182935"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_f3c01c33f136_darwin_arm64.tar.gz"
    sha256 "f4640304f9217ac9bae90d70e0e036e3daf0915609f02e3a22c3bbecaed0a5da"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_f3c01c33f136_darwin_amd64.tar.gz"
    sha256 "cd6d4241af3c1864d1683431ad0919da66d624b7cc97938d41f3fb5e98a3c2ac"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
