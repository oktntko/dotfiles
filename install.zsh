#!/bin/zsh

if [[ -z ${ZSH_VERSION} ]]; then
  echo 'You must use zsh to run install.zsh' >&2
  exit 1
fi

if ! type lsb_release > /dev/null; then
  echo 'You must install lsb-release' >&2
  exit 1
fi


# https://www.cyberciti.biz/faq/find-linux-distribution-name-version-number/
distribution=`lsb_release --id --short`

if [[ $distribution == "Arch" ]]; then
  git clone https://aur.archlinux.org/yay.git ./yay && cd ./yay && makepkg -si --noconfirm && cd .. && rm -rf ./yay
  yay -S --noconfirm bat ripgrep fzf exa

else
  NONINTERACTIVE=1 /bin/bash -c "$(curl --fail --silent --show-error --location https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  brew install bat ripgrep fzf exa
fi

# asdf
git clone https://github.com/asdf-vm/asdf.git ~/.asdf && \
  cd ~/.asdf && git checkout "$(git describe --abbrev=0 --tags)" && cd ~/

source "$HOME/.asdf/asdf.sh"

asdf plugin add nodejs
asdf plugin add java
asdf plugin add python

# chsh
sudo chsh $USER --shell $(which zsh)
