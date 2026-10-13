class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261013150630"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_9eb7ad0b2151_darwin_arm64.tar.gz"
    sha256 "a510d5f5b819b516e19f39b3fa8a3b2727e6930478b7b4aa41345465c7d117b0"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_9eb7ad0b2151_darwin_amd64.tar.gz"
    sha256 "c0d33f794d76f93f9f9174fc9daa397fdeb21711c1cd66d8cb11163310deb307"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
