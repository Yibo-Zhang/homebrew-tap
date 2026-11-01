class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261101215128"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_2344b8cf903c_darwin_arm64.tar.gz"
    sha256 "e9d2280255f08dc89053e65aa2958c0be67ab444531eed0b115123d219899a57"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_2344b8cf903c_darwin_amd64.tar.gz"
    sha256 "ce745698463d48b572628ed7728c5e01f48b8f30aff92f447fdce249c0604aa6"
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
