class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20260930154933"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_0feaadc024e1_darwin_arm64.tar.gz"
    sha256 "9c6332cd376d60c8c2303653f6cb5f64bb9d5bc10d0e56bd7d0090fc52ce6dba"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_0feaadc024e1_darwin_amd64.tar.gz"
    sha256 "e75517733e57164fa87a48fc97c6befbc7b0499988af91397941bdd22b4baa17"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
