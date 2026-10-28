class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261028130524"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_0f1e17008e04_darwin_arm64.tar.gz"
    sha256 "07fce3bd29cfe68ad25f8e53867dca0a3c4e82db299112e319886ceaf03d7a9c"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_0f1e17008e04_darwin_amd64.tar.gz"
    sha256 "afe7c188b884e44f8f2cdfe9f6bc0490c11bf1a6d58428f02bb43d5f3dc144b2"
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
