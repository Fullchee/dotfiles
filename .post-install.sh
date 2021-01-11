#!/bin/zsh

# adding repos
sudo add-apt-repository -y ppa:atareao/atareao
sudo add-apt-repository -y ppa:numix/ppa
sudo add-apt-repository -y ppa:alessandro-strada/ppa
sudo add-apt-repository -y ppa:linuxuprising/shutter
sudo add-apt-repository -y ppa:peek-developers/stable
sudo add-apt-repository -y ppa:jtaylor/keepass
sudo add-apt-repository -y ppa:linrunner/tlp
sudo add-apt-repository -y ppa:linuxgndu/sqlitebrowser
sudo add-apt-repository -y ppa:nilarimogard/webupd8
sudo add-apt-repository -y ppa:cpick/hub

# flashing with balena-etcher
echo "deb https://deb.etcher.io stable etcher" | sudo tee /etc/apt/sources.list.d/balena-etcher.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61

# VSCode
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo wget https://vscode-update.azurewebsites.net/latest/linux-deb-x64/stable -O /tmp/code_latest_amd64.deb; sudo dpkg -i /tmp/code_latest_amd64.deb

sudo rm -f /etc/apt/preferences.d/nosnap.pref

sudo apt install snapd -y

# sublime text
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

# google chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list

# yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# heroku
sudo add-apt-repository "deb https://cli-assets.heroku.com/branches/stable/apt ./"
curl -L https://cli-assets.heroku.com/apt/release.key | sudo apt-key add -

# Todo: typora
#wget -qO - https://typora.io/linux/public-key.asc | sudo apt-key add -
#echo -e "\ndeb https://typora.io/linux ./" | sudo tee -a /etc/apt/sources.list

# node
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -

sudo apt-get -y --force-yes update
sudo apt-get -y --force-yes upgrade

# installing the programs
sudo apt-get -y install at
sudo apt-get -y install apt-transport-https # for vscode
sudo apt-get -y install balena-etcher-electron
sudo apt-get -y install imagemagick
sudo apt-get -y install fd-find
sudo apt-get -y install convert
sudo apt-get -y install dconf-editor
sudo apt-get -y install gcc
sudo apt-get -y install git
sudo apt-get -y install google-chrome-stable
sudo apt-get -y install grive
sudo apt-get -y install gnome-shell-pomodoro
sudo apt-get -y install gnumeric
sudo apt-get -y install grub-customizer
sudo apt-get -y install gconf-editor
sudo apt-get -y install guake
sudo apt-get -y install heroku
sudo apt-get -y install keepass2
sudo apt-get -y install nodejs build-essential npm
sudo apt-get -y install numix-gtk-theme
sudo apt-get -y install numix-icon-theme
sudo apt-get -y install pandoc # convert between file types
sudo apt-get -y install peek # record gifs
sudo apt-get -y install playonlinux # have Microsoft Office on Linux
sudo apt-get -y install postgresql
sudo apt-get -y install powerline-fonts
sudo apt-get -y install redshift # fl.ux for Linux, turn your screen red
sudo apt-get -y install redshift-gtk
sudo apt-get -y install ruby-all-dev
sudo apt-get -y install silversearcher-ag # grep but much better
sudo apt-get -y install shutter # screenshot and quick editing
# libgoo-canvas-perl
sudo apt-get -y install sqlitebrowser
sudo apt-get -y install sublime-text
sudo apt-get -y install texlive-full
sudo apt-get -y install touchpad-indicator
sudo apt-get -y install tlp
sudo apt-get -y install tree # print the file structure
sudo apt-get -y install typora
sudo apt-get -y install vlc
sudo apt-get -y install wine-stable
sudo apt-get -y install xclip
sudo apt-get -y install xterm
sudo apt-get -y install unetbootin
sudo apt-get -y install vim
sudo apt-get -y install yank
sudo apt-get -y install zip
sudo apt-get -y install zsh
sudo apt-get -y install zsh-doc

sudo apt remove -y tomboy
sudo apt-get remove -y gnome-screenshot # I use shutter instead, you can edit 
sudo apt remove -y hexchat
sudo apt remove -y thunderbird
sudo apt remove -y gnome-calendar

