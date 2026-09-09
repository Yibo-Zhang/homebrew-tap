cask "halo" do
  version "1.0.0"
  sha256 "06dcd71c0541be0c174e1a1bdb6dcec03c3e69a0c1048145fb831802506c9a81"

  url "https://github.com/Yibo-Zhang/homebrew-tap/releases/download/halo-v#{version}/Halo-#{version}-arm64.zip"
  name "Halo"
  desc "AI, transcription, notes, and scratchpad utility"
  homepage "https://github.com/Yibo-Zhang/homebrew-tap"

  depends_on arch: :arm64
  depends_on macos: ">= :sonoma"

  app "Halo.app"

  caveats <<~EOS
    Halo is currently ad-hoc signed and is not notarized.
    If macOS blocks the first launch, right-click Halo.app in Applications and choose Open.
  EOS
end
