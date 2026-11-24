# PATH directories
export PATH="$PATH:$HOME/.dotfiles/bin"
[ -d /opt/homebrew/bin  ] && export PATH="$PATH:/opt/homebrew/bin"
[ -d /snap/bin          ] && export PATH="$PATH:/snap/bin"
[ -d "$HOME/.local/bin" ] && export PATH="$PATH:$HOME/.local/bin"

source "$HOME/.dotfiles/unity-android.zsh"

if command -v brew >/dev/null 2>&1; then
    RUSTUP_PREFIX="$(brew --prefix --installed rustup 2>/dev/null)" &&
        export PATH="$PATH:$RUSTUP_PREFIX/bin"
    unset RUSTUP_PREFIX
fi

# Prefer Vim
export EDITOR=nvim
bindkey -v

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
elif [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
fi

# Misc aliasese
alias ls="ls --color -F"

# History
HISTFILE=~/.zsh_history
HISTSIZE=2000
SAVEHIST=1000

# WSL options
if command -v powershell.exe >/dev/null 2>&1; then
    alias open="powershell.exe -Command Start-Process"
fi

# Unity CLI
[ -f "$HOME/.unity/env" ] && . "$HOME/.unity/env"
[ -d "$HOME/.upm/bin" ] && export PATH="$HOME/.upm/bin:$PATH"