# youtube-dl`
pip3 install youtube-dl

# dropbox
cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -

#sudo snap install slack --classic
#sudo snap install docker circleci
#sudo snap connect circleci:docker docker

sudo snap install authy --beta

# Install Anki
# TODO: create a function that will check if the newer version exists
# https://github.com/ankitects/anki/releases/latest => https://github.com/ankitects/anki/releases/tag/2.1.29
wget -c https://github.com/ankitects/anki/releases/download/2.1.29/anki-2.1.29-linux-amd64.tar.bz2

tar -xjf anki-2.1.29-linux-amd64.tar.bz2
cd anki-2.1.29-linux-amd64
sudo make install
cd ..
rm -rf anki-2.1.29-linux-amd64
rm -f anki-2.1.29-linux-amd64.tar.bz2

git config --global user.email "fullchee@gmail.com"
git config --global user.name "Fullchee Zhang"

# if you have a synaptics touchpad, you need this command for touchpad-indicator
killall syndaemon


# install my dotfiles after installing prezto
git clone --bare https://github.com/Fullchee/cfg.git $HOME/.cfg
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME' $@
config config --local status.showUntrackedFiles no
config reset --hard
config update-index --assume-unchanged ~/.npmrc  # don't want to accidentally add npm credentials

# Disable global Linux Mint help when pressing F1
sudo chmod -x /usr/local/bin/yelp

npm install -g npm \
babel-eslint \
eslint \
eslint-config-airbnb \
eslint-plugin-import \
eslint-plugin-jsx-a11y \
eslint-plugin-react \
eslint-plugin-react-hooks \
heroku \
jest \
netlify \
tldr \
write-good

# disable the insert button
xmodmap -e "keycode 118 ="



# install screenkey
# git -C ~/opt clone https://github.com/wavexx/screenkey.git
# sudo ~/opt/screenkey/setup.py install

# create google drive
mkdir ~/grive

git config --global credential.helper store

mkdir ~/learning

cd ~/Desktop
wget https://raw.githubusercontent.com/Fullchee/post-install-scripts/master/linux/zsh-scripts.sh
chmod u+x zsh-scripts.sh
cd -

# shutter packages for editing
wget https://launchpad.net/ubuntu/+archive/primary/+files/libgoocanvas-common_1.0.0-1_all.deb
sudo apt install -y ./libgoocanvas-common_1.0.0-1_all.deb
rm -f libgoocanvas-common_1.0.0-1_all.deb

wget https://launchpad.net/ubuntu/+archive/primary/+files/libgoocanvas3_1.0.0-1_amd64.deb
sudo apt install -y ./libgoocanvas3_1.0.0-1_amd64.deb
rm -f ./libgoocanvas3_1.0.0-1_amd64.deb

wget https://launchpad.net/ubuntu/+archive/primary/+files/libgoo-canvas-perl_0.06-2ubuntu3_amd64.deb
sudo apt install -y ./libgoo-canvas-perl_0.06-2ubuntu3_amd64.deb
rm -f ./libgoo-canvas-perl_0.06-2ubuntu3_amd64.deb

# firefox developer edition
sudo apt remove -y firefox
wget https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=linux64&lang=en-CA
tar -xvf firefox-*.tar.bz2
sudo mv firefox /opt
sudo ln -s /opt/firefox/firefox /usr/local/bin/firefox
sudo touch ~/.local/share/applications/Firefox.cinnamon-generated.desktop
echo "Icon=/opt/firefox/browser/chrome/icons/default/default48.png" | tee -a ~/.local/share/applications/Firefox.cinnamon-generated.desktop
sudo chmod +x ~/.local/share/applications/Firefox.cinnamon-generated.desktop

# install prezto
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME' $@
rm -rf ~/.zprezto
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
config config --local status.showUntrackedFiles no
config reset --hard
config update-index --assume-unchanged ~/.npmrc  # don't want to accidentally add npm credentials

# Linux: use local time, dual boot: don't change Windows time
timedatectl set-local-rtc 1 --adjust-system-clock

# https://code.visualstudio.com/docs/setup/linux#_visual-studio-code-is-unable-to-watch-for-file-changes-in-this-large-workspace-error-enospc
echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf

