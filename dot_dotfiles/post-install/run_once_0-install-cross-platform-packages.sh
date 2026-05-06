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

ensure_command() {
  local cmd="$1"
  if ! command -v "$cmd" &> /dev/null; then
    return 1
  fi
  return 0
}

ensure_executable() {
  local name="$1"
  local install_cmd="$2"
  if ! command -v "$name" &>/dev/null; then
    eval "$install_cmd"
  fi
}

ensure_cargo() {
  # Usage: ensure_cargo <bin> [crate] [--git <git_url>] [cargo args...]
  # Examples:
  #   ensure_cargo bat
  #   ensure_cargo cargo-install-update cargo-update
  #   ensure_cargo ping --locked
  #   ensure_cargo weave weave-cli --git https://github.com/Ataraxy-Labs/weave
  #   ensure_cargo gws --git https://github.com/googleworkspace/cli --locked
  # If only <bin> is provided, assume the crate name matches the binary name.
  local bin="$1"; shift
  local crate="$bin"
  if [ "$#" -gt 0 ] && [ "$1" != "--git" ]; then
    crate="$1"; shift
  fi

  local git_url=""
  local cargo_args=()
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --git)
        shift
        git_url="$1"; shift
        ;;
      *)
        cargo_args+=("$1")
        shift
        ;;
    esac
  done

  if ! ensure_command "$bin"; then
    if [ -n "$git_url" ]; then
      cargo install --git "$git_url" "$crate" "${cargo_args[@]}"
    else
      cargo install --locked "$crate" "${cargo_args[@]}"
    fi
  fi
}

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


ensure_uv_tool() {
  local bin="$1"; shift
  if ! ensure_command "$bin"; then
      uv tool install "$bin"
  fi
}

ensure_pnpm_global() {
  local pkg="$1" ; shift
  if ! pnpm list -g 2>/dev/null | grep -q "$pkg"; then
    pnpm add -g "$pkg"
  fi
}

ensure_brew() {
  local cli_name="$1"
  local brew_name="${2:-$1}"

  if ! brew ls --versions "$cli_name" >/dev/null 2>&1; then
    brew install "$brew_name"
  fi
}

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
  sudo apt-get install -y build-essential  # for cargo install, bitwarden CLI to work on linux, provides cc for compiling dependencies
fi

# node environment ----------------------------------------------------
ensure_executable mise 'curl https://mise.run | sh'
eval "$(~/.local/bin/mise activate zsh)"  # activate it for this session
mise use -g node@lts
npm i -g npm
npm i -g corepack@latest
corepack enable pnpm
corepack use pnpm@latest
ensure_executable bun 'curl -fsSL https://bun.com/install | bash'

# cross-platform package installs -------------------------------------

# adb
if $IS_LINUX; then
  sudo apt install android-tools-adb android-tools-fastboot
elif $IS_MAC; then
  brew install --cask android-platform-tools
fi

ensure_pkg age       # file encryption for chezmoi

ensure_brew anki

ensure_uv_tool bandit  # security linter

ensure_brew balenaetcher

ensure_pkg bash      # apple ships bash 3, linux has newer version
ensure_cargo bat  # better cat
ensure_pnpm_global @bitwarden/cli  # to work with varlock
ensure_cargo cargo-install-update cargo-update  # manage cargo-installed binaries, `cargo install-update -a` to update them all

ensure_brew chatgpt

ensure_executable chezmoi 'sh -c "$(curl -fsLS get.chezmoi.io)"'  # dotfiles manager
ensure_cargo choose  # eg: easily get the 3rd item in each line
ensure_executable claude 'curl -fsSL https://claude.ai/install.sh | bash'

ensure_brew claude

ensure_pkg coreutils

ensure_brew db-browser-for-sqlite

ensure_cargo delta git-delta  # git pager, works better for larger files as a pager than difftastic
ensure_cargo difft difftastic  # better git diff

ensure_brew discord
ensure_brew docker

