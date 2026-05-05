# Source antidote.
[[ -e ${ZDOTDIR:-$HOME}/.antidote ]] ||
  git clone https://github.com/mattmc3/antidote.git ${ZDOTDIR:-$HOME}/.antidote
source ${ZDOTDIR:-$HOME}/.antidote/antidote.zsh
source <(antidote init)

antidote bundle getantidote/use-omz
antidote bundle zsh-users/zsh-autosuggestions
antidote bundle MichaelAquilina/zsh-you-should-use
antidote bundle spaceship-prompt/spaceship-prompt
# Keep this last
antidote bundle zsh-users/zsh-syntax-highlighting
