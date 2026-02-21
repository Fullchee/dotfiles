# Apple silicon
if [ -d /opt/homebrew/bin ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
# intel
elif [ -d /usr/local/bin ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

function lockafter() {
  # Check if a parameter was provided
  if [[ $# -eq 0 ]]; then
    echo "Usage: lockafter <minutes>"
    echo "Example: lockafter 5 (locks after 5 minutes)"
    return 1
  fi

  # Check if the parameter is a number
  if [[ ! $1 =~ ^[0-9]+$ ]]; then
    echo "Error: Please provide a valid number of minutes"
    return 1
  fi

  # Convert minutes to seconds
  local seconds=$(($1 * 60))

  # Inform the user
  echo "Your Mac will lock in $1 minute(s)."

  # Run the lock command in the background, make it harder to cancel
  nohup bash -c "sleep $seconds && pmset displaysleepnow" >/dev/null 2>&1 &
}

function notify() {
	if [ -z "$1" ] ; then
		echo 'Usage: notify <message> time'
		return
	fi
	echo 'notify-send "$1"' | at $2
}


# Hide/show all desktop icons (useful when presenting)
alias hide-desktop-icons="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias show-desktop-icons="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

update-raycast-config() {
	cd ~/.dotfiles
  	for file in Raycast\ 202*.rayconfig; do
		# Check if the file exists and matches the pattern
		if [[ -f "$file" ]]; then
			mv -f "$file" "Raycast.rayconfig"
		fi
	done
	cd - > /dev/null
}
