# dotfiles

### Setup
1. Install prezto (https://github.com/sorin-ionescu/prezto)
2. Backup all of your original config files
3. Clone this repo
4. Download Powerline Fonts (https://github.com/powerline/fonts)

```bash
sudo apt install zsh zsh-doc

# install prezto
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

# Clone this repo
git clone --bare https://github.com/Fullchee/dotfiles.git $HOME/.cfg
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
echo "alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'" >> $HOME/.bashrc
config config --local status.showUntrackedFiles no

# install powerline fonts
sudo apt-get install fonts-powerline

# change shell
chsh -s $(which zsh)
```

Finally change your font to a powerline font.
