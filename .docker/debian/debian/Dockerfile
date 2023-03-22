FROM debian:11.6-slim

RUN apt-get update && apt-get upgrade

RUN apt-get install -y sudo tzdata locales \
    # タイムゾーンの設定のため
    && ln --symbolic --force /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    # ロケールの設定のため
    && sed -i '/en_US.UTF-8/s/^#//g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8

ARG WORK_USER
ARG WORK_GROUP
ARG WORK_UID
ARG WORK_GID

RUN groupadd --gid $WORK_GID $WORK_GROUP \
    && useradd --gid $WORK_GID --groups sudo --uid $WORK_UID --create-home --shell /bin/bash $WORK_USER \
    && echo $WORK_USER:$WORK_USER | chpasswd \
    && echo "$WORK_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER $WORK_USER
WORKDIR /home/$WORK_USER/

# How to setup
RUN sudo apt-get install -y \
    # ディストリビューションの確認のため
    lsb-release \
    # Homebrew on Linux
    build-essential curl file git procps \
    # Basic tools
    curl git vim wget zsh

# asdf-python (https://github.com/asdf-community/asdf-python/issues/119)
RUN sudo apt-get install -y build-essential curl libbz2-dev libffi-dev liblzma-dev libncursesw5-dev libreadline-dev libsqlite3-dev libssl-dev libxml2-dev libxmlsec1-dev llvm make tk-dev wget xz-utils zlib1g-dev
