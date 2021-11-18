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
