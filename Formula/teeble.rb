class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20260901182910"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_2bc58f79749f_darwin_arm64.tar.gz"
    sha256 "f87ff281fe90751f08378d9df92f8c5660d10b75326859536a56ac518784c9a5"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_2bc58f79749f_darwin_amd64.tar.gz"
    sha256 "32e95b64e351170ba22eab1c43b061e6c77035a8a3444f18520a41d6c72c3fbd"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
