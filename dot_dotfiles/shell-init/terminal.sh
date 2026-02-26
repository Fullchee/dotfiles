alias -s {js,json,env,gitignore,md,html,css,toml}=bat # https://www.stefanjudis.com/today-i-learned/suffix-aliases-in-zsh/
source <(fzf --zsh)

alias grep=ugrep

alias la="eza --icons --grid --all"
alias ll='eza -la --git --icons'
alias searchtree='eza --tree --icons --git-ignore | fzf'

function ls() {
  # 1. Define the default flags as a Zsh **array** for correct expansion.
  local default_flags=(--git --icons --grid --git-ignore)

  # 2. Check if any of the exclusion flags are present in the arguments provided to 'ls'.
  if [[ " $@ " =~ " -a " || " $@ " =~ " --all " || " $@ " =~ " --no-git " ]]; then
    # 3. If an exclusion flag is found, remove '--git-ignore' from the default_flags array.
    # The '=${arrayname/(pattern)/}' syntax is a Zsh array removal/substitution.
    default_flags=(${default_flags[@]/:#--git-ignore/})
  fi

  # 4. Execute 'eza' using "${default_flags[@]}" to expand the array
  # correctly into separate, quoted arguments, followed by the user's arguments ($@).
  eza "${default_flags[@]}" "$@"
}

# Arguments:
#   Depth (int) (optional, default=2)
# Usage:
#	tree . 1
# 	tree folder_name 2
tree() {
	eza --tree --icons --git-ignore -L "${2:-2}" "${1:-.}"
}

# use fd so that it respects .gitignore
# https://github.com/junegunn/fzf#respecting-gitignore
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'c

# Fuzzy find all files and subdirectories of the working directory, and output the selection to STDOUT.
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Fuzzy find all subdirectories of the working directory, and run the command "cd" with the output as argument.
export FZF_ALT_C_COMMAND="fd --type d --strip-cwd-prefix --hidden --follow --exclude .git"

alias ...="cd ../.."
alias ....="cd ../../.."

#### File and folder helpers START

mkcd() {
  mkdir "$1"
  cd "$1"
}

function diffdir() {
	diff -r $1 $2 | grep $1 | awk '{print $4}'
}

# asdf/fileName.ext => fileName
function extract-filename() {
	fullfile="$1"
	filename=$(basename "$fullfile")  # asdf/fieleName.ext => fileName.ext
	echo "${filename%.*}"  # fileName.ext => fileName
}
