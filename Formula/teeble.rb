class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20260906205250"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_03feb5dd3065_darwin_arm64.tar.gz"
    sha256 "85d07bc8b02d683969f07d518a9c2988c008eaa16e1ca94d15566e4cf144bf85"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_03feb5dd3065_darwin_amd64.tar.gz"
    sha256 "770014195449ef4ca250a05e1dd04ab3ba67d5f6790cf2162eb948a4f29a782c"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
