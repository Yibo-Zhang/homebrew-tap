class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261013153853"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_120486a80b08_darwin_arm64.tar.gz"
    sha256 "8cd6a56007620e2c0c96e0b5c7ecbcdffa77933a134df8bb85137b82e81cb841"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_120486a80b08_darwin_amd64.tar.gz"
    sha256 "8496b7e6ca0b9b4555cc7b38d4fb96be420e8511e033ff091a21fd8d14913b1f"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
