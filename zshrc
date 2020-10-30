# ================================================================================
# .zshrc
# ================================================================================

# --------------------------------------------------------------------------------
# init
# --------------------------------------------------------------------------------

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

## brew
export PATH="/home/linuxbrew/.linuxbrew/bin:$HOME/bin:$PATH"

## zplug
export ZPLUG_HOME=/home/linuxbrew/.linuxbrew/opt/zplug
source $ZPLUG_HOME/init.zsh

# --------------------------------------------------------------------------------
# alias
# --------------------------------------------------------------------------------

alias ls='ls --color=auto'
alias ll='ls -lphA --group-directories-first --time-style=long-iso'
alias ..='cd ..'
alias dotfiles="cd ~/.dotfiles"

# --------------------------------------------------------------------------------
# zsh 設定
# --------------------------------------------------------------------------------
## 色付け
autoload -Uz colors && colors
export LS_COLORS='di=94:ln=36:ex=32:so=46;34:pi=43;34'

## 補完機能を使用する
autoload -Uz compinit && compinit
autoload -Uz bashcompinit && bashcompinit
zstyle ':completion:*:default' menu select=1
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

## ヒストリ設定
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
### 直前のコマンドの重複を削除
setopt hist_ignore_dups
### 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups
### 同時に起動したzshの間でヒストリを共有
setopt share_history

## ディレクトリ関連
### cdなしでディレクトリ名を直接指定して移動
setopt auto_cd
### 補完候補が複数ある時に、一覧表示
setopt auto_list
### 補完キー（Tab, Ctrl+I) を連打するだけで順に補完候補を自動で補完
setopt auto_menu

## プロンプトのカスタマイズ
autoload -Uz promptinit && promptinit
zplug romkatv/powerlevel10k, as:theme, depth:1

# --------------------------------------------------------------------------------
# plugin
# --------------------------------------------------------------------------------
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"

# git diff
zplug "zdharma/zsh-diff-so-fancy"

# --------------------------------------------------------------------------------
# fzf
# --------------------------------------------------------------------------------
zplug "junegunn/fzf-bin", as:command, from:gh-r, rename-to:fzf
# cd
zplug "b4b4r07/enhancd", use:init.sh
# git
zplug "wfxr/forgit"
function fzf-checkout-branch() {
  local branches branch
  branches=$(git branch | sed -e 's/\(^\* \|^  \)//g' | cut -d " " -f 1) &&
  branch=$(echo "$branches" | fzf --preview "git log --oneline --graph --color=always {}") &&
  git checkout $(echo "$branch")
}

alias gcb=fzf-checkout-branch

# default options
export FZF_DEFAULT_OPTS='--color=fg+:11 --height 70% --reverse --select-1 --exit-0 --multi'
# files
export FZF_CTRL_T_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_CTRL_T_OPTS='--preview "bat --color=always --style=numbers,header,grid --line-range :500 {} | head -200"'
# cd
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"

# check install
if ! zplug check --verbose; then
    zplug install
fi

# load
zplug load

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --------------------------------------------------------------------------------
# os差分
# --------------------------------------------------------------------------------
if [[ -n $(uname | grep -i 'Darwin') ]] ; then
  # 'MacOS'

elif [[ -n $( uname | grep -i 'Linux' ) ]] && [[ -z $( uname -r | grep -i 'microsoft' ) ]] ; then
  # 'Linux'

elif [[ -n $( uname | grep -i 'Linux' ) ]] && [[ -n $( uname -r | grep -i 'microsoft' ) ]] ; then
  # 'WSL'
  export WSL_ip_line=$(ipconfig.exe | grep "WSL" -n | awk -F ":" '{print $1+4}')
  export DISPLAY=$(ipconfig.exe | awk -v a=$WSL_ip_line '{if (NR==a) print $NF":0.0"}' | tr -d "\r")
  export WINDOWS_USERNAME=$(cd /mnt/c && cmd.exe /c 'echo %USERNAME%' | awk '{ print $1 }' | tr -d "\r")

  alias pwdw="wslpath -w ."

else
  # 'Windows'

fi

# --------------------------------------------------------------------------------
# function
# --------------------------------------------------------------------------------
wslcd() {
  if [[ -n $(echo $1 | grep -a '\\') ]] ; then
    builtin cd $(wslpath -u $1)
  else
    builtin cd $1
  fi
}

# --------------------------------------------------------------------------------
# bindkey
# --------------------------------------------------------------------------------
# confirm : sudo showkey
[[ ! -f ~/.dotfiles/key-bindings.zsh ]] || source ~/.dotfiles/key-bindings.zsh

bindkey "^[[H"    beginning-of-line   # Home
bindkey "^[[F"    end-of-line         # End
bindkey "^[[3~"   delete-char         # Delete
bindkey "^[[1;5D" emacs-backward-word # Ctrl + Left
bindkey "^[[1;5C" emacs-forward-word  # Ctrl + Right
bindkey "^H"      backward-kill-word  # Ctrl + Backspace

# --------------------------------------------------------------------------------
# その他
# --------------------------------------------------------------------------------
# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# --------------------------------------------------------------------------------
# local用
# --------------------------------------------------------------------------------
[[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local
