if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

if [ -d ~/.local/bin ]; then
    export PATH=$PATH:~/.local/bin
fi

if [ `uname` != "Darwin" ]; then
    if grep -q Microsoft /proc/version; then
        alias wffmpeg=/mnt/c/ProgramData/chocolatey/bin/ffmpeg.exe
        alias wffplay=/mnt/c/ProgramData/chocolatey/bin/ffplay.exe
        alias w7z=/mnt/c/ProgramData/chocolatey/lib/7zip.portable/tools/7z.exe
    fi
fi

export EDITOR=vim
set -o vi
