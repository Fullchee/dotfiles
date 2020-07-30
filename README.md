# dotfiles

## Install


```sh
git clone --bare https://github.com/Fullchee/dotfiles.git $HOME/.cfg
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config config --local status.showUntrackedFiles no
sudo apt install -y zsh
chsh -s /bin/zsh
./post-install.sh
```

## Manual install steps

- [ ] `ssh-keygen`
- [ ] Play On Linux
  - [ ] Install Office 2007 (word and excel)
- [ ] Chrome Login
- [ ] Firefox Login
- [ ] VSCode Sync (LastPass)
- [ ] [Anki](https://apps.ankiweb.net/)
	- [ ] [install all the plugins](https://gist.github.com/Fullchee/20d835b5d2d88eabc778f75f169015d2)
- [ ] use numix theme
   - [ ] System Settings -> Themes
- [ ] shutter
	- [ ] Create a new keyboard shortcut `shutter -s'
	- [ ] set to print screen
- [ ] sudo crontab -e
	- [ ] `* 1 * * * sudo poweroff`
- [ ] Setup bluetooth devices
	- [ ] portable speaker
	- [ ] wireless headphones
- [ ] RescueTime https://www.rescuetime.com/download_linux
	- [ ] login to Chrome extension
- [ ] `im-config` and use xim (ibus, the default has the annoying ctrl shift e shortcut)
   - [ ] then reset computer
- [ ] Settings -> Sound -> Sounds -> Starting Cinnamon (disable)
- [ ] [grive](https://github.com/vitalif/grive2) (run grive in ~/grive)
- [ ] Printers
```sh
# CANON MF4770n
wget -O linux-UFRII-drv-v370-usen-06.tar.gz "http://pdisp01.c-wss.com/gdl/WWUFORedirectTarget.do?id=MDEwMDAwOTIzNjAz&cmp=ABR&lang=EN"
tar -xzvf linux-UFRII-drv-v370-usen-06.tar.gz
sudo linux-UFRII-drv-v370-usen/install.sh
rm -rf linux-UFRII-drv-v370-usen
rm -f linux-UFRII-drv-v370-usen-06.tar.gz
```
- [ ] Java
	- [ ] [JDK](https://www.oracle.com/technetwork/java/javase/downloads/index.html)
	- [ ] [Intellij](https://www.oracle.com/technetwork/java/javase/downloads/index.html)
	- [ ] Android Studio
- [ ] GRUB Customizer
   - [ ] use a custom background image that's a `.png`

