#!/bin/bash
# One-command setup for a new or wiped Mac.
# Safe to re-run any time — it skips anything already done.
#
#   git clone https://github.com/tchetelat5/mac-setup.git ~/Code/mac-setup
#   ~/Code/mac-setup/setup.sh

set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
CODE_DIR="$HOME/Code"

say() { printf "\n\033[1;34m==> %s\033[0m\n" "$1"; }
ask() { read -r -p "$1 [y/N] " reply; [[ "$reply" =~ ^[Yy]$ ]]; }

# 1. Apple's command line tools (needed for git and Homebrew)
say "Checking Apple command line tools"
if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
  echo "Finish the install window that just opened, then run this script again."
  exit 0
fi

# 2. Homebrew
say "Checking Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null || \
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"

# 3. Tools and apps from the Brewfile
say "Installing tools from Brewfile"
brew bundle --file="$DIR/Brewfile"

if ask "Install Xcode? (Mac mini / MacBook Pro yes — MacBook Neo no)"; then
  brew bundle --file="$DIR/Brewfile.xcode"
fi

# 4. Git identity and sensible defaults
say "Setting up git"
if [ -z "$(git config --global user.name)" ]; then
  read -r -p "Your name for git commits: " gitname
  git config --global user.name "$gitname"
fi
if [ -z "$(git config --global user.email)" ]; then
  echo "Tip: use your GitHub 'noreply' email (GitHub > Settings > Emails) to keep your real email private."
  read -r -p "Email for git commits: " gitemail
  git config --global user.email "$gitemail"
fi
git config --global init.defaultBranch main
git config --global push.autoSetupRemote true
git config --global pull.rebase false

# 5. GitHub sign-in (lets git and Claude Code push from this Mac)
say "Checking GitHub sign-in"
if ! gh auth status >/dev/null 2>&1; then
  gh auth login --hostname github.com --git-protocol https --web
fi
gh auth setup-git

# 6. One folder for all code, with every repo cloned into it
say "Setting up $CODE_DIR"
mkdir -p "$CODE_DIR"
if ask "Clone all your GitHub repos into $CODE_DIR?"; then
  for repo in $(gh repo list --limit 200 --json nameWithOwner -q '.[].nameWithOwner'); do
    name="${repo##*/}"
    if [ ! -d "$CODE_DIR/$name" ]; then
      echo "Cloning $repo"
      gh repo clone "$repo" "$CODE_DIR/$name"
    fi
  done
fi

# 7. Put the helper scripts on the PATH
say "Adding helper commands"
grep -q 'mac-setup/bin' "$HOME/.zshrc" 2>/dev/null || \
  echo "export PATH=\"$DIR/bin:\$PATH\"" >> "$HOME/.zshrc"
chmod +x "$DIR/bin/"*

say "Done. Open a new Terminal window, then try: code-status"
