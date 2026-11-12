class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261112154816"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_41e1437c0171_darwin_arm64.tar.gz"
    sha256 "b825db4bbe7b901c0c5b2e007f45d4933289dc0d2121bb36a4788cf9838e9121"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_41e1437c0171_darwin_amd64.tar.gz"
    sha256 "64cc59571737046b2172f598609bb5d13646aeb066ef07abc8ced5a845600387"
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
