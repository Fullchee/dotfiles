#!/bin/zsh

set -euo pipefail

# Caddy (reverse proxy with automatic HTTPS)
docker network create caddy
docker run -d --name caddy \
    -p 80:80 -p 443:443 -p 443:443/udp \
    -v caddy_data:/data \
    -v caddy_config:/config \
    -v "$HOME/Caddyfile:/etc/caddy/Caddyfile" \
    --restart unless-stopped \
    caddy:latest

# Cloudflare Tunnels
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o ~/.local/bin/cloudflared && chmod +x ~/.local/bin/cloudflared

# docker
curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh
rm -f get-docker.sh
sudo usermod -aG docker "$USER" # grant access to docker socket (don't need to run sudo for docker)

# dockploy (local vercel)
curl -sSL https://dokploy.com/install.sh | sudo sh

# File explorer (accessible online storage)
docker run -d --name filebrowser --network caddy -v /:/srv -e PUID=1000 -e PGID=1000 filebrowser/filebrowser

# Home assistant: http://192.168.50.11:8123
docker run -d --name homeassistant --privileged -v /etc/localtime:/etc/localtime:ro -v /home/fullchee/.homeassistant:/config -v /run/dbus:/run/dbus --network=host ghcr.io/home-assistant/home-assistant:stable

# Homepage (dashboard)
docker run -d --name homepage --network caddy -v /home/fullchee/homepage:/app/config --restart unless-stopped ghcr.io/benphelps/homepage:latest

# Immich (Google Photos)
# http://192.168.50.11:2283
mkdir "$HOME/immich"
cd "$HOME/immich"
wget -O docker-compose.yml https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml
wget -O .env https://github.com/immich-app/immich/releases/latest/download/example.env

# Jellyfin
docker run -d --name jellyfin --network caddy -v jellyfin-config:/config -v jellyfin-media:/media jellyfin/jellyfin

# lazydocker
curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

# n8n (self hosted Zapier)
docker run -d --name n8n --network caddy -v n8n_data:/home/node/.n8n n8nio/n8n

# opencode
curl -fsSL https://opencode.ai/install | bash

# qbittorrent
sudo apt-get install -y qbittorrent-nox

# tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# VaultWarden
docker run -d --name vaultwarden --network caddy -v /vw-data:/data --restart unless-stopped vaultwarden/server:latest

# Watchtower (auto-update docker containers)
docker run -d --name watchtower -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --schedule "0 0 4 * * *" --cleanup

sudo apt-get install -y w3m # terminal based browser

# Whatsapp bot (Baileys)
pnpm add -g pm2 # keep your bot running (auto-restart on crash)
pnpm add -g qrcode-terminal
pnpm add -g @whiskeysockets/baileys

# Create Caddyfile for reverse proxy (update domain names)
mkdir -p "$HOME/caddy"
cat >"$HOME/caddy/Caddyfile" <<'EOF'
# TODO: Replace example.com with your actual domain

# Homepage dashboard
home.example.com {
    reverse_proxy homepage:3000
}

# VaultWarden password manager
vault.example.com {
    reverse_proxy vaultwarden:80
}

# n8n automation
n8n.example.com {
    reverse_proxy n8n:5678
}

# Jellyfin media server
media.example.com {
    reverse_proxy jellyfin:8096
}

# FileBrowser
files.example.com {
    reverse_proxy filebrowser:80
}

# Duplicati backups
backups.example.com {
    reverse_proxy duplicati:8200
}

# Paperless-ngx documents
docs.example.com {
    reverse_proxy paperless-ngx:8000
}

# Uptime Kuma
status.example.com {
    reverse_proxy uptime-kuma:3001
}

# LinkStack
link.example.com {
    reverse_proxy linkstack:80
}
EOF
