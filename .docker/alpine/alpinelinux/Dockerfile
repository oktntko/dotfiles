FROM alpine:3.17.2

RUN apk update && apk upgrade && apk add bash shadow

RUN apk add sudo tzdata \
    # タイムゾーンの設定のため
    && ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

ARG WORK_USER
ARG WORK_GROUP
ARG WORK_UID
ARG WORK_GID

RUN groupadd --gid $WORK_GID $WORK_GROUP \
    && useradd --gid $WORK_GID --groups root --uid $WORK_UID --create-home --shell /bin/bash $WORK_USER \
    && echo $WORK_USER:$WORK_USER | chpasswd \
    && echo "$WORK_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER $WORK_USER
WORKDIR /home/$WORK_USER/

# How to setup
RUN sudo apk add \
    # ディストリビューションの確認のため
    lsb-release \
    # Homebrew on Linux
    build-base curl file git procps \
    # Basic tools
    curl wget git zip unzip vim zsh

# asdf-python (https://github.com/asdf-community/asdf-python/issues/119)
RUN sudo apk add openssl-dev bzip2-dev ncurses-dev libffi-dev readline-dev sqlite-dev tk-dev xz-dev
# asdf-node (https://github.com/asdf-vm/asdf-nodejs/issues/281)
