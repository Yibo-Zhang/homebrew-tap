class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261101221921"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_8b3aae18473d_darwin_arm64.tar.gz"
    sha256 "e0341c0d9e80ef6864440f05998830640ea2ae90ea5fa794b388e0e83b48dbf1"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_8b3aae18473d_darwin_amd64.tar.gz"
    sha256 "3ee1558382f31beda6f7f62829ce7e1d76bb315e393be96978b78be91ae10797"
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
