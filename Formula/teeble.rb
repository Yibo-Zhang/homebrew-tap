class Teeble < Formula
  desc "Standalone CLI for Leno"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"
  version "0.0.0-20261104151235"
  license :cannot_represent

  depends_on :macos

  on_arm do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_d4f6f48b10e9_darwin_arm64.tar.gz"
    sha256 "22200b62043bf310a450e807e50ebf7439397c3f72f1b8afeedbf6cd620d6361"
  end

  on_intel do
    url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/teeble-latest/teeble_d4f6f48b10e9_darwin_amd64.tar.gz"
    sha256 "4a863d99c6aa9c8c6f9cabe29b6a3943a63d87e09c3debdea9c852f4544e63ea"
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
