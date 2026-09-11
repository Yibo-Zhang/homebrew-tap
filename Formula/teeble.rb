class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20260911151954"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_95681ed6f235_darwin_arm64.tar.gz"
    sha256 "b3a66b2aedbd7fe7be5bfc22a1f600fe436ccd137e3606f220cccd63f1b1f5e7"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_95681ed6f235_darwin_amd64.tar.gz"
    sha256 "e8fe663ff7d196e2be76995b451c07aa9d524934a684ed06c86d8e5f22631c27"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
