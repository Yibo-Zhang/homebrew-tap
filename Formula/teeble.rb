class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261023142607"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_5e5688b81bbc_darwin_arm64.tar.gz"
    sha256 "26852c2cfb56d8ca5d19369a69ff2f598a6f910ad4ed980e9add90d6fe5dac47"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_5e5688b81bbc_darwin_amd64.tar.gz"
    sha256 "a76e2e203de8212508405adea0d0815782ad49e5331323ff934bb3aff68f47c2"
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
