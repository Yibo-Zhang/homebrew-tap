class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261102043225"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_13986df815af_darwin_arm64.tar.gz"
    sha256 "e3ad6ca505c5dcc06781047f9d81698c012ecae5b29d367b00b893fd0e03de58"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_13986df815af_darwin_amd64.tar.gz"
    sha256 "516f830fc1aaa2a5b943d33276b5ef9973a88aacd407ce51c58d99684fd3c594"
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
