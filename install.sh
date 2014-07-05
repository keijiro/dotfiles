#!/bin/sh

cd `dirname $0`

basedir=`pwd`

function make_link {
    ln -svf "$basedir/$1" "$HOME/.$1"
}

make_link "bash_profile"
make_link "hgrc"
make_link "vimrc"
make_link "vim"
