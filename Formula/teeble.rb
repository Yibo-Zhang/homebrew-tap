class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261111181541"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_79ea848e5cd3_darwin_arm64.tar.gz"
    sha256 "ffbae1ee11fbe49d84d9705fef59336e8a42e09c9cb0eda1190f00c8d397d1cc"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_79ea848e5cd3_darwin_amd64.tar.gz"
    sha256 "e67ddd0456d8fe7512a99f45be7aeaf26b6716a56c4c3c9167293dbaf8a4e7ae"
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
