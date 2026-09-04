class BarkCli < Formula
  desc "Small JSON command-line client for Bark notifications"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap/tree/main/tools/bark-cli"
  version "0.1.0-20260904153458"
  license "MIT"

  depends_on :macos
  depends_on arch: :arm64

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/bark-cli-latest/bark-cli_0.1.0-20260904153458_007a46cc3fd6_darwin_arm64.tar.gz"
    sha256 "370b3f00619ae4ec0b26768c38701b0fa6b99809faf7697a7f461b91844df65e"
  end

  def install
    bin.install "bark-cli"
  end

  test do
    assert_match "\"ok\":true", shell_output("#{bin}/bark-cli --version")
  end
end
