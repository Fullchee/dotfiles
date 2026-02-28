# dotfiles

## Usage

### Mac pre-install steps

1. Grant the `Terminal` Full Disk Access (so that chezmoi can edit files in /Library folders )
   1. Open System Settings
   2. Search for `Full Disk Access`
   3. Give the built-in `Terminal` Full Disk Access

## Common steps

1. Open the `Terminal`
2. Set the hostname(s)

**macOS:**

```sh
sudo scutil --set HostName fullchee-mac      # the canonical name used by DNS
sudo scutil --set LocalHostName fullchee-mac # Bonjour/local network name (no spaces)
sudo scutil --set ComputerName fullchee-mac  # shown in Sharing preferences and login screen
```

- **Linux:**

```sh
sudo hostnamectl set-hostname fullchee-home-server
```

Run the script to setup the chezmoi `dotfiles` repo

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply Fullchee
```

While it's running

1. Copy the value of the public SSH key
   1. `cat ~/.ssh/id_ed25519.pub | pbcopy`
      1. if this changes, update [`.ssh/config`](https://github.com/Fullchee/mac-dotfiles/blob/main/.ssh/config)
2. Add the key to GitHub twice (authentication + signing)
   1. <https://github.com/settings/keys>
3. Log into the App Store (for `mas` CLI to work)

### Mac manual steps

#### Work Mac

- Set the values of `$HOME/.dotfiles/shell-init/citylitics-secrets.sh` from Bitwarden

#### Settings

- Finder: View -> Show Path bar
- System Settings
  - Accessibility
    - Zoom -> Use scroll gesture with modifier keys to zoom
    - Read & Speak
      - Speak Selection: enable
      - System Voice -> (i)
        - Download and set voice to Siri 1 (Siri 4 sounds robotic)
        - Increment speed by 1
  - Appearance -> Show scroll bars -> Always
    - doesn't seem to work: `defaults write NSGlobalDomain AppleShowScrollBars -string Always`
  - Full Disk Access -> Give Full Disk Acess to iTerm
  - Keyboard
    - Keyboard Navigation: Enable
    - Text Input -> Edit -> Add period with double-space (turn off)
    - Keyboard shortcuts
      - Mission Control: disable everything
      - Spotlight -> Show Spotlight Search: disable (when installing Raycast)
  - Login Items & Extensions
    - Actions: enable ImagOptim
  - Location
    - just allow weather and some System Settings to use location
  - Menu Bar
    - Sound: Always Show
    - Show Weather
    - Remove Spotlight
  - Screenshot: cmd shift 5 -> Options
    - save to Desktop
    - show Mouse cursor
  - Trackpad
    - Tap to click
    - -> Scroll & Save: Natural scrolling: disable

#### External devices

- Connect to Bluetooth devices
  - portable speaker
  - headphones
  - earbuds
- Printer
  - [Canon printer driver](https://www.usa.canon.com/internet/portal/us/home/support/details/printers/black-and-white-laser/mf4770n/imageclass-mf4770n?tab=drivers_downloads)
  - [Brother printer driver](https://support.brother.com/g/b/downloadtop.aspx?c=ca&lang=en&prod=hl2240_us_eu)
    - Doesn't support Mac anymore: need to download from <https://www.freeprinterdriverdownload.org/download-brother-hl-2240-driver/amp/>

## Background

- used git bare repo for a decade
  - worked when I had dotfiles on my computer, work computer, sister's computer
  - started to not work when I got a home server and multiple raspberry Pis but I wanted to have the same git experience
  - also nice how the installation process is for android too
