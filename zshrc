export EDITOR=vim
export PATH="/opt/homebrew/bin:$PATH"

bindkey -v
bindkey "^R" history-incremental-search-backward

alias ls="ls --color -F"

eval "$(starship init zsh)"

source /opt/homebrew/share/zsh-abbr/zsh-abbr.zsh
