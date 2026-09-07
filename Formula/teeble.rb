class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20260907111701"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_f75706474863_darwin_arm64.tar.gz"
    sha256 "08d079e1d4d33703910b6dbb143245622654754e7f50ef5979e641d79987b1e6"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_f75706474863_darwin_amd64.tar.gz"
    sha256 "3f9b29dc9a89ff5441160a4cd5c9926ff9227ebb55d075aebb7f1b6b9afbcacf"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
