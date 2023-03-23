#!/bin/zsh

if [[ -z ${ZSH_VERSION} ]]; then
  echo 'You must use zsh to run install.zsh' >&2
  exit 1
fi

if type lsb_release > /dev/null; then
  # https://www.cyberciti.biz/faq/find-linux-distribution-name-version-number/
  distribution=`lsb_release --id --short`

else
  distribution="distribution"

fi

if [[ $distribution == "Arch" ]]; then
  if ! type yay > /dev/null; then
    git clone https://aur.archlinux.org/yay.git ./yay && cd ./yay && makepkg -si --noconfirm && cd .. && rm -rf ./yay
  fi

  yay -S --noconfirm bat ripgrep fzf exa

else
  if ! type brew > /dev/null; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl --fail --silent --show-error --location https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi

  brew install bat ripgrep fzf exa
fi

# asdf
if ! type asdf > /dev/null; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf && \
    cd ~/.asdf && git checkout "$(git describe --abbrev=0 --tags)" && cd ~/

  source "$HOME/.asdf/asdf.sh"
fi

asdf plugin add nodejs
asdf plugin add java
asdf plugin add python

# chsh
sudo chsh $USER --shell $(which zsh)

# dotfiles
for DOTFILE in \
  ".default-npm-packages" \
  ".default-python-packages" \
  ".gitconfig" \
  ".p10k.zsh" \
  ".tool-versions" \
  ".vimrc" \
  ".zimrc" \
  ".zshrc"
do
  curl -fsSL --create-dirs -o ${HOME}/${DOTFILE} \
      https://raw.githubusercontent.com/oktntko/dotfiles/main/dotfiles/${DOTFILE}
done

# modules
for MODULE in \
  "fzf.init.zsh"
do
  curl -fsSL --create-dirs -o ${HOME}/.dotfiles/modules/${MODULE} \
      https://raw.githubusercontent.com/oktntko/dotfiles/main/modules/${MODULE}
done
