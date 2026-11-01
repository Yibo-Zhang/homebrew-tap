class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261101133311"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_081df453efb1_darwin_arm64.tar.gz"
    sha256 "51d02d5b153efca5af0d3ac365d9c4782b7a56bd936b9e72b30f77176e5483ce"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_081df453efb1_darwin_amd64.tar.gz"
    sha256 "82db5bcb234ebbb17d76eee0b07d6a0d3c26aa9d74f78b01866cf3c71cad841f"
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
