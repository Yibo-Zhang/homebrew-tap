class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261028150719"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_f592c33a2c60_darwin_arm64.tar.gz"
    sha256 "1fce9c3953f4bc5bf6a257c8a75b1c3687b5813cdfc5ecd35a58af1fa015452b"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_f592c33a2c60_darwin_amd64.tar.gz"
    sha256 "3bb5def224fc32b65469634a524a6e34c3b392f11c87e7df41aae73fe66278b7"
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
