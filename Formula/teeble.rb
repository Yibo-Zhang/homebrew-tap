class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261029120113"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_afffa7973791_darwin_arm64.tar.gz"
    sha256 "cf9887d54d9c5436b9cce23a58559af7dd9cdaa15f5b6fed3b9ee2fe4b5da18b"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_afffa7973791_darwin_amd64.tar.gz"
    sha256 "6480ff5a3752b3f0ce8eb43d342fa6f04ed27d08c7d6b21dc0c15d80b1d7e3a3"
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
