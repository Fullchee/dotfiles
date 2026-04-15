#!/bin/zsh

set -euo pipefail

# extend sudo timeout for this script only (120 minutes)
sudo sh -c 'echo "Defaults timestamp_timeout=120" > /etc/sudoers.d/timeout'

IS_MAC=false
IS_LINUX=false

case "$(uname -s)" in
  Darwin)
    IS_MAC=true
    ;;
  Linux)
    IS_LINUX=true
    ;;
esac

ensure_pkg() {
  if $IS_MAC; then
    brew install "$@"       # shortcuts, no "-y"
  elif $IS_LINUX; then
    sudo apt-get install -y "$@"  # apt always -y
  else
    echo "[ensure_pkg] only works for Linux and Mac" >&2
    exit 1
  fi
}

ensure_command() {
  local cmd="$1"
  if ! command -v "$cmd" &> /dev/null; then
    return 1
  fi
  return 0
}

ensure_cargo_install() {
  # Usage: ensure_cargo_install <bin> [crate] [--git <git_url> [cargo args...]]
  # If only <bin> is provided, assume the crate name matches the binary name.
  local bin="$1"; shift
  local crate="$bin"
  if [ "$#" -gt 0 ] && [ "$1" != "--git" ]; then
    crate="$1"; shift
  fi

  local git_url=""
  if [ "$#" -gt 0 ] && [ "$1" = "--git" ]; then
    shift
    git_url="$1"; shift
  fi

  if ! ensure_command "$bin"; then
    if [ -n "$git_url" ]; then
      cargo install --git "$git_url" "$crate" "$@"
    else
      cargo install --locked "$crate" "$@"
    fi
  fi
}

ensure_uv_tool() {
  local bin="$1"; shift
  if ! ensure_command "$bin"; then
    if [ "$#" -eq 0 ]; then
      uv tool install "$bin"
    else
      uv tool install "$@"
    fi
  fi
}

ensure_pnpm_global() {
  local pkg="$1" ; shift
  if ! pnpm list -g 2>/dev/null | grep -q "$pkg"; then
    pnpm add -g "$pkg"
  fi
}

ensure_brew() {
  local pkg="$1"
  if ! brew list --cask | grep -q "^$pkg$"; then
    brew install --cask "$pkg"
  fi
}

ensure_mas_app() {
  local app_id="$1"
  if ! mas list | awk '{print $1}' | grep -q "^${app_id}$"; then
    mas install "$app_id"
  fi
}

if $IS_LINUX; then
  sudo apt-get install -y build-essential  # for cargo install, bitwarden CLI to work on linux, provides cc for compiling dependencies
fi

# Rust toolchain
if ! ensure_command rustup; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
else
  rustup self update
  rustup update
fi
. "$HOME/.cargo/env"  # add cargo to current session to install software below

export CARGO_NET_GIT_FETCH_WITH_CLI=true

# uv needed here to install other global python packages below
if ! command -v uv >/dev/null; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
  uv python install --default
fi

