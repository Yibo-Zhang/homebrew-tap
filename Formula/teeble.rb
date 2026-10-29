class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261029152701"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_082728f96abb_darwin_arm64.tar.gz"
    sha256 "77bae1f24b59a8781c527c5c9dfdade80049d9bb528305ba40fb8f6f568dedfb"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_082728f96abb_darwin_amd64.tar.gz"
    sha256 "988d0936891f1e62361422cc5e7304e1d0fb6b09153bed484c6bfe51922b6ee6"
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
