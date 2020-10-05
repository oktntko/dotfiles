#!/bin/bash

# Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile
echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile

brew doctor

# zsh
brew install zsh
which zsh | sudo tee -a /etc/shells

## plugins
### zplug
brew install zplug
## vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# link
zsh "${ZDOTDIR:-$HOME}"/.dotfiles/link.sh

# sh 変更して終了(パスワード聞かれる)
chsh -s /home/linuxbrew/.linuxbrew/bin/zsh

