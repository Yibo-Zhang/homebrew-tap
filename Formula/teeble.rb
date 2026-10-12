class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261012195920"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_8bf060ea1094_darwin_arm64.tar.gz"
    sha256 "46420e57500ec2da420590276dad978e05ffe11fce45f6edc90072af20763d32"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_8bf060ea1094_darwin_amd64.tar.gz"
    sha256 "a40428c17635fe50e43ae43720d2de172fce42bb70c62efecb13c0c5a8e8deee"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
