> I switched to a Mac as my main device.
> 
> Those dotfiles are private because they have work specific stuff

https://github.com/Fullchee/mac-dotfiles

# dotfiles

- [Mac dotfiles (private)](https://github.com/Fullchee/mac-dotfiles)
- [Windows dotfiles](https://github.com/Fullchee/windows-dotfiles)

## Install

1. `ssh-keygen`
2. `cat ~/.ssh/id_rsa.pub`
3. https://github.com/settings/keys   
4. Clone this repo (no sudo)

```sh
sudo apt install -y  zsh
git init --bare $HOME/.cfg
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config config --local status.showUntrackedFiles no
config remote add origin https://github.com/Fullchee/dotfiles.git
config fetch origin master
config reset --hard origin/master
config branch --set-upstream-to=origin/master master
zsh ~/.post-install.sh
```

## Manual install steps

### Cross platform
- [ ] [Anki](https://apps.ankiweb.net/)
	- [ ] [install all the plugins](https://gist.github.com/Fullchee/20d835b5d2d88eabc778f75f169015d2)
- [ ] Firefox Login
	- [ ] browser.sessionstore.warnOnQuit (set to true)
- [ ] Setup bluetooth devices
	- [ ] portable speaker
	- [ ] wireless headphones
- [ ] Dropbox and Keepass

### Linux

#### Canon Printer 

```sh
# CANON MF4770n
wget -O linux-UFRII-drv-v370-usen-06.tar.gz "http://pdisp01.c-wss.com/gdl/WWUFORedirectTarget.do?id=MDEwMDAwOTIzNjAz&cmp=ABR&lang=EN"
tar -xzvf linux-UFRII-drv-v370-usen-06.tar.gz
sudo linux-UFRII-drv-v370-usen/install.sh
rm -rf linux-UFRII-drv-v370-usen
rm -f linux-UFRII-drv-v370-usen-06.tar.gz
```

- [ ] Play On Linux
  - [ ] Install Office 2007 (word and excel)
- [ ] use numix theme
   - [ ] System Settings -> Themes
- [ ] shutter
	- [ ] Create a new keyboard shortcut `shutter -s'
	- [ ] set to print screen
- [ ] sudo crontab -e
	- [ ] `* 1 * * * sudo poweroff`
- [ ] `im-config` and use xim (ibus, the default has the annoying ctrl shift e shortcut)
   - [ ] then reset computer
- [ ] Settings -> Sound -> Sounds -> Starting Cinnamon (disable)
- [ ] Settings -> Window Tiling -> Maximize instead of tile (check)
- [ ] Java
	- [ ] [JDK](https://www.oracle.com/technetwork/java/javase/downloads/index.html)
	- [ ] [Intellij](https://www.oracle.com/technetwork/java/javase/downloads/index.html)
	- [ ] Android Studio
- [ ] GRUB Customizer
   - [ ] use a custom background image that's a `.png`

