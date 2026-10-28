class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261028022408"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_bcc975c60ee1_darwin_arm64.tar.gz"
    sha256 "ca12441bc19dbf04802d2ba2ea18a58f0ad265cb01a15a08093f03000442744b"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_bcc975c60ee1_darwin_amd64.tar.gz"
    sha256 "c557bb7df6eed80e532d4da3beffe751ec014400fb2b1f42c8e0cdf2b6f58495"
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
