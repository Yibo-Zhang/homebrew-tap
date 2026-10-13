class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261013175042"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_ef39b9888c23_darwin_arm64.tar.gz"
    sha256 "2f4ea5d3d3efcbab99ae31f9500325bd2223cef0fdc53cbf55ab7c382ed43d18"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_ef39b9888c23_darwin_amd64.tar.gz"
    sha256 "440ec3b0026df4164c0dd5c278d39e3528abb75c2557510133e51be232d9938b"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
