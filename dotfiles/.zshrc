
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

# toc
# - Load
# - Behaviour
#   - Environment ... Sets generic Zsh built-in environment options.
#   - Input       ... Applies correct bindkeys for input events.
# - Productivity
#   - alias
# - Modules
# - Check

## Load ------------------------------------------------------------------------
  #* Powerlevel10k
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi

  #* Homebrew on Linux
  for BREW_DIR in {/home/linuxbrew,$HOME}/.linuxbrew
  do
    [[ ! -f ${BREW_DIR}/bin/brew ]] || eval $($BREW_DIR/bin/brew shellenv)
  done

  #* mise
  eval "$(mise activate zsh)"

#/ Load ------------------------------------------------------------------------

## Behaviour -------------------------------------------------------------------

  ## Environment ---------------------------------------------------------------
  #* Completion
  autoload -Uz compinit && compinit
  autoload -Uz bashcompinit && bashcompinit
  autoload -Uz promptinit && promptinit
  autoload -Uz colors && colors
  export LS_COLORS='di=94:ln=36:ex=32:so=46;34:pi=43;34'
  zstyle ':completion:*:default' menu select=1
  zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
  setopt AUTO_LIST # 補完候補が複数ある時に、一覧表示
  setopt AUTO_MENU # 補完キー（Tab, Ctrl+I) を連打するだけで順に補完候補を自動で補完

  #* Changing directories
  setopt AUTO_CD # cdなしでディレクトリ名を直接指定して移動

  #* Editor
  export EDITOR=vim

  #* History
  HISTFILE="$HOME/.history"
  HISTSIZE=100000
  SAVEHIST=100000
  setopt HIST_IGNORE_DUPS # 直前のコマンドの重複を削除
  setopt HIST_IGNORE_ALL_DUPS # 同じコマンドをヒストリに残さない
  setopt HIST_IGNORE_SPACE # 先頭がスペースで始まる場合は履歴に追加しない
  setopt HIST_FIND_NO_DUPS # 履歴検索中、(連続してなくとも)重複を飛ばす
  setopt HIST_NO_STORE # histroyコマンドは記録しない
  setopt HIST_REDUCE_BLANKS # 余分な空白は詰めて記録
  setopt SHARE_HISTORY # 同時に起動したzshの間でヒストリを共有

  #* Input/output
  setopt INTERACTIVE_COMMENTS # コマンド上でコメントを有効にする
  setopt NO_CLOBBER # `>` による既存ファイルの上書きを許可しない。代わりに `>|` または `>!` を使用してください。
  setopt NO_BEEP # ビープ音
  #/ Environment ---------------------------------------------------------------

  ## Input ---------------------------------------------------------------------
  # confirm : sudo showkey
  autoload -Uz select-word-style
  select-word-style default
  zstyle ':zle:*' word-chars ' _-./;:={}[]()<>'
  zstyle ':zle:*' word-style unspecified

  bindkey "^[[H"    beginning-of-line   # Home
  bindkey "^[[F"    end-of-line         # End
  bindkey "^[[3~"   delete-char         # Delete
  bindkey "^[[1;5D" backward-word # Ctrl + Left
  bindkey "^[[1;5C" forward-word  # Ctrl + Right
  bindkey "^H"      backward-kill-word  # Ctrl + Backspace
  bindkey "^[[3;5~" kill-word           # Ctrl + Delete
  #/ Input ---------------------------------------------------------------------

#/ Behaviour -------------------------------------------------------------------

## Productivity ----------------------------------------------------------------

  ## alias ---------------------------------------------------------------------
  #* ls
  if (( ${+commands[eza]} )); then
    alias ls='eza --color=auto'
    alias ll='eza --all --long --modified --group --group-directories-first --icons --git --time-style=long-iso'
  fi

  #* grep
  if (( ${+commands[rg]} )); then
    alias grep='rg --ignore-case'
  fi

  #* cat
  if (( ${+commands[bat]} )); then
    alias cat='bat --pager="less -RFX"'
  fi
  #/ alias ---------------------------------------------------------------------

#/ Productivity ----------------------------------------------------------------

## Modules ---------------------------------------------------------------------
  #* enhancd
  export ENHANCD_ENABLE_DOUBLE_DOT=false
  export ENHANCD_ENABLE_HOME=false

  #* modules
  for file in $HOME/.dotfiles/modules/*.zsh(.N); do
    source $file
  done
#/ Modules ---------------------------------------------------------------------

## Check -----------------------------------------------------------------------
  #* zim
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

  # * local
  [[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local

  #* Powerlevel10k
  # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

