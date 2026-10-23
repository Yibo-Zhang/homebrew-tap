class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261023215702"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_b4b0347a22e7_darwin_arm64.tar.gz"
    sha256 "04bad86413b15782af252953d0feb678b12aa186a6fafe6662fd9c86da631e44"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_b4b0347a22e7_darwin_amd64.tar.gz"
    sha256 "5b6524044532ae23f86a46da8851afe272c2604ffbf70e780f61acd3b79479d7"
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
