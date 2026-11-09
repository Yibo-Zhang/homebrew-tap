class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261109190021"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_b8ecf66ca8a0_darwin_arm64.tar.gz"
    sha256 "2bae4a948ecc1e35a41546223ba6dbc9d818d7a1fd18f72a8740a8f38d904e0e"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_b8ecf66ca8a0_darwin_amd64.tar.gz"
    sha256 "9c877005b2040031fdbdf46e854c8816339bf83aecd3fedc4961bb4f62e42161"
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
