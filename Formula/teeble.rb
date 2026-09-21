class Teeble < Formula
  desc "Standalone CLI for Teeble"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20260921235134"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_39e3301965a5_darwin_arm64.tar.gz"
    sha256 "6f33bbcd689cf0c43a113e6f711d3e96c0dcd5195c9a3d667fb3383f1f314684"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_39e3301965a5_darwin_amd64.tar.gz"
    sha256 "43ffc261978f025d91d181c99bd58e4e0c807d34e4d298c21feea86c771273c3"
  end

  def install
    bin.install "teeble"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/teeble --version")
  end
end
