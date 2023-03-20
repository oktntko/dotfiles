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

if [[ $distribution == "Ubuntu" ]]; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl --fail --silent --show-error --location https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  brew install bat ripgrep fzf exa
fi

# chsh
sudo chsh $USER --shell $(which zsh)
