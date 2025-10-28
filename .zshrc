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

# Python
alias cv='python -m venv venv'
alias sv='source venv/bin/activate'
alias deac='deactivate'

# Docker
alias ddebug='docker run --rm -it --entrypoint /bin/bash'

# Run things
fastfetch

source ~/scripts/general.sh


