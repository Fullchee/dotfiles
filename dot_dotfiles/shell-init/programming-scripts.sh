# Table of contents
# General
# Android
# Databases
# Networking

## -------- General --------
alias tldrf='tldr --list | fzf --preview "tldr {1} --color=always" --preview-window=right,70% | xargs tldr'

alias sz="source ~/.zshrc"
eval "$(zoxide init zsh)"
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"



set-terminal-tab-title() {
  # XTerm Control Sequences, OSC: Operating System Commands
  # \033 Escape character
  # ]: OSC: Operating System Command
  # 1: Change Icon Name Only
  # ;: separator
  osc_header="\033]1;"
  osc_terminator="\007"  # bell character, historically, rang a bell
  content="$1"

  # Print using %b for escapes and %s for strings
  printf "%b%s%b" "$osc_header" "$content" "$osc_terminator"
}

# write current command location to `.zsh_history_ext` whenever a command is ran
# `.zsh_history_ext` is used in `lc` command
function zshaddhistory() {
  # ignore empty commands
  if [[ $1 == $'\n' ]]; then return; fi

  # ignore specific commands
  local COMMANDS_TO_IGNORE=( last ls ll cd j git gss gap lc ggpush ggpull);
  for i in "${COMMANDS_TO_IGNORE[@]}"
  do
    # return if the run commands starts with the ignored commands
    if [[ $1 == "$i"* ]]; then
      return;
    fi
  done

  echo "${1%%$'\n'}${LC_DELIMITER_START}${PWD}${LC_DELIMITER_END}" >> ~/.lc_history
}

# `lc`:  last command
function last() {
  SELECTED_COMMAND=$(grep -a --color=never "${PWD}${LC_DELIMITER_END}" ~/.lc_history | cut -f1 -d "${LC_DELIMITER_START}" | tail -r | fzf);

  # handle case of selecting no command via fzf
  if [[ ${#SELECTED_COMMAND} -gt 0 ]]; then
    echo "Running '$SELECTED_COMMAND'..."
    echo "**************************"
    eval " $SELECTED_COMMAND";
  fi
}


## -------- General end  --------

## -------- Android --------
export ANDROID_SDK=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_SDK/tools
export PATH=$PATH:$ANDROID_SDK/tools/bin
export PATH=$PATH:$ANDROID_SDK/platform-tools
## -------- Android end --------

## -------- Databases --------
export PATH="/opt/homebrew/opt/postgresql@18/bin:$PATH"
alias copydb=createdb -O postgres -T

renamedb() {
  local old_db_name=$1
  local new_db_name=$2

  if [ -z "$old_db_name" ] || [ -z "$new_db_name" ]; then
    echo "Usage: rename_or_create_db <old_db_name> <new_db_name>"
    return 1
  fi

  echo "Checking if database '$new_db_name' exists..."

  # Check if the new database already exists
  if psql -U postgres -lqt | cut -d \| -f 1 | grep -qw "$new_db_name"; then
    echo "Database '$new_db_name' already exists."
  else
    echo "Renaming database '$old_db_name' to '$new_db_name'..."
    # Rename the old database to the new name
    psql -U postgres -c "ALTER DATABASE \"$old_db_name\" RENAME TO \"$new_db_name\";"
    echo "Database '$old_db_name' has been renamed to '$new_db_name'."
  fi
}

alias killpostmaster="rm /usr/local/var/postgres/postmaster.pid"
alias fixpsql="killpostmaster"

# mv_table $DB_SRC $DB_DEST "table_name"
function mv_table {
  psql -d $2 -c "TRUNCATE TABLE $3;"
  pg_dump -d $1 --no-owner --no-acl -Fc --table=$3 | pg_restore -d $2 --no-owner --no-acl --table=$3
}

## -------- Databases END --------


## -------- Networking --------
get-ip() {
  echo Your ip is; dig +short myip.opendns.com @resolver1.opendns.com;
}

get-wifi-mac() {
    # 1. Extract the MAC address (jumping 2 lines down from Wi-Fi)
    local mac=$(networksetup -listallhardwareports | \
                grep -A 2 "Wi-Fi" | \
                grep -oE "([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}")

    # 2. Check if we actually found something
    if [ -n "$mac" ]; then
        echo "$mac"            # Print to terminal
        echo -n "$mac" | pbcopy # Copy to clipboard (the -n removes the newline)
    else
        echo "Error: Could not find Wi-Fi MAC address. ❌"
    fi
}


killport() {
    if [ -z "$1" ] ; then
        echo 'Usage: killport <portnumber'
        return
    fi
    kill $(lsof -t -i:"$1")
}

##################### Node

eval "$(fnm env --use-on-cd --corepack-enabled)"

function fnm-use() {
	fnm list | awk '{print $2}' | fzf --header "Pick node version" | xargs fnm use
}

export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

#################### Node end ####################


#################### Python ####################
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
alias py=python
export PIP_REQUIRE_VIRTUALENV=true
alias ptpy=ptpython

export PATH="$HOME/.local/bin:$PATH"  # pipx adds packages here

if [ -f "$HOME/.local/bin/env" ]; then
  . "$HOME/.local/bin/env"
fi

eval "$(uv generate-shell-completion zsh)"

venv() {
  # no arg given -> try venv and .venv
  if [[ -z "$1" ]]; then
    if [[ -f "venv/bin/activate" ]]; then
      source venv/bin/activate
      return
    elif [[ -f ".venv/bin/activate" ]]; then
      source .venv/bin/activate
      return
    elif [[ -f "../venv/bin/activate" ]]; then
      source ../venv/bin/activate
      return
    elif [[ -f "../.venv/bin/activate" ]]; then
      source ../.venv/bin/activate
      return
    else
      echo "Please provide a path to your venv. Didn't find a venv or .venv"
      return 1
    fi
  fi

  if [[ -f "$1/venv/bin/activate" ]]; then
    source "$1/venv/bin/activate"
  elif [[ -f "$1/.venv/bin/activate" ]]; then
    source "$1.venv/bin/activate"
  elif [[ -f "$1/bin/activate" ]]; then
    source "$1/bin/activate"
  else
    echo "'$1/bin/activate' does not exist."
    return 1
  fi
}

#################### Python end  ####################
