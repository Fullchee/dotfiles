#!/bin/zsh

# Extend sudo timeout to 120 minutes so that it doesn't ask for a password every minute
sudo sh -c 'echo "Defaults timestamp_timeout=120" > /etc/sudoers.d/timeout'

if ! command -v brew &> /dev/null; then
  echo "Installing homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add homebrew to path for this script
  # Apple silicon
  if [ -d /opt/homebrew/bin ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  # intel
  elif [ -d /usr/local/bin ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

brew update;

brew install ansible;
brew install cask;
brew install cloud-sql-proxy;  # connect securely to GCP Cloud SQL
brew install coreutils;
brew install gh;  # GitHub CLI
brew install git;  # newer version of git
brew install graphviz;  # for WatrHub Django model ERDs
brew install imagemagick;
brew install jordanbaird-ice;  # hide items in the menu bar, better than HiddenBar
brew install mas;  # mac app store CLI
brew install mycli;  # better MySQL CLI (auto-complete)
brew install pipx;
brew install pre-commit;  # Git pre-commit hooks
brew install pyenv;
brew tap hashicorp/tap;
brew install hashicorp/tap/terraform;
brew install vim;
brew install wget;

brew install --cask docker;
brew install --cask figma;
brew install --cask font-hack-nerd-font;  # font with icons (for eza)
brew install --cask gcloud-cli;
brew install --cask google-chrome;
brew install --cask loom;
brew install --cask mysqlworkbench;
brew install --cask raycast;  # nicer app launcher/spotlight
brew install --cask rectangle;  # change window sizes, nicer than Raycast's keyboard shortcuts
brew install --cask tableplus;  # database GUI
brew install --cask slack;
brew install --cask visual-studio-code;
brew install --cask zoom;

mas install 1352778147; # BitWarden: app store version has more features, like TouchID
mas install 540348655;  # Monosnap: screenshot tool
mas install 1518036000; # Sequel Ace (MySQL GUI)
mas install 1122008420; # TableTool, view CSVs


brew tap shopify/shopify
brew install ejson
sudo mkdir -p /opt/ejson/keys
sudo chown -R $(whoami) /opt/ejson

cd ~
git clone git@github.com:WatrHub/watrhub-django.git;
cd watrhub-django;
pre-commit install;

# TODO: get python version from GitHub repo
PYTHON_VERSION="3.9.24"
pyenv init
pyenv install $PYTHON_VERSION
pyenv global $PYTHON_VERSION
pyenv local $PYTHON_VERSION

# TODO: FETCH NODE VERSION FROM GITHUB REPO
# node
NODE_VERSION=24
curl -fsSL https://fnm.vercel.app/install | bash;  # fnm: faster nvm
fnm install $NODE_VERSION;
fnm default $NODE_VERSION;

npm install -g @github/copilot  # only works on Node v22+


# TODO: steps to setup watrhub django app

# TODO: finish ejson setup
# in your rc file
# export EJSON_PUBLIC_KEY=380307...
# export EJSON_PRIVATE_KEY=1f9e45...
rm -f /opt/ejson/keys/${EJSON_PUBLIC_KEY}
touch /opt/ejson/keys/${EJSON_PUBLIC_KEY}
echo ${EJSON_PRIVATE_KEY} > /opt/ejson/keys/${EJSON_PUBLIC_KEY}



# requires user config

echo "Set dev-review-env as default project";
echo "Default GCE region: doesn't matter";

gcloud auth application-default login;
gcloud config set project dev-review-env;


# Remove the temporary timeout when done
sudo rm /etc/sudoers.d/timeout