# bootstrap helpers ----------------------------------------------------------
if $IS_MAC; then
  # Extend sudo timeout to 120 minutes
  if ! command -v brew &> /dev/null; then
    echo "Installing homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Apple silicon
    if [ -d /opt/homebrew/bin ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    # intel
    elif [ -d /usr/local/bin ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi

  brew update
  export HOMEBREW_NO_AUTO_UPDATE=1  # when you run `brew install`, don't run `brew update` first, we already did it here
fi

if $IS_LINUX; then
  sudo apt-get update -y
  sudo apt-get upgrade -y
fi

# node environment ----------------------------------------------------
mise use -g node@lts
npm i -g corepack@latest
npm i -g npm
corepack enable pnpm
corepack use pnpm@latest

# platform-independent package installs -------------------------------------

# adb
if $IS_LINUX; then
  sudo apt update && sudo apt install android-tools-adb android-tools-fastboot
elif $IS_MAC; then
  brew install --cask android-platform-tools
fi

ensure_pkg age       # file encryption for chezmoi

ensure_uv_tool bandit  # security linter
ensure_pkg bash      # apple ships bash 3, linux has newer version

ensure_cargo_install bat  # better cat

if command -v pnpm &> /dev/null; then
  ensure_pnpm_global @bitwarden/cli  # to work with varlock
fi
if ! ensure_command bun; then
  curl -fsSL https://bun.com/install | bash
fi
ensure_cargo_install cargo-install-update cargo-update  # manage cargo-installed binaries, `cargo install-update -a` to update them all
if ! ensure_command chezmoi; then
  sh -c "$(curl -fsLS get.chezmoi.io)"  # dotfiles manager
fi

if ! ensure_command claude; then
  curl -fsSL https://claude.ai/install.sh | bash
fi
ensure_pkg coreutils
ensure_cargo_install choose  # eg: easily get the 3rd item in each line
if ! ensure_command difft && ! ensure_command difftastic; then
  ensure_cargo_install difftastic  # better git diff
fi
ensure_cargo_install dust du-dust  # better du
ensure_cargo_install eza  # better ls & tree with icons
ensure_cargo_install fd fd-find  # faster find
ensure_pkg ffmpeg
ensure_pkg fzf       # interactive filter

if $IS_LINUX; then
  # get newer git version
  sudo apt-add-repository -y ppa:git-core/ppa
  sudo apt-get update
fi
ensure_pkg git       # up-to-date git
ensure_pkg gh        # GitHub CLI
ensure_pkg git-filter-repo  # remove a file from git history
ensure_cargo_install delta git-delta  # git pager, works better for larger files as a pager than difftastic
ensure_pnpm_global @withgraphite/graphite-cli@stable  # gt for declaring branch dependencies


if $IS_MAC; then
  ensure_pkg graphviz  # generate (DB) diagrams (eg: DBeaver to generate ER diagrams)
fi

ensure_cargo_install hx helix-term  # vim with batteries included, no need to manage plugins
ensure_uv_tool httpie  # test APIs from terminal, like Postman but CLI
ensure_cargo_install hyperfine  # command benchmarking
ensure_pkg imagemagick  # like ffmpeg for images
ensure_pkg jc        # convert plain text data into JSON (to plug into jq)
ensure_pkg jq        # JSON processor
ensure_cargo_install just  # a better `Make` and `Makefile` replacement for tasks

ensure_uv_tool llm  # pipe LLM input & output from the terminal
llm install llm-anthropic

if ! ensure_command mise; then
  curl https://mise.run | sh
fi
eval "$(~/.local/bin/mise activate zsh)"  # activate it for this session

ensure_pkg moor
ensure_pkg mosh      # ssh for bad (mobile) connections
ensure_cargo_install pngquant  # png compression

# postgres
ensure_pkg pgcli
if $IS_MAC; then
  POSTGRES_NAME=$(brew formulae | grep postgresql@ | tail -1)
  ensure_pkg "$POSTGRES_NAME"
  brew services start postgresql
else
  ensure_pkg postgresql postgresql-contrib
fi
createuser -s postgres
createuser -s "$USER"
createdb "$USER"

ensure_cargo_install prek
prek install || true

# python ------------------------------------------------------------------
ensure_uv_tool ptpython
ensure_uv_tool pyright  # type checker that's faster than mypy
ensure_uv_tool rich-cli # highlight and format text
ensure_cargo_install rg ripgrep  # faster grep
ensure_uv_tool ruff ruff@latest
ensure_cargo_install sd  # faster sed
ensure_pkg shellcheck
ensure_pkg shfmt
ensure_uv_tool sqlfluff

if ! ensure_command tldr && ! ensure_command tealdeer; then
  ensure_cargo_install tealdeer  # prompt
fi
tldr --update

ensure_pkg tmux
ensure_pkg ugrep   # drop-in grep API when LLM still uses grep
if ! ensure_command varlock; then
  curl -sSfL https://varlock.dev/install.sh | sh -s  # varlock: AI-safe .env files: Schemas for agents, Secrets for humans.
fi
ensure_pkg vim

# weave: language aware merger
ensure_cargo_install weave weave-cli --git https://github.com/Ataraxy-Labs/weave
ensure_cargo_install weave-driver weave-driver --git https://github.com/Ataraxy-Labs/weave
weave setup

ensure_pkg wget

ensure_cargo_install wt worktrunk
wt config shell install

# yt-dlp
if command -v yt-dlp >/dev/null 2>&1; then
  # Update in-place when already installed
  yt-dlp -U || true
else
  mkdir -p "$HOME/.local/bin"
  if $IS_MAC; then
    curl -fsSL https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_macos -o "$HOME/.local/bin/yt-dlp"
  else
    curl -fsSL https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o "$HOME/.local/bin/yt-dlp"
  fi
  chmod +x "$HOME/.local/bin/yt-dlp"
fi

ensure_cargo_install zoxide
ensure_pkg zsh

if [ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
  config config --local status.showUntrackedFiles no
  echo 'source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"' >> ~/.zshrc

  touch ~/.lc_history

  zsh

  setopt EXTENDED_GLOB
  for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -sf "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
  done
fi

# Desktop applications (macOS) ------------------------------------------------
if $IS_MAC; then
  ensure_brew adobe-acrobat-reader
  ensure_brew anki
  ensure_brew balenaetcher
  ensure_brew chatgpt
  ensure_brew claude
  ensure_brew db-browser-for-sqlite
  ensure_brew discord
  ensure_brew docker
  ensure_brew figma
  ensure_brew finicky
  ensure_brew firefox

  # firefox policies
  mkdir -p ~/Library/Application\ Support/Firefox/distribution
  cp ~/.dotfiles/post-install/firefox-policies.json ~/Library/Application\ Support/Firefox/distribution/policies.json || true

  ensure_brew font-hack-nerd-font
  ensure_brew font-jetbrains-mono
  ensure_brew freedom
  ensure_brew google-chrome
  ensure_brew handbrake
  ensure_brew imageoptim
  ensure_brew iina
  ensure_brew iterm2

  if [ ! -f "$HOME/.iterm2_shell_integration.zsh" ]; then
    curl -L https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh
  fi

  ensure_brew itermai
  ensure_brew karabiner-elements
  ensure_brew keycastr
  ensure_brew modern-csv
  ensure_brew notion
  ensure_brew obsidian
  ensure_brew raspberry-pi-imager
  ensure_brew raycast
  ensure_brew rectangle
  ensure_brew sejda-pdf
  ensure_brew tableplus
  ensure_brew thaw
  ensure_brew todoist
  ensure_brew visual-studio-code
  ensure_brew wechat
  ensure_brew whatsapp
  ensure_brew wispr-flow
  ensure_brew zoom

  if ! command -v zed >/dev/null 2>&1; then
    curl -f https://zed.dev/install.sh | sh
  fi

  # App Store apps
  ensure_mas_app 1440147259  # AdGuard for Safari
  ensure_mas_app 937984704   # Amphetamine: keep mac working

  # Amphetamine Enhancer
  if ! [ -d /Applications/Amphetamine\ Enhancer.app ]; then
    cd /tmp
    curl -fL -o Amphetamine\ Enhancer.dmg https://github.com/x74353/Amphetamine-Enhancer/raw/master/Releases/Current/Amphetamine%20Enhancer.dmg
    hdiutil attach Amphetamine\ Enhancer.dmg
    cp -R /Volumes/Amphetamine\ Enhancer/Amphetamine\ Enhancer.app /Applications
    hdiutil detach /Volumes/Amphetamine\ Enhancer
    rm Amphetamine\ Enhancer.dmg
    cd - > /dev/null
  fi

  ensure_mas_app 1352778147  # BitWarden: app store version has more features, like TouchID
  ensure_mas_app 540348655   # Monosnap
  ensure_mas_app 1406676254  # Splice Crop: crop the middle of an image (M1 macs only)
  ensure_mas_app 1122008420  # TableTool, view CSVs
fi

# create the folder if it doesn't exist
mkdir -p ~/projects


# Remove the temporary timeout when done
sudo rm /etc/sudoers.d/timeout
