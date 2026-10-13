class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261013041041"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_0b4190c7ee4d_darwin_arm64.tar.gz"
    sha256 "871ce7fd50cbed5ac4c25da03f0d9534b2e2cd6646291fc754d5cf5da45ac049"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_0b4190c7ee4d_darwin_amd64.tar.gz"
    sha256 "dd8785723ebd5adb66025aff47b8384ec6056a647e1dfdfb726f1504d3ab127b"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
