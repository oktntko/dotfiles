#!/bin/zsh

local SCRIPT_DIR=$(cd $(dirname $0); pwd)

local links=$(find "$SCRIPT_DIR"/links -type f | sed -e 's/\(^\* \|^ \)//g' | cut -d " " -f 1) &&
echo $links | fzf --preview "bat --color=always --style=numbers,header,grid --line-range :500 {}" | while read item; do
  ln -s "${(q)item}" "${ZDOTDIR:-$HOME}/.$(basename ${(q)item})"
done
