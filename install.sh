#!/bin/bash

brew install zplug tree bat ripgrep fzf git-delta exa

# vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# chsh
chsh -s /bin/zsh
