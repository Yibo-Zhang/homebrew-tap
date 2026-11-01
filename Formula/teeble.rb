class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261101232630"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_1f7398f83a47_darwin_arm64.tar.gz"
    sha256 "92d450a40a2dcd6d5c8661048d1c90b07d2c910f7a12a92e0d86c7b98db6090b"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_1f7398f83a47_darwin_amd64.tar.gz"
    sha256 "6ec51f24e42a8f7f457ffa77a5df05eb4cdcd7562a9a8e32c9b2623d88b2716a"
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
