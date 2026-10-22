class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261022203114"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_47a469a5f312_darwin_arm64.tar.gz"
    sha256 "56adce5e8ba1ab5b73c1ed289e6e0b39a459e9ef1aa51f35f96f2dcf2b47c7ad"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_47a469a5f312_darwin_amd64.tar.gz"
    sha256 "9b6c237667757555486cb7353616cd903e59066168ebd6bded26019f94e8af8f"
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
