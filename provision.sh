#! /usr/bin/env bash

sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm base-devel clang boost git protobuf jsoncpp go vim zsh

git clone https://github.com/scrosby/OSM-binary
cd OSM-binary
make -C src
sudo make -C src install

cat <<'HERE' | sudo tee -a /etc/pacman.conf

[archlinuxfr]
SigLevel = Never
Server = http://repo.archlinux.fr/$arch
HERE

sudo pacman -Sy --noconfirm yaourt 
yaourt -S --noconfirm aur/poco aur/folly-git

echo <<'HERE' | tee -a $HOME/.bash_profile
export GOPATH=$HOME/.gocode
export EDITOR=vim
HERE

go get github.com/lib/pq
