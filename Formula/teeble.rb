class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20260915134425"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_027e4661d71b_darwin_arm64.tar.gz"
    sha256 "4c9e067ada59356740f4f85ea9f4896688f7caa0598c581fe4666e811ee7ec6c"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_027e4661d71b_darwin_amd64.tar.gz"
    sha256 "2a7b336fdbdba18444841be9dacb94f47ad6f63f70f99b1abfb48837379ad93c"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
