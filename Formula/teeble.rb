class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261026223930"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_7d859256bbfa_darwin_arm64.tar.gz"
    sha256 "0dd36a447f53516180c4a8325491022f99df9098cf8ee243d61ea993290e35d8"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_7d859256bbfa_darwin_amd64.tar.gz"
    sha256 "5f53161616fe81c3d881b0e52c8babc8793502fd5ff623875ac487aaa69a32d7"
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
