- [yuk7/ArchWSL](https://github.com/yuk7/ArchWSL/releases)から Arch.zip をダウンロード
  - `C:\Users\user\.arch` にダウンロードしたものとする
- zipファイルを展開する
  - `C:\Users\user\.arch`
    - Arch.exe
    - Arch.zip
    - rootfs.tar.gz
- [docs](https://wsldl-pg.github.io/ArchW-docs/How-to-Setup/)に従ってセットアップする
```
>Arch.exe
[root@PC-NAME user]# passwd
>Arch.exe
[root@PC-NAME]# echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel
(setup sudoers file.)

[root@PC-NAME]# useradd -m -G wheel -s /bin/bash {username}
(add user)

[root@PC-NAME user]# passwd {username}
(set default user password)

[root@PC-NAME user]# exit

>Arch.exe config --default-user {username}
    (setting to default user)
>Arch.exe
[user@PC-NAME]$ sudo pacman-key --init

[user@PC-NAME]$ sudo pacman-key --populate

[user@PC-NAME]$ sudo pacman -Syy archlinux-keyring

[user@PC-NAME]$ sudo pacman -Syu

[user@PC-NAME]$ sudo pacman -Sy base-devel git zsh wget curl
```
- [yay](https://github.com/Jguer/yay)をインストールする
```
[user@PC-NAME]$ git clone https://aur.archlinux.org/yay.git

[user@PC-NAME]$ cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay
```
- Dockerを使うために [Distrod](https://github.com/nullpo-head/wsl-distrod#option-2-make-your-current-distro-run-systemd)で systemctl を有効にする
```
curl -L -O "https://raw.githubusercontent.com/nullpo-head/wsl-distrod/main/install.sh"
chmod +x install.sh
sudo ./install.sh install
sudo /opt/distrod/bin/distrod enable
```
- Dockerをインストール
```
yay -S docker
yay -S docker-compose
sudo systemctl start docker
sudo systemctl status docker
sudo systemctl enable docker
```
