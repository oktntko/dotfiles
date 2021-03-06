# dotfiles

# Requirements
- brew
```
git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew
mkdir ~/.linuxbrew/bin
ln -s ~/.linuxbrew/Homebrew/bin/brew ~/.linuxbrew/bin
eval $(~/.linuxbrew/bin/brew shellenv)
```

- asdf
```
git clone https://github.com/asdf-vm/asdf.git ~/.asdf
cd ~/.asdf
git checkout "$(git describe --abbrev=0 --tags)"
```

- zplug
```
git clone https://github.com/zplug/zplug ~/.zplug
```

# Install
```
git clone https://github.com/oktntko/dotfiles.git ~/.dotfiles
zsh ~/.dotfiles/install.zsh
zsh ~/.dotfiles/link.zsh
```

- asdf
```
asdf plugin add nodejs
asdf plugin add python
asdf install
asdf reshim python
python --version
node -v

pip install --upgrade pip
pip install pipenv
asdf reshim python
pipenv --version
```
