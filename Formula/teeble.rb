class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261013031938"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_54a7190942e5_darwin_arm64.tar.gz"
    sha256 "37dd640cf91ceee7848ef48384c001a7b3a0919b778e36e5c3678e8f23d9c627"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_54a7190942e5_darwin_amd64.tar.gz"
    sha256 "85e932153882404c8b378fa1d4fab9787acb2343a9626721c6a2f33ac3728cff"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
