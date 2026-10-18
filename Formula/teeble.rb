class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261018180526"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_83711bfae678_darwin_arm64.tar.gz"
    sha256 "d20921da9556970829163b2885f91de2438c7913d054eb1a678f9c2563ae4184"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_83711bfae678_darwin_amd64.tar.gz"
    sha256 "f1b869b085b3ebbc2695134e0262696c4f648eae0a80144212969ca085310539"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
