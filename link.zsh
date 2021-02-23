#!/bin/zsh

local SCRIPT_DIR=$(cd $(dirname $0); pwd)

for link_file in $(find "$SCRIPT_DIR"/links -type f); do
  ln -s "$link_file" "${ZDOTDIR:-$HOME}/.$(basename $link_file)"
done
