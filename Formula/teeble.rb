class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261112032321"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_5493f21106c4_darwin_arm64.tar.gz"
    sha256 "dc62cc178295c5d02d494f28e5da455a94b795a1dd06382b6e802dce24477b95"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_5493f21106c4_darwin_amd64.tar.gz"
    sha256 "e8b43f1626d85eed63bb2a84bccf40d14d101deae9294ba380ccfe8095407afc"
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
