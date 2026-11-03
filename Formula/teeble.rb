class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261103034051"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_e840e6170c1e_darwin_arm64.tar.gz"
    sha256 "84bdb34fa70f3618b155061ad9a1f777b6e426ef5b197491c6dc104d9296cc77"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_e840e6170c1e_darwin_amd64.tar.gz"
    sha256 "34ef78fc4d788fe75dae60d91d6fa80918f7a1a11c7875f3efa1d1450c78e531"
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
