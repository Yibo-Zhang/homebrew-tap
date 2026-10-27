class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261027024127"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_5391b67ad076_darwin_arm64.tar.gz"
    sha256 "8f071539e2a8ac4b1eea7003d611fe42f77b9d39f37b09e6c584f867778834fe"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_5391b67ad076_darwin_amd64.tar.gz"
    sha256 "1a235cb50f1dcc63d645bc581a78d212b906f706ea417a795c2ab333b5e17b69"
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
