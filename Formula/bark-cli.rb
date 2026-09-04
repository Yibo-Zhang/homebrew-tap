class BarkCli < Formula
  desc "Small JSON command-line client for Bark notifications"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap/tree/main/tools/bark-cli"
  version "0.2.0-20260904163008"
  license "MIT"

  depends_on :macos
  depends_on arch: :arm64

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/bark-cli-latest/bark-cli_0.2.0-20260904163008_78c3e8288aa8_darwin_arm64.tar.gz"
    sha256 "57722d5f9af6b164bfabb0214f4b2d83170486efd4f5805c4db1f9fe2b9c471c"
  end

  def install
    bin.install "bark-cli"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/bark-cli --version")
  end
end
