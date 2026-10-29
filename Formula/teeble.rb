class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261029150513"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_6224561a488a_darwin_arm64.tar.gz"
    sha256 "c39382c0767f3324debc2ebdc5db3a76ad1c0f234e4cf577c1b25b7c07234fbc"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_6224561a488a_darwin_amd64.tar.gz"
    sha256 "3cf96867ad0153331f02f79ade82eb9f3cd3991c03e4554019762d28037e0327"
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
