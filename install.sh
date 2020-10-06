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

### vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

### nodenv
brew install nodenv
mkdir -p "$(nodenv root)"/plugins
git clone https://github.com/nodenv/nodenv-update.git "$(nodenv root)"/plugins/nodenv-update
git clone https://github.com/nodenv/nodenv-package-rehash.git "$(nodenv root)"/plugins/nodenv-package-rehash
# --------------------------------------------------------------------------------
# nodenv -l
# nodenv install 12.18.4
# nodenv rehash
# nodenv global 12.18.4
# --------------------------------------------------------------------------------


# link
zsh "${ZDOTDIR:-$HOME}"/.dotfiles/link.zsh

# sh 変更して終了(パスワード聞かれる)
chsh -s /home/linuxbrew/.linuxbrew/bin/zsh

