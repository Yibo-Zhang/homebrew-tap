class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261101171926"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_f388e2ac0bf1_darwin_arm64.tar.gz"
    sha256 "9e3268ca66707f5bd5efd1b1734782275e1711a35e2b424b644d40672018ea0a"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_f388e2ac0bf1_darwin_amd64.tar.gz"
    sha256 "7bb313569df40e7d6e921bffd407611b91f90722708387c65d9bdac042004145"
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
