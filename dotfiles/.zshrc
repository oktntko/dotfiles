
# ================================================================================
#  __________________________________________
#   __________________________________________
#    _____________________________/\\\_________
#     ____________________________\/\\\_________
#      ____________________________\/\\\_________
#       __/\\\\\\\\\\\__/\\\\\\\\\\_\/\\\_________
#        _\///////\\\/__\/\\\//////__\/\\\\\\\\\\__
#         ______/\\\/____\/\\\\\\\\\\_\/\\\/////\\\_
#          ____/\\\/______\////////\\\_\/\\\___\/\\\_
#           __/\\\\\\\\\\\__/\\\\\\\\\\_\/\\\___\/\\\_
#            _\///////////__\//////////__\///____\///__
#             __________________________________________
#              __________________________________________
#               __________________________________________
# ================================================================================
## Powerlevel10k
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

## Homebrew on Linux
[[ ! -f /home/linuxbrew/.linuxbrew/bin/brew ]] || eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)

## asdf
[[ ! -f "$HOME/.asdf/asdf.sh" ]] || source "$HOME/.asdf/asdf.sh"

## asdf-python
export PIPENV_VENV_IN_PROJECT=true

## asdf-java
[[ ! -f ~/.asdf/plugins/java/set-java-home.zsh ]] || source ~/.asdf/plugins/java/set-java-home.zsh

# --------------------------------------------------------------------------------
# alias
# --------------------------------------------------------------------------------

# --------------------------------------------------------------------------------
# ls
# --------------------------------------------------------------------------------
alias ls='exa --color=auto'
alias ll='exa --all --long --modified --group --group-directories-first --icons --git --time-style=long-iso'

# --------------------------------------------------------------------------------
# grep
# --------------------------------------------------------------------------------
alias grep='rg'

# --------------------------------------------------------------------------------
# cat
# --------------------------------------------------------------------------------
alias cat='bat'


# --------------------------------------------------------------------------------
# docker
# --------------------------------------------------------------------------------
alias dcs='docker-compose start'
alias dcp='docker-compose stop'

# --------------------------------------------------------------------------------
# bindkey
# --------------------------------------------------------------------------------
# confirm : sudo showkey

bindkey "^[[H"    beginning-of-line   # Home
bindkey "^[[F"    end-of-line         # End
bindkey "^[[3~"   delete-char         # Delete
bindkey "^[[1;5D" emacs-backward-word # Ctrl + Left
bindkey "^[[1;5C" emacs-forward-word  # Ctrl + Right
bindkey "^H"      backward-kill-word  # Ctrl + Backspace

# --------------------------------------------------------------------------------
# env
# --------------------------------------------------------------------------------

# --------------------------------------------------------------------------------
# enhancd
# --------------------------------------------------------------------------------
export ENHANCD_DISABLE_DOT=1
export ENHANCD_DISABLE_HOME=1

# --------------------------------------------------------------------------------
# zsh 設定
# --------------------------------------------------------------------------------

## 補完機能を使用する
fpath=($ASDF_DIR/completions $fpath)
autoload -Uz compinit && compinit
autoload -Uz bashcompinit && bashcompinit
autoload -Uz promptinit && promptinit
autoload -Uz colors && colors
export LS_COLORS='di=94:ln=36:ex=32:so=46;34:pi=43;34'
# 補完でカラーを使用する
zstyle ':completion:*:default' menu select=1
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

## エディタ
export EDITOR=vim

## ヒストリ設定
HISTFILE="$HOME/.history"
HISTSIZE=100000
SAVEHIST=100000
### 直前のコマンドの重複を削除
setopt hist_ignore_dups
### 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups
### 先頭がスペースで始まる場合は履歴に追加しない
setopt hist_ignore_space
### 同時に起動したzshの間でヒストリを共有
setopt share_history
### 余分な空白は詰めて記録
setopt hist_reduce_blanks

## ディレクトリ関連
### cdなしでディレクトリ名を直接指定して移動
setopt auto_cd
### 補完候補が複数ある時に、一覧表示
setopt auto_list
### 補完キー（Tab, Ctrl+I) を連打するだけで順に補完候補を自動で補完
setopt auto_menu
### コマンド上でコメントを有効にする
setopt interactivecomments

#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/
#
# https://www.mankier.com/1/fzf
#
# - $FZF_TMUX_OPTS
# - $FZF_CTRL_T_COMMAND
# - $FZF_CTRL_T_OPTS
# - $FZF_CTRL_R_OPTS
# - $FZF_ALT_C_COMMAND
# - $FZF_ALT_C_OPTS

