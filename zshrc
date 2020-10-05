# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# init
## brew
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

## zplug 
export ZPLUG_HOME=/home/linuxbrew/.linuxbrew/opt/zplug
source $ZPLUG_HOME/init.zsh

# alias
alias ls='ls --color=auto'
alias ll='ls -lphA --group-directories-first --time-style=long-iso'

# zsh
## 補完機能を使用する
autoload -Uz compinit && compinit
autoload -Uz bashcompinit && bashcompinit
zstyle ':completion:*:default' menu select=1

## 
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

## 
setopt auto_cd
setopt auto_list
setopt auto_menu
setopt hist_ignore_dups
setopt share_history

unsetopt list_types
unsetopt prompt_sp

## 色付け
autoload -Uz colors && colors
export LS_COLORS='di=94:ln=36:ex=32:so=46;34:pi=43;34'
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# プロンプトのカスタマイズ
autoload -Uz promptinit && promptinit
zplug romkatv/powerlevel10k, as:theme, depth:1

## plugin
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"

## check install
if ! zplug check --verbose; then
    zplug install
fi

## load
zplug load --verbose

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
