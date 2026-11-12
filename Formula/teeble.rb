class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261112053657"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_088e6d2ba650_darwin_arm64.tar.gz"
    sha256 "d7e4697a221c3f9c1ba043e9b044cd6e756bb1820d750e62c1e8c276ebbca459"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_088e6d2ba650_darwin_amd64.tar.gz"
    sha256 "fba2ed079da0d5d8b902973c732ac8a4d1f454e8fd8087effd70923fd703aa93"
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
