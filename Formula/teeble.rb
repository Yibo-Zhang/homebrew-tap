class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20260905104051"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_4519932c3ab2_darwin_arm64.tar.gz"
    sha256 "94481ba5fef3cea3df22cfee439efdd38ff6aaf49315adfc85b7e38ee94dbf29"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_4519932c3ab2_darwin_amd64.tar.gz"
    sha256 "497bb2c0b16fdf23663a0e0595804f95d4866c4135728e8cacc9a481538fcd15"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
