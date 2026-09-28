class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20260928132554"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_3ce9947ab6b5_darwin_arm64.tar.gz"
    sha256 "3bc4da16baab31d5c5784b22ea5b1568d8bb0c50eb95fec0ca2f54e031873f4d"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_3ce9947ab6b5_darwin_amd64.tar.gz"
    sha256 "55310dd4a845559c14e4e9c0f163e2a3cec20705ddbac9abed701ccf2a099aa6"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
