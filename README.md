# dotfiles

# Requirements
- brew
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
- asdf (python 以外)
```
asdf plugin add nodejs && \
asdf plugin add java && \
asdf install
```

- asdf (python)
```
brew install openssl && \
LDFLAGS="-Wl,-rpath,$(brew --prefix openssl)/lib" \
CPPFLAGS="-I$(brew --prefix openssl)/include" \
CONFIGURE_OPTS="--with-openssl=$(brew --prefix openssl)" \
asdf install python
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
