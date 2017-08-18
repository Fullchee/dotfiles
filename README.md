# cfg

### Setup
1. Backup all of your original config files
2. Clone the repo
3. Install prezto (https://github.com/sorin-ionescu/prezto)
```bash
git clone --bare https://github.com/Fullchee/cfg.git $HOME/.cfg
```
```bash
# add this to the .aliases file
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
```

```bash
config config --local status.showUntrackedFiles no
```

To change shell, use
```bash
chsh -s $(which zsh)
```
