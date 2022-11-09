c#!/bin/zsh

if type yay > /dev/null; then
  yay -S tree bat ripgrep fzf git-delta exa
elif type apt > /dev/null; then
  sudo apt install tree bat ripgrep fzf exa # TODO git-delta
elif type brew > /dev/null; then
  brew install tree bat ripgrep fzf git-delta exa
fi

# vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# chsh
chsh -s /bin/zsh
