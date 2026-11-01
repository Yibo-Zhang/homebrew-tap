class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261101135006"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_726b355b0d7e_darwin_arm64.tar.gz"
    sha256 "1b3962adea1db5c8613b3f67cc8fe36c3dd60280f7c1cc5dd338aabbaa23b3ec"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_726b355b0d7e_darwin_amd64.tar.gz"
    sha256 "e6ba5b87be80c85f611f1ca58d92dfd81d724c8c38f3ecd5cfcd122550a4995a"
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
