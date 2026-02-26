# dotfiles

# dotfiles

## Usage

### Mac usage

1. Open System Settings
2. Search for `Full Disk Access`
3. Give the built-in `Terminal` Full Disk Access
4. Open the `Terminal`
5. Run the script to setup the chezmoi `dotfiles` repo

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply Fullchee
```

## Background

- used git bare repo for a decade
  - worked when I had dotfiles on my computer, work computer, sister's computer
  - started to not work when I got a home server and multiple raspberry Pis but I wanted to have the same git experience
  - also nice how the installation process is for android too
