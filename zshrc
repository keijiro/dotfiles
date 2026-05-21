# PATH directories
export PATH="$PATH:$HOME/.dotfiles/bin"
[ -d /opt/homebrew/bin ] && export PATH="$PATH:/opt/homebrew/bin"
[ -d /snap/bin         ] && export PATH="$PATH:/snap/bin"
[ -d ~/.local/bin      ] && export PATH="$PATH:$HOME/.local/bin"
source "$HOME/.dotfiles/unity-android.zsh"

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
alias u='HUB_DISABLE_DETACHED=1 unity'

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
