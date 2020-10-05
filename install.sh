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
### prezto
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
### zplug
brew install zplug
## vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

chsh -s /home/linuxbrew/.linuxbrew/bin/zsh

SCRIPT_DIR=$(cd $(dirname $0); pwd)
zsh ${SCRIPT_DIR}/link.sh

setopt extended_glob
for rcfile in "${SCRIPT_DIR}"^(README.md|LICENSE|install.sh)(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
setopt no_extended_glob
