# dotfiles

# Requirements
- ubuntu
```
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential procps curl file git zsh
git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew
mkdir ~/.linuxbrew/bin
ln -s ~/.linuxbrew/Homebrew/bin/brew ~/.linuxbrew/bin
eval $(~/.linuxbrew/bin/brew shellenv)
```

# install

``
## インストール
```
git clone git@github.com:oktntko/dotfiles.git ~/.dotfiles
sh ~/.dotfiles/install.sh
```

## 説明書き
1. Homebrewをインストール
2. Homebrewで zshをインストール
3. gitで preztoをダウンロード
4. Homebrewで zplugをインストール
5. curlで vim-plugをダウンロード
6. zshに デフォルトのシェルを変更
