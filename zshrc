# PATH directories
export PATH="$PATH:~/.dotfiles/bin"
[ -d /opt/homebrew/bin ] && export PATH="$PATH:/opt/homebrew/bin"
[ -d /snap/bin         ] && export PATH="$PATH:/snap/bin"
[ -d ~/.local/bin      ] && export PATH="$PATH:~/.local/bin"

# Antidote initialization
source ~/.antidote/antidote.zsh
antidote load

# zsh plugins
eval "$(starship init zsh)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Prefer Vim
export EDITOR=nvim
bindkey -v

# Misc aliasese
alias ls="ls --color -F"

# WSL options
if [ `uname` = "Linux" ] && grep -i -q "microsoft" /proc/version; then
    alias open="powershell.exe -Command Start-Process"
fi
