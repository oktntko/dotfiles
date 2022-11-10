# dotfiles

# Requirements
- brew(ubuntuの場合)
```
git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew && \
mkdir ~/.linuxbrew/bin && \
ln -s ~/.linuxbrew/Homebrew/bin/brew ~/.linuxbrew/bin && \
eval $(~/.linuxbrew/bin/brew shellenv)
```

- asdf
```
git clone https://github.com/asdf-vm/asdf.git ~/.asdf && \
cd ~/.asdf && git checkout "$(git describe --abbrev=0 --tags)" && cd ~/
```

- zplug
```
git clone https://github.com/zplug/zplug ~/.zplug
```

# Install
```
git clone https://github.com/oktntko/dotfiles.git ~/.dotfiles && \
zsh ~/.dotfiles/install.zsh && \
zsh ~/.dotfiles/link.zsh
```

# re login
- asdf
```
asdf plugin add nodejs && \
asdf plugin add java && \
asdf plugin add python && \
asdf install
```

- node
```
npm i -g npm@latest
```

- python
```
pip install --upgrade pip && \
pip install pipenv && \
asdf reshim python && \
pipenv --version
```

- version
```
python --version && \
node --version && \
java --version
```
