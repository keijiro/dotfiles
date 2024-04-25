# PATH directories
export PATH="$PATH:~/.dotfiles/bin"
[ -d /opt/homebrew/bin ] && export PATH="$PATH:/opt/homebrew/bin"
[ -d /snap/bin         ] && export PATH="$PATH:/snap/bin"
[ -d ~/.local/bin      ] && export PATH="$PATH:~/.local/bin"

# Antidote initialization
BREW_ANTIDOTE=/opt/homebrew/opt/antidote/share/antidote/antidote.zsh
if [ -d ~/.antidote ]; then
    source ~/.antidote/antidote.zsh
    antidote load
elif [ -e $BREW_ANTIDOTE ]; then
    source $BREW_ANTIDOTE
    antidote load
fi

# Starship
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# fzf
if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
    echo hoge
elif [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
fi

# Prefer Vim
export EDITOR=nvim
bindkey -v

# Misc aliasese
alias ls="ls --color -F"

# WSL options
if [ `uname` = "Linux" ] && grep -i -q "microsoft" /proc/version; then
    alias open="powershell.exe -Command Start-Process"
fi
