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
# install

```
git https://github.com/oktntko/dotfiles.git ~/.dotfiles
zsh ~/.dotfiles/install.zsh
zsh ~/.dotfiles/link.zsh
```

## 説明書き
1. Homebrewをインストール
2. Homebrewで zshをインストール
3. gitで preztoをダウンロード
4. Homebrewで zplugをインストール
5. curlで vim-plugをダウンロード
6. zshに デフォルトのシェルを変更
