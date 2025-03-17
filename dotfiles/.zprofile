for BREW_DIR in {/home/linuxbrew,$HOME}/.linuxbrew
do
  [[ ! -f ${BREW_DIR}/bin/mise ]] || eval $($BREW_DIR/bin/mise activate zsh --shims)
done
