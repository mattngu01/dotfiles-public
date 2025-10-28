#!/bin/bash

# Python
alias sv='python3 -m venv venv'
alias cv='source venv/bin/activate'
alias deac='deactivate'

# Docker / K8s
alias ddebug='docker run --rm -it --entrypoint /bin/bash'
alias k='kubectl'
alias ku='kubectl kustomize'
alias yless='jless --yaml'
alias kdebug-pod='kubectl run mattn-debugpod --image="nicolaka/netshoot" -i --tty --rm'
alias kdebug-container='kubectl debug -it --image="nicolaka/netshoot" --container="mattn-debugcontainer"'

# Terraform
alias tf='terraform'
alias tfplanlog='tf plan -out tf.plan -no-color | tee plan.log'

# General / Misc / Random
alias zsrc='source ~/.zshrc'
alias kssh='kitten ssh'
alias g='git'

# disable interactive mode for kubectx
export KUBECTX_IGNORE_FZF=1
export EDITOR=vim

# allow ctrl X + ctrl E to edit line in kitty
autoload edit-command-line; zle -N edit-command-line
bindkey "^Xe" edit-command-line

eval "$(zoxide init zsh)"
eval "$(mise activate zsh)"

random_uuid() {
	uuidgen | awk '{print tolower($0)}'
}
