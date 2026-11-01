class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261101035556"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_f10c7cbc1c71_darwin_arm64.tar.gz"
    sha256 "dfafc772787bb127a555b541e978543585efef0fc3cada93d2032bd61fce0ec0"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_f10c7cbc1c71_darwin_amd64.tar.gz"
    sha256 "11d8a03d73ce2ab9ec867b5625648c98e550ddc432034aacc19371c6e02bca28"
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
