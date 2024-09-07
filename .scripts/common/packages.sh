#!/bin/sh

PKG="stow neovim lazygit zsh noto cascadia-code feh firefox"

pkg install -y $PKG

chsh -s /usr/local/bin/zsh gael
