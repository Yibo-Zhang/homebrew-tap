class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20260903191746"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_cef637ff75d4_darwin_arm64.tar.gz"
    sha256 "832fcdcc80f2144e927074cb47f4f1168e3f746e0150001e8dbb11f4e9057040"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_cef637ff75d4_darwin_amd64.tar.gz"
    sha256 "9d6a601ce6f49e94b54e92b1ed0276f16fcfa583f259657f830a2ddac4cdfe55"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
