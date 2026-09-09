class Deck < Formula
  desc "Control room for parallel AI coding agents (branch = worktree = tmux session)"
  homepage "https://github.com/lizarusi/deck"
  # private repo: fetched over SSH with your own GitHub keys
  url "git@github.com:lizarusi/deck.git", using: :git, tag: "v0.8.1"
  version "0.8.1"
  head "git@github.com:lizarusi/deck.git", using: :git, branch: "main"

  # prebuilt bottle: pure bash, so one file serves every macOS/arch ("all").
  # A bottle install needs neither the private source repo nor up-to-date
  # Command Line Tools. Rebuild per release: see CLAUDE.md "Releasing".
  bottle do
    root_url "https://github.com/lizarusi/homebrew-tap/releases/download/deck-0.8.0"
    rebuild 4
    sha256 cellar: :any_skip_relocation, all: "0db0ff55b00a0b06a7f2056250ae74132a414e880274a00d59a13107f74dd137"
  end

  depends_on "fzf"
  depends_on "jq"
  # skhd (Fn+` -> deck focus) is deliberately NOT a dependency: its bottle is
  # per macOS/arch, and where none fits it compiles, which fails with
  # outdated Command Line Tools — that must not take deck down with it.
  # `deck setup` installs lizarusi/tap/skhd itself and only warns on failure.
  depends_on :macos
  depends_on "tmux"
  # terminal-notifier (clickable notifications) is optional like skhd: its
  # build needs full Xcode where Homebrew has no bottle (Intel Macs), and
  # deck falls back to osascript banners. `deck setup` installs it when it can.

  def install
    # keep the repo layout intact under libexec: bin/deck resolves its own
    # path (readlink -f) and finds lib/ and libexec/ next to it
    libexec.install Dir["*"]
    bin.install_symlink libexec/"bin/deck"
    bin.install_symlink libexec/"hooks/deck-claude-status"
    zsh_completion.install libexec/"completions/_deck"
  end

  def caveats
    <<~EOS
      Run once per machine to wire Claude Code hooks, tmux, iTerm2,
      Terminal.app and skhd:
        deck setup

      deck setup also installs skhd (lizarusi/tap/skhd) for the Fn+`
      jump-to-deck key. It needs two one-time grants: Accessibility (macOS
      prompts when it first starts — enable it under System Settings >
      Privacy & Security, then re-run deck setup) and Automation for the
      terminal (prompted on the first press). If skhd cannot be built on
      this Mac (no bottle for it, Command Line Tools outdated), setup warns
      and wires everything else; the key is optional.

      If this machine previously used deck from a checkout (install.sh),
      its completion symlink blocks linking — run: brew link --overwrite deck
    EOS
  end

  test do
    assert_match "deck", shell_output("#{bin}/deck help")
  end
end
