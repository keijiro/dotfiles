export EDITOR=nvim
export PATH="/opt/homebrew/bin:$PATH"

bindkey -v

alias ls="ls --color -F"

eval "$(starship init zsh)"
eval "$(fzf --zsh)"

source /opt/homebrew/share/zsh-abbr/zsh-abbr.zsh
source /opt/homebrew/etc/profile.d/z.sh
