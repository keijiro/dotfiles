if [ -d ~/.local/bin ]; then
    export PATH=$PATH:~/.local/bin
fi

if [ -d ~/Library/Python/2.7/bin ]; then
    export PATH=$PATH:~/Library/Python/2.7/bin
fi

export EDITOR=vim
set -o vi

if [ `uname` == "Linux" ] && grep -i -q "microsoft" /proc/version; then
    alias open="powershell.exe -Command Start-Process"
fi
