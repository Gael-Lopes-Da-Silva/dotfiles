#
# Install znap:
#
ZNAP_HOME="$HOME/.local/share/zsh/snap"
[[ -r "$ZNAP_HOME/znap.zsh" ]] || git clone https://github.com/marlonrichert/zsh-snap "$ZNAP_HOME"
source "$ZNAP_HOME/znap.zsh"

#
# User config:
#
source "$HOME/.config/zsh/.zplugins"
source "$HOME/.config/zsh/.zexports"
source "$HOME/.config/zsh/.zoptions"
source "$HOME/.config/zsh/.zaliases"
source "$HOME/.config/zsh/.zprompt"
