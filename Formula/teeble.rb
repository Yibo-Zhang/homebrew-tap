class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261013023020"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_f1f2e24dd48e_darwin_arm64.tar.gz"
    sha256 "49196157400f6d6b43cab67bad869938792b52750f51f2ed8d4b28aee403102a"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_f1f2e24dd48e_darwin_amd64.tar.gz"
    sha256 "46d06a11b2864144811b0f059296520fc509c43e97d5a6f888b332fabcf26b26"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
