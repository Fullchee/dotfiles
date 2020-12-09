# --- CONFIG
# use 'config' instead of 'git' to manage this git repo, lose all git auto-complete commands :(
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME' $@
alias configpull='git stash && git pull && git stash pop'
alias sz="source ~/.zshrc"

# --- Linux-only
alias updatevsc="sudo wget https://vscode-update.azurewebsites.net/latest/linux-deb-x64/stable -O /tmp/code_latest_amd64.deb; sudo dpkg -i /tmp/code_latest_amd64.deb"
alias chrome="google-chrome"
alias cpcwd="pwd | xclip -selection clipboard"

# --- Cross-platform
alias py="python"
alias vsc="code"
alias ls='ls -GF'
alias globalnpm="npm list -g --depth=0"

# get the largest files
alias largestfiles="du -h . | sort -rh" | head -100
alias syncdrives='rsync -av --exclude "My Passport/TV Shows" --exclude "My Passport/Movies" "/media/fullchee/My Passport" "/media/fullchee/second-backup"'
alias ipaddr="ifconfig | grep inet"

alias psg="ps aux | grep"
alias pgrep="pgrep -f"
alias eclipse="~/eclipse/java-neon/eclipse"
alias desktopentries="/usr/share/applications"
alias billinfo="keepass2 ~/Dropbox/Bill\ Info.kdbx && ~/.dropbox-dist/dropboxd"
alias androidemulator="~/Android/Sdk/tools/emulator -avd Nexus_5_API_25 > /dev/null &"
alias androidEmulator="androidemulator"
alias o.="o ."
alias restartdocker="sudo /etc/init.d/docker restart"
alias updategrive="cd ~/grive;grive;cd -"-
alias typora="opt/Typora-linux-x64/Typora &"
alias stopin30="sleep 1800; systemctl suspend;"
alias open=xdg-open
alias androidstudio="~/opt/android-studio/bin/studio.sh &"
