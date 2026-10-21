class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261020173029"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_cf212302bdcd_darwin_arm64.tar.gz"
    sha256 "3d291e55e1eea25ee038e5be7eb76b97e0a01f7c3bab822dba60cd378e5ecde3"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_cf212302bdcd_darwin_amd64.tar.gz"
    sha256 "dada147295fa11ab06bb7d5dbbafc2db87d7881e2d5423340f74b3be7be0af6c"
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
