class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261017053720"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_f7fcddee6006_darwin_arm64.tar.gz"
    sha256 "f7ec24207f4a38b49cc965c8dc0db08eaa1b5ac76f3cf6a126daaedd5c5bfd82"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_f7fcddee6006_darwin_amd64.tar.gz"
    sha256 "47a8e995c1c8eae1dae062aa06235955d4be3078f0fd611c65e2ae99619d105f"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
