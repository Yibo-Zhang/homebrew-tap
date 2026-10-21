class BarkCli < Formula
  desc "Small JSON command-line client for Bark notifications"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap/tree/main/tools/bark-cli"
  version "0.2.0-20261021041523"
  license "MIT"

  depends_on :macos
  depends_on arch: :arm64

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/bark-cli-latest/bark-cli_0.2.0-20261021041523_d62274e03cfb_darwin_arm64.tar.gz"
    sha256 "44657ea2cd4eed132c072cc51c1f3e0496a9947d2699627a1df8492063def621"
  end

  def install
    bin.install "bark-cli"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/bark-cli --version")
  end
end
