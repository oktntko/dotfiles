FROM amazonlinux:2023

RUN dnf update -y

RUN dnf install -y sudo tzdata \
    # タイムゾーンの設定のため
    && ln --symbolic --force /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    # ロケールの設定のため
    && dnf install -y langpacks-en \
    # groupadd, useradd, chpasswd chsh のため
    shadow-utils util-linux-user

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

# How to setup
# Homebrew on Linux
# https://bugs.launchpad.net/tripleo/+bug/1953156 (The curl installation conflicts with curl-minimal package.)
RUN sudo dnf groupinstall -y 'Development Tools' && sudo dnf install -y --allowerasing procps-ng curl file git \
    # Basic tools
    curl git vim wget zsh

# asdf-python
RUN sudo dnf install -y openssl-devel bzip2-devel ncurses-devel libffi-devel readline-devel sqlite-devel
