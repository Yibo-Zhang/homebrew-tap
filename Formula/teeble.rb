class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261102131232"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_bea51dbd8a9c_darwin_arm64.tar.gz"
    sha256 "3b64fec5066b748278202885f7bfaf08b0289daccd44438d18429ec34b169e32"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_bea51dbd8a9c_darwin_amd64.tar.gz"
    sha256 "37ba7358c5e18e2078d0b2ec0db6d6c1f84e127a47b75c64cb5d137b4396b243"
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
