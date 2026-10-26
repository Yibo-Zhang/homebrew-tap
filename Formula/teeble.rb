class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261026170647"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_b165893b0ba5_darwin_arm64.tar.gz"
    sha256 "72fc4938fdd9ee1a3597399ed9d56fd0f6e2a12f40db7abdf00ebd2ac8f096ae"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_b165893b0ba5_darwin_amd64.tar.gz"
    sha256 "0272d39ad9b59f2feab0569ad8d7e3419d5796aa463b5b49f4f509eba98d29bd"
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
