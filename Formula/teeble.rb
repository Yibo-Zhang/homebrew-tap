class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261023144504"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_69f23e33d039_darwin_arm64.tar.gz"
    sha256 "7046c93c249eaddf15c056bb131bbd07f8903e7dc5b9df0a2fd3f18ce4417006"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_69f23e33d039_darwin_amd64.tar.gz"
    sha256 "19c714b9ec433358db988f09990d17745a78df4580b9163a6a5a9fa83e6ba411"
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
