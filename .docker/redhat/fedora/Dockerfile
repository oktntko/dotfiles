FROM fedora:37

RUN dnf update -y

RUN dnf install -y sudo tzdata \
    # タイムゾーンの設定のため
    && ln --symbolic --force /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    # ロケールの設定のため
    && dnf install -y langpacks-en

ENV LANG en_US.UTF-8

ARG WORK_USER
ARG WORK_GROUP
ARG WORK_UID
ARG WORK_GID

RUN groupadd --gid $WORK_GID $WORK_GROUP \
    && useradd --gid $WORK_GID --groups wheel --uid $WORK_UID --create-home --shell /bin/bash $WORK_USER \
    && echo $WORK_USER:$WORK_USER | chpasswd \
    && echo "$WORK_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER $WORK_USER
WORKDIR /home/$WORK_USER/

# # How to setup
RUN sudo dnf install -y \
    # ディストリビューションの確認のため
    redhat-lsb \
    # Homebrew on Linux
    && sudo dnf groupinstall -y 'Development Tools' && sudo dnf install -y procps-ng curl file git \
    # Basic tools
    curl git vim wget zsh

# asdf-python
RUN sudo dnf install -y openssl-devel bzip2-devel ncurses-devel libffi-devel readline-devel sqlite-devel

COPY ../../../install.zsh ./

RUN zsh install.zsh && rm install.zsh
