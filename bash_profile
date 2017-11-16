if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

if [ -d ~/.local/bin ]; then
    export PATH=$PATH:~/.local/bin
fi

if grep -q Microsoft /proc/version; then
    alias wffmpeg=/mnt/c/ProgramData/chocolatey/bin/ffmpeg.exe
    alias wffplay=/mnt/c/ProgramData/chocolatey/bin/ffplay.exe
fi

export EDITOR=vim
set -o vi
