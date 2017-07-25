# cfg

### Setup
```bash
git init --bare $HOME/.cfg
```
```bash
# add this to the .aliases file
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
```

```bash
config config --local status.showUntrackedFiles no
```

### Transfer to new setup
```bash
git clone --bare https://github.com/Fullchee/cfg.git $HOME/.cfg
```
