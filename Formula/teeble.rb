class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261111143714"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_acfd1acba9e5_darwin_arm64.tar.gz"
    sha256 "ba4a8ab5dc53572b822f89294919d6114ea3d417e2099c3498060fb9b5011df1"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_acfd1acba9e5_darwin_amd64.tar.gz"
    sha256 "26d436e4bc779b5c50ed63c9189ab4dd7c6bfd26583fbdf5d9bb224483361ca0"
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
