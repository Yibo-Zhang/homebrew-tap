class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20260917185729"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_f044ab8aa769_darwin_arm64.tar.gz"
    sha256 "242e7f4fb1943b5bdf5b6fd72452bb720e9e42fa790248c13a2925bdf7d7cad0"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_f044ab8aa769_darwin_amd64.tar.gz"
    sha256 "6c18d98d2e6c5ba3a15178c1262d58d6e68534f612d338679209b2c88bcb2a6b"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
