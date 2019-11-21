# dotfiles

### Setup
1. Run the linux post install script
   * https://github.com/Fullchee/post-install-scripts/blob/master/linux/linux-post-install.sh
   * (also installs powerline fonts)

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

# remove stock zsh files that conflict with my dot files
mkdir -p .config-backup && \
config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
xargs -I{} mv {} .config-backup/{}

config checkout

config config --local status.showUntrackedFiles no

# install powerline fonts
sudo apt-get install fonts-powerline

# change shell
chsh -s $(which zsh)
```
