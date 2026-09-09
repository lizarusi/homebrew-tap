class TerminalNotifier < Formula
  desc "Send macOS User Notifications from the command-line (deck: clickable notifications)"
  homepage "https://github.com/julienXX/terminal-notifier"
  url "https://github.com/julienXX/terminal-notifier/releases/download/3.1.0/terminal-notifier-3.1.0.zip"
  sha256 "e969d4ae20287da1ba55495ae31dcedd8e9069deb8ce4eed24f6561a5fc3e4d5"
  license "MIT"

  # Why here and not homebrew-core: core compiles it with xcodebuild, which
  # needs full Xcode, and core ships no Intel bottles any more — so on an
  # Intel Mac (or any Mac without Xcode) the core formula cannot install.
  # Upstream publishes a prebuilt universal (arm64 + x86_64, macOS 11+) app
  # with every release; this formula installs that. Its signature is
  # ad-hoc and unnotarized, so it is re-signed ad-hoc here — the same
  # result as a local build, which is what core's formula produces.
  # Bumping: new tag in the url, new sha256 of the zip.
  depends_on :macos

  def install
    app = "terminal-notifier.app"
    system "/usr/bin/codesign", "--force", "--sign", "-", "--deep", app
    prefix.install app
    bin.write_exec_script prefix/app/"Contents/MacOS/terminal-notifier"
  end

  test do
    assert_match version.to_s, pipe_output("#{bin}/terminal-notifier -help")
    app = prefix/"terminal-notifier.app"
    system "/usr/bin/codesign", "--verify", "--strict", app
    assert_match "fr.julienxx.oss.terminal-notifier", shell_output("/usr/bin/codesign -dv #{app} 2>&1")
  end
end
