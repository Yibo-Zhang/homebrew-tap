class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261101223555"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_8ca789dce584_darwin_arm64.tar.gz"
    sha256 "b72a4feb751a15949bd32230f95b9e13b2beb2094aa5974a8311ddf7c617f523"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_8ca789dce584_darwin_amd64.tar.gz"
    sha256 "b5b21b7f661e90b78816bd8536dbd7c6547481c1fd89203cb452e2c5b8362a1d"
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
