class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261027123718"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_06a6421afa39_darwin_arm64.tar.gz"
    sha256 "37df6031d85e500dd171cdafe817a499c2ba01ca129dfc0894b7207d6193c5ee"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_06a6421afa39_darwin_amd64.tar.gz"
    sha256 "8d0754ca7441502e64ab4007b61334c1c2e0036712abcd163f49b87e3dbce732"
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
