class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261028215419"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_d3fdee218283_darwin_arm64.tar.gz"
    sha256 "75c2e6c88f00db69327f015c60bfc474634fa7d3d54363eca9a558ba9228083f"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_d3fdee218283_darwin_amd64.tar.gz"
    sha256 "bdc7cddca6304ca18e32cf52385f37cc72dff23b26653433f6e3fe9ddc41d2e9"
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
