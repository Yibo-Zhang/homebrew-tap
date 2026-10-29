class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261029163326"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_f9d74d784bea_darwin_arm64.tar.gz"
    sha256 "c4a2361ddfd937355f12910dab72e96eacc109257e0f4ba48c4ea5398130ee53"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_f9d74d784bea_darwin_amd64.tar.gz"
    sha256 "568fc6efb8589ad77b546bd14a927edea4ac36671d106d8b74b9a7f64a0e3775"
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
