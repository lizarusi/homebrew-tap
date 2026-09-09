class Skhd < Formula
  desc "Simple hotkey daemon for macOS (deck: the Fn+` jump-to-deck key)"
  homepage "https://github.com/asmvik/skhd"
  url "https://github.com/asmvik/skhd/archive/v0.3.9.zip"
  sha256 "3832df8b3a7156f2a3d512c6fae8b4cb8bbd2b8a484ab672508788a2c46b72a2"
  head "https://github.com/asmvik/skhd.git", branch: "master"

  # Carried in this tap for one reason: a bottle. Upstream
  # (koekeishiya/formulae) ships none, so every install compiles, which needs
  # current Command Line Tools on the installing Mac. Rebuild the bottle with
  # scripts/bottle skhd (it is per macOS version/arch: a bottle built on an
  # older macOS serves newer ones, not the other way round).
  bottle do
    root_url "https://github.com/lizarusi/homebrew-tap/releases/download/skhd-0.3.9"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "7168c49aad6e509534e3f8340764e6ff1d051c5f3a71c00955ca11c300d68eda"
  end

  depends_on :macos

  def install
    ENV.deparallelize
    system "make", "-j1", "install"
    system "codesign", "-fs", "-", "#{buildpath}/bin/skhd"
    bin.install "#{buildpath}/bin/skhd"
    (pkgshare/"examples").install "#{buildpath}/examples/skhdrc"
  end

  def caveats
    <<~EOS
      skhd needs Accessibility access once (System Settings > Privacy &
      Security > Accessibility: add #{opt_bin}/skhd) — macOS prompts the
      first time it starts. A new build of the binary needs the grant again.

      As a login service:  skhd --start-service   (deck setup does this)
      Logs: /tmp/skhd_<user>.[out|err].log
    EOS
  end

  test do
    assert_match "skhd-v#{version}", shell_output("#{bin}/skhd --version")
  end
end
