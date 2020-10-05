#!/bin/zsh

# link
setopt extended_glob
for rcfile in "${ZDOTDIR:-$HOME}"/.dotfiles/^(LICENSE|README.md|install.sh|link.sh)(.N); do
  echo $rcfile
done
setopt no_extended_glob
