class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261102021902"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_a7948f537717_darwin_arm64.tar.gz"
    sha256 "71c3acc4a35ce1ae814f483449ac0d38057891ca2e974a1dc9a945b7c19b4610"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_a7948f537717_darwin_amd64.tar.gz"
    sha256 "e7f417d259ba17b8097a79c2af80e6b7458432ea14c2033fda6dd5923ed7a198"
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
