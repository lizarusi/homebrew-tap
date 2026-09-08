class Deck < Formula
  desc "Control room for parallel AI coding agents (branch = worktree = tmux session)"
  homepage "https://github.com/lizarusi/deck"
  # private repo: fetched over SSH with your own GitHub keys
  url "git@github.com:lizarusi/deck.git", using: :git, tag: "v0.7.2"
  version "0.7.2"
  head "git@github.com:lizarusi/deck.git", using: :git, branch: "main"

  # prebuilt bottle: pure bash, so one file serves every macOS/arch ("all").
  # A bottle install needs neither the private source repo nor up-to-date
  # Command Line Tools. Rebuild per release: see CLAUDE.md "Releasing".
  bottle do
    root_url "https://github.com/lizarusi/homebrew-tap/releases/download/deck-0.7.2"
    rebuild 3
    sha256 cellar: :any_skip_relocation, all: "4f5cacc97a06a61333f8ee3b3d8fe1bf518de2c900405de44f0edc80d7d5349a"
  end

  depends_on "fzf"
  depends_on "jq"
  depends_on :macos
  depends_on "terminal-notifier"
  depends_on "tmux"

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
      Run once per machine to wire Claude Code hooks, tmux, iTerm and skhd
      (deck setup taps koekeishiya/formulae and installs skhd itself —
      a cross-tap dependency here would make newer Homebrew refuse the install):
        deck setup

      skhd (the Fn+` hotkey, iTerm2 only) needs two one-time grants:
      Accessibility (macOS prompts when it first starts — enable it under
      System Settings > Privacy & Security, then re-run deck setup) and
      Automation for iTerm2 (prompted on the first press).

      If this machine previously used deck from a checkout (install.sh),
      its completion symlink blocks linking — run: brew link --overwrite deck
    EOS
  end

  test do
    assert_match "deck", shell_output("#{bin}/deck help")
  end
end
