# Any zsh-specific things should go in here!
autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
# End of lines configured by zsh-newuser-install

# show git branch in prompt
autoload -Uz vcs_info
precmd() { vcs_info }

zstyle ':vcs_info:git:*' formats '%b '

# prompt
setopt PROMPT_SUBST
PROMPT='%F{green}[%T]%f %n@%m %F{blue}%~%f %F{red}${vcs_info_msg_0_}%f$ '

# make ctrl-r reverse search work
bindkey -e

# allow ctrl X + ctrl E to edit line in kitty
autoload edit-command-line; zle -N edit-command-line
bindkey "^Xe" edit-command-line

source ~/scripts/general.sh
source ~/work/work.sh

