class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261024030429"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_a78b559ff56a_darwin_arm64.tar.gz"
    sha256 "7d51b7a08a30b869cf639deaf633d4431ac2ee64ea6f73e76060b8edc4bf82e8"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_a78b559ff56a_darwin_amd64.tar.gz"
    sha256 "fe7b1102fbe357edf2220604e62c9004831c969f885ecd0469c8e01771a1d63c"
  end

  def install
    bin.install "teeble"
    bin.install_symlink "teeble" => "leno"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
    assert_match "\"ok\":true", shell_output("#{bin}/leno --version")
  end
end
