class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261023210324"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_491f89cb59e5_darwin_arm64.tar.gz"
    sha256 "6aa4759860f0eefd41eb7e32a316c1fec94f9e9ffae6cc27ea203eccbc46415c"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_491f89cb59e5_darwin_amd64.tar.gz"
    sha256 "cfb9f04448c60350707fdccdf43875d8fa627464e1dafe9898958f87aa78e0c2"
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
