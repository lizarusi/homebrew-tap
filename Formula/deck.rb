class Deck < Formula
  desc "Control room for parallel AI coding agents (branch = worktree = tmux session)"
  homepage "https://github.com/lizarusi/deck"
  # private repo: fetched over SSH with your own GitHub keys
  url "git@github.com:lizarusi/deck.git", using: :git, tag: "v0.8.3"
  version "0.8.3"
  head "git@github.com:lizarusi/deck.git", using: :git, branch: "main"

  # prebuilt bottle: pure bash, so one file serves every macOS/arch ("all").
  # A bottle install needs neither the private source repo nor up-to-date
  # Command Line Tools. Rebuild per release: see CLAUDE.md "Releasing".
  bottle do
    root_url "https://github.com/lizarusi/homebrew-tap/releases/download/deck-0.8.2"
    rebuild 5
    sha256 cellar: :any_skip_relocation, all: "0c281ba64f411b7feaf75abc992518fe262288a1e85834043b20f165fe0129bd"
  end

  depends_on "fzf"
  depends_on "jq"
  # skhd (Fn+` -> deck focus) is deliberately NOT a dependency: its bottle is
  # per macOS/arch, and where none fits it compiles, which fails with
  # outdated Command Line Tools — that must not take deck down with it.
  # `deck setup` installs lizarusi/tap/skhd itself and only warns on failure.
  depends_on "lizarusi/tap/terminal-notifier"   # upstream's prebuilt app: core's needs Xcode, no Intel bottle
  depends_on :macos
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
