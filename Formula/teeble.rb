class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261111055154"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_db326c9feba5_darwin_arm64.tar.gz"
    sha256 "1b1526e07d336fc5abbabf0835f3c3e8f0f8c484c1512a481aeaa1c2ffecc408"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_db326c9feba5_darwin_amd64.tar.gz"
    sha256 "1d3d9182d8bc18eca64b02d5de42a96755bf5441a5a8a933a5e9531bd0304ccf"
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
