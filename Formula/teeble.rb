class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261102012944"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_bb9c8256e2eb_darwin_arm64.tar.gz"
    sha256 "7d08c84303818d49292c3d3169c113ffe27a3046eb94b0806e9728d53a2af5d4"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_bb9c8256e2eb_darwin_amd64.tar.gz"
    sha256 "5c21412df80c68215b2a60e3437e84b68e4930c629e60e89f391d517a6590242"
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
