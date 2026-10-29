class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261029154138"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_b3ee1cfffcc3_darwin_arm64.tar.gz"
    sha256 "4dc818dce33d9b63c368549afa2b4741dee102c3aaa52a8226ac2ddbd9e435a1"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_b3ee1cfffcc3_darwin_amd64.tar.gz"
    sha256 "f1213f71dfca960f0455a8076ef418adedac90f91e3fc684ed72d8fe29e283c0"
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
