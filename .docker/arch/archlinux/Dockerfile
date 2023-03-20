FROM archlinux:latest

RUN pacman -Syu --noconfirm

RUN pacman -S --noconfirm sudo \
    # タイムゾーンの設定のため
    tzdata && ln --symbolic --force /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

ARG WORK_USER
ARG WORK_GROUP
ARG WORK_UID
ARG WORK_GID

RUN groupadd --gid $WORK_GID $WORK_GROUP \
    && useradd --gid $WORK_GID --groups wheel --uid $WORK_UID --create-home --shell /bin/bash $WORK_USER \
    && echo $WORK_USER:$WORK_USER | chpasswd \
    && echo "$WORK_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/wheel

USER $WORK_USER
WORKDIR /home/$WORK_USER/

# How to setup
RUN sudo pacman -S --noconfirm \
    # ディストリビューションの確認のため
    lsb-release \
    # Homebrew on Linux
    base-devel curl file git procps \
    # Basic tools
    curl git vim wget zsh

COPY ../../../install.zsh ./

RUN zsh install.zsh && rm install.zsh
