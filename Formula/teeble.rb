class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261101163301"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_677c6d439fdb_darwin_arm64.tar.gz"
    sha256 "857d680b10abf167cfa9daca71031daa119d461e84ac3780fb41c2744d607639"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_677c6d439fdb_darwin_amd64.tar.gz"
    sha256 "694d76de649612da4f6475cef94649bfcf6bc30c326ebf798dc6567532425adf"
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
