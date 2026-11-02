class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261102195648"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_895396bc5843_darwin_arm64.tar.gz"
    sha256 "397727effa87d0e8f0d796acccbdb9458e8d543bc02a2006a8590a8aac9bba86"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_895396bc5843_darwin_amd64.tar.gz"
    sha256 "7dbef8d560e89a711adca9dea43ebda53bdaebd114d37fedb4037716ffbec65e"
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
