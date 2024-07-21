# install znap
ZNAP_HOME="$HOME/.local/share/zsh/snap"
[[ -r "$ZNAP_HOME/znap.zsh" ]] || git clone https://github.com/marlonrichert/zsh-snap "$ZNAP_HOME"
source "$ZNAP_HOME/znap.zsh"

# user config
source "$HOME/.zplugins"
source "$HOME/.zexports"
source "$HOME/.zoptions"
source "$HOME/.zaliases"
source "$HOME/.zprompt"
