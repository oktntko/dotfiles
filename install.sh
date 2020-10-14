#!/bin/bash

# Homebrew
if !(type "brew" > /dev/null 2>&1); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
  test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
  test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile
  echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile

  brew doctor
fi

# zsh
if !(type "zsh" > /dev/null 2>&1); then
  brew install zsh
  which zsh | sudo tee -a /etc/shells
fi

## plugins
### zplug
if !(type "zplug" > /dev/null 2>&1); then
  brew install zplug
fi

### vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

### nvm
if !(type "nvm" > /dev/null 2>&1); then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.36.0/install.sh | bash
fi

# link
zsh "${ZDOTDIR:-$HOME}"/.dotfiles/link.zsh

# sh 変更して終了(パスワード聞かれる)
chsh -s /home/linuxbrew/.linuxbrew/bin/zsh

