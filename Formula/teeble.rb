class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261012012504"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_447c0e16b272_darwin_arm64.tar.gz"
    sha256 "673f159954639c4d4898eabece10ce4b46233dec36c8ac4ab101b4d58b117721"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_447c0e16b272_darwin_amd64.tar.gz"
    sha256 "26f2dc24ef574871ee27fe548d846ce312aca33d5d55ed6b912635e02baf9c7e"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
