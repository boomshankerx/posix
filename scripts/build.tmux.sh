#!/usr/bin/env bash

apt install wget tar libevent-dev libncurses-dev
VERSION=2.7 
mkdir ~/tmux-src && wget -qO- https://github.com/tmux/tmux/releases/download/${VERSION}/tmux-${VERSION}.tar.gz | tar xvz -C ~/tmux-src && cd ~/tmux-src/tmux*
./configure && make -j"$(nproc)" && sudo make install
cd && rm -rf ~/tmux-src
tmux -V
