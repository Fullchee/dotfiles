# dotfiles

### Setup
1. Install prezto (https://github.com/sorin-ionescu/prezto)
2. Backup all of your original config files
3. Clone this repo
4. Download Powerline Fonts (https://github.com/powerline/fonts)

```bash
# run the following two steps
git clone --bare https://github.com/Fullchee/cfg.git $HOME/.cfg
config config --local status.showUntrackedFiles no
```

To change shell, use
```bash
chsh -s $(which zsh)
```
