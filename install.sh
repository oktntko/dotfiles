#!/bin/bash

# https://docs.brew.sh/Homebrew-on-Linux
# build-essential curl file git

# ------------------------------------------------------------------------------
# Homebrew
# ------------------------------------------------------------------------------
if !(type "brew" > /dev/null 2>&1); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
  test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
  test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile
  echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile

  brew doctor
fi

# ------------------------------------------------------------------------------
# package install
# ------------------------------------------------------------------------------
# zsh
brew install zsh
which zsh | sudo tee -a /etc/shells

brew install zplug tree bat ripgrep fzf git-delta

# nvm
if !(type "nvm" > /dev/null 2>&1); then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
fi

# vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# ------------------------------------------------------------------------------
# link
# ------------------------------------------------------------------------------
zsh "${ZDOTDIR:-$HOME}"/.dotfiles/link.zsh

# ------------------------------------------------------------------------------
# sh 変更して終了(パスワード聞かれる)
# ------------------------------------------------------------------------------
chsh -s /home/linuxbrew/.linuxbrew/bin/zsh