# --------------------------------------------------------------------------------
# オプション
# --------------------------------------------------------------------------------
# default  | パイプ経由で候補リストが渡されなかったときのデフォルトコマンド
export FZF_DEFAULT_COMMAND='rg --files --follow --glob "!.git/*"'
export FZF_DEFAULT_OPTS='--reverse --bind=shift-up:preview-up,shift-down:preview-down,shift-left:preview-page-up,shift-right:preview-page-down'
# Ctrl + T | 現在のディレクトリ配下のファイル検索
export FZF_CTRL_T_COMMAND='rg --files --follow --glob "!.git/*"'
export FZF_CTRL_T_OPTS='--cycle --preview-window=75% --preview="bat --color=always --style=numbers,header,grid --line-range :500 {}"'
# Alt + C  | 現在のディレクトリ配下のディレクトリ検索
# export FZF_ALT_C_COMMAND=""
export FZF_ALT_C_OPTS="--cycle --preview-window=75% --preview='tree -C {}'"
# Ctrl + R | ヒストリの検索
# export FZF_CTRL_R_OPTS=""

# --------------------------------------------------------------------------------
# Key bindings
# --------------------------------------------------------------------------------
# The code at the top and the bottom of this file is the same as in completion.zsh.
# Refer to that file for explanation.
if 'zmodload' 'zsh/parameter' 2>'/dev/null' && (( ${+options} )); then
  __fzf_key_bindings_options="options=(${(j: :)${(kv)options[@]}})"
else
  () {
    __fzf_key_bindings_options="setopt"
    'local' '__fzf_opt'
    for __fzf_opt in "${(@)${(@f)$(set -o)}%% *}"; do
      if [[ -o "$__fzf_opt" ]]; then
        __fzf_key_bindings_options+=" -o $__fzf_opt"
      else
        __fzf_key_bindings_options+=" +o $__fzf_opt"
      fi
    done
  }
fi

'emulate' 'zsh' '-o' 'no_aliases'

{

[[ -o interactive ]] || return 0

# CTRL-T - Paste the selected file path(s) into the command line
__fsel() {
  local cmd="${FZF_CTRL_T_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type f -print \
    -o -type d -print \
    -o -type l -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail no_aliases 2> /dev/null
  eval "$cmd" | FZF_DEFAULT_OPTS="--reverse $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) -m "$@" | while read item; do
    echo -n "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

__fzfcmd() {
  [ -n "$TMUX_PANE" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "$FZF_TMUX_OPTS" ]; } &&
    echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

fzf-file-widget() {
  LBUFFER="${LBUFFER}$(__fsel)"
  local ret=$?
  zle reset-prompt
  return $ret
}
zle     -N   fzf-file-widget
bindkey '^T' fzf-file-widget

# Ensure precmds are run after cd
fzf-redraw-prompt() {
  local precmd
  for precmd in $precmd_functions; do
    $precmd
  done
  zle reset-prompt
}
zle -N fzf-redraw-prompt

# ALT-C - cd into the selected directory
fzf-cd-widget() {
  local cmd="${FZF_ALT_C_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type d -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail no_aliases 2> /dev/null
  local dir="$(eval "$cmd" | FZF_DEFAULT_OPTS="--reverse $FZF_DEFAULT_OPTS $FZF_ALT_C_OPTS" $(__fzfcmd) +m)"
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  if [ -z "$BUFFER" ]; then
    BUFFER="cd ${(q)dir}"
    zle accept-line
  else
    print -sr "cd ${(q)dir}"
    cd "$dir"
  fi
  local ret=$?
  unset dir # ensure this doesn't end up appearing in prompt expansion
  zle fzf-redraw-prompt
  return $ret
}
zle     -N    fzf-cd-widget
bindkey '\ec' fzf-cd-widget

# CTRL-R - Paste the selected command from history into the command line
fzf-history-widget() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
  selected=( $(fc -rl 1 | perl -ne 'print if !$seen{(/^\s*[0-9]+\**\s+(.*)/, $1)}++' |
    FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort $FZF_CTRL_R_OPTS --query=${(qqq)LBUFFER} +m" $(__fzfcmd)) )
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle reset-prompt
  return $ret
}
zle     -N   fzf-history-widget
bindkey '^R' fzf-history-widget

} always {
  eval $__fzf_key_bindings_options
  'unset' '__fzf_key_bindings_options'
}

# ------------------
# Initialize modules
# ------------------

ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi
# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
# Initialize modules.
source ${ZIM_HOME}/init.zsh

# --------------------------------------------------------------------------------
# local用
# --------------------------------------------------------------------------------
[[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local

## Powerlevel10k
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
