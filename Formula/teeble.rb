class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261013163712"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_e0bf64e26fe4_darwin_arm64.tar.gz"
    sha256 "fa99cdd4c1d54908b71e5bd5ad1d2105acc524f34d7fa696f64cc270a5dbac5c"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_e0bf64e26fe4_darwin_amd64.tar.gz"
    sha256 "2d87cb7f7f5fda8b94b204b22c0daa4ce9559edbee8fbbe760436fd249733074"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
