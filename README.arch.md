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

[user@PC-NAME]$ sudo pacman -Sy base-devel git zsh wget
```

```
[user@PC-NAME]$ git clone https://aur.archlinux.org/yay.git

[user@PC-NAME]$ cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay

```