ensure_cargo dust du-dust  # better du
ensure_cargo eza  # better ls & tree with icons
ensure_cargo fd fd-find  # faster find
ensure_pkg ffmpeg

ensure_brew figma
ensure_brew finicky

if $IS_MAC; then
  ensure_brew firefox
  # firefox policies
  mkdir -p ~/Library/Application\ Support/Firefox/distribution
  cp ~/.dotfiles/post-install/firefox-policies.json ~/Library/Application\ Support/Firefox/distribution/policies.json || true
fi

if $IS_MAC; then
  ensure_brew font-hack-nerd-font
  ensure_brew font-jetbrains-mono
fi

ensure_brew freedom

ensure_pkg fzf       # interactive filter
ensure_pkg gh        # GitHub CLI

if $IS_LINUX; then
  # get newer git version
  sudo apt-add-repository -y ppa:git-core/ppa
  sudo apt-get update
fi
ensure_pkg git       # up-to-date git
ensure_pkg git-filter-repo  # remove a file from git history
ensure_pnpm_global @withgraphite/graphite-cli@stable  # gt for declaring branch dependencies

ensure_brew google-chrome

if $IS_MAC; then
  ensure_pkg graphviz  # generate (DB) diagrams (eg: DBeaver to generate ER diagrams)
fi

ensure_cargo gws --git https://github.com/googleworkspace/cli --locked
ensure_brew handbrake

ensure_cargo hx helix-term  # vim with batteries included, no need to manage plugins
ensure_uv_tool httpie  # test APIs from terminal, like Postman but CLI
ensure_cargo hyperfine  # command benchmarking

ensure_pkg imagemagick  # like ffmpeg for images

ensure_pkg jc        # convert plain text data into JSON (to plug into jq)
ensure_pkg jq        # JSON processor
ensure_cargo just  # a better `Make` and `Makefile` replacement for tasks
ensure_cargo just-lsp # LSP server for justfiles

ensure_uv_tool llm  # pipe LLM input & output from the terminal
llm install llm-anthropic

ensure_brew modern-csv

ensure_pkg moor
ensure_pkg mosh      # ssh for bad (mobile) connections

ensure_brew notion
ensure_brew obsidian

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

ensure_cargo pngquant  # png compression
ensure_cargo prek
prek install || true

ensure_uv_tool ptpython
ensure_uv_tool pyright  # type checker that's faster than mypy

ensure_brew raspberry-pi-imager

ensure_uv_tool rich-cli # highlight and format text
ensure_cargo rg ripgrep  # faster grep
ensure_uv_tool ruff@latest
ensure_cargo sd  # faster sed

ensure_brew sejda-pdf

ensure_pkg shellcheck
ensure_pkg shfmt
ensure_uv_tool sqlfluff

ensure_brew tableplus

ensure_cargo tldr tealdeer  # prompt
tldr --update

ensure_pkg tmux

ensure_brew todoist

ensure_pkg ugrep   # drop-in grep API when LLM still uses grep
ensure_executable varlock 'curl -sSfL https://varlock.dev/install.sh | sh -s'  # varlock: AI-safe .env files: Schemas for agents, Secrets for humans.
ensure_pkg vim

ensure_brew visual-studio-code

# weave: language aware merger
ensure_cargo weave weave-cli --git https://github.com/Ataraxy-Labs/weave
ensure_cargo weave-driver weave-driver --git https://github.com/Ataraxy-Labs/weave
weave setup

ensure_brew wechat

ensure_pkg wget

ensure_brew whatsapp

ensure_cargo wt worktrunk
wt config shell install

# yt-dlp
if command -v yt-dlp >/dev/null 2>&1; then
  # Update in-place when already installed
  uv tool upgrade yt-dlp
else
  uv tool install yt-dlp
fi

if $IS_MAC; then ensure_executable zed 'curl -f https://zed.dev/install.sh | sh'; fi

ensure_cargo zoxide

ensure_brew zoom

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

# create the folder if it doesn't exist
mkdir -p ~/projects


# Remove the temporary timeout when done
sudo rm /etc/sudoers.d/timeout
