class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261101034200"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_f570632cb7ec_darwin_arm64.tar.gz"
    sha256 "1371565e26c83c47443a4bc1bc26d17bf4ecca609b013fa937d5c73e7ec2a211"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_f570632cb7ec_darwin_amd64.tar.gz"
    sha256 "a866475bc176c771cb718283baa1bc661e3a250fc25154965d30efacf6435d13"
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
