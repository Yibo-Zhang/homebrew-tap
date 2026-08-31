class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20260831123359"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_56ba5971e076_darwin_arm64.tar.gz"
    sha256 "28ce971dd31a31486dd122280dbc6ef751d34c64f94800319f7e9db345464108"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_56ba5971e076_darwin_amd64.tar.gz"
    sha256 "0e68211ada23aa68795dfb82b9fd3a0e382b1568ca4435bcde1f0a123d7a425f"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
