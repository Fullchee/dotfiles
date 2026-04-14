# Setup fzf
# ---------
FZF_BASE=""
if [[ -d /opt/homebrew/opt/fzf ]]; then
  FZF_BASE=/opt/homebrew/opt/fzf
elif [[ -d /usr/local/opt/fzf ]]; then
  FZF_BASE=/usr/local/opt/fzf
fi

if [[ -n "$FZF_BASE" && ! "$PATH" == *$FZF_BASE/bin* ]]; then
  PATH="${PATH:+${PATH}:}/$FZF_BASE/bin"
fi

if [[ -n "$FZF_BASE" && -f "$FZF_BASE/shell/completion.zsh" && -f "$FZF_BASE/shell/key-bindings.zsh" ]]; then
  source "$FZF_BASE/shell/completion.zsh"
  source "$FZF_BASE/shell/key-bindings.zsh"
else
  source <(fzf --zsh)
fi
