#!/bin/zsh

# link
setopt extended_glob
for rcfile in "${ZDOTDIR:-$HOME}"/.dotfiles/^(LICENSE|README.md|install.sh|link.zsh)(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
setopt no_extended_glob
