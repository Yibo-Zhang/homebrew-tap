class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261026180152"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_3a7ec6418e8f_darwin_arm64.tar.gz"
    sha256 "e0a35359477276f44f44213f512ec5d0483d20adb253ec939c42d3cfaa448ad6"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_3a7ec6418e8f_darwin_amd64.tar.gz"
    sha256 "90a1cc7cbb372c8dd023c68ae89dfe6d893b219b7484871b9ab41714ca309d42"
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
