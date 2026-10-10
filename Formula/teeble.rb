class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261010131434"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_cf52a24ea7e7_darwin_arm64.tar.gz"
    sha256 "6e71c61c5a18c9e3186f451a640956c4998ea9bb92b263bce18de9b11fe60fb8"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_cf52a24ea7e7_darwin_amd64.tar.gz"
    sha256 "cb7d900f368ec05554a617f9c25bda57896cf6756ae724e2690b502b9cec72d6"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
