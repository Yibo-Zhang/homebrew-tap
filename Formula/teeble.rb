class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261010030919"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_00ac46ea0fae_darwin_arm64.tar.gz"
    sha256 "f8049c6f241fea0782722701f67e9b8c5c4bb7ba0c0bb6ad1ea4a57a8279fd73"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_00ac46ea0fae_darwin_amd64.tar.gz"
    sha256 "696ea13b10c7a38803c38aec7f1f6ff978ffb05985a02a57d657916e94b468f6"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
