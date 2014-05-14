#!/bin/sh

basedir=`dirname $0`

function make_link {
    ln -sv "$basedir/$1" "$HOME/.$1"
}

make_link "bash_profile"
make_link "hgrc"
make_link "vimrc"
make_link "vim"
