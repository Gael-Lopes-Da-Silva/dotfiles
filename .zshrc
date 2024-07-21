# install znap
ZNAP_HOME="$HOME/.local/share/zsh/snap"
[[ -r "$ZNAP_HOME/znap.zsh" ]] || git clone https://github.com/marlonrichert/zsh-snap "$ZNAP_HOME"
source "$ZNAP_HOME/znap.zsh"

# install plugins
znap source "marlonrichert/zsh-edit"
znap source "zsh-users/zsh-syntax-highlighting"
znap source "zsh-users/zsh-autosuggestions"

znap install "zsh-users/zsh-completions"

# plugins config
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# user config
setopt AUTOCD
setopt INTERACTIVE_COMMENTS
setopt SHARE_HISTORY

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
ZLE_RPROMPT_INDENT=0

PROMPT="%B{%F{blue}%3~%f}%b "
RPROMPT="%B%F{black}%!%f%b"

alias ls="ls -h -X --color --group-directories-first --hyperlink"
alias ll="ls -lh -X --color --group-directories-first --hyperlink"
alias la="ls -lh -AX --color --group-directories-first --hyperlink"

alias vim="nvim"
