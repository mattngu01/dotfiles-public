#!/bin/bash

# anything related to tooling, aliases, and not affecting zsh behavior goes here

# keep this first, may link tools that are used in later things
eval "$(mise activate zsh)"

# Python
alias sv='python3 -m venv .venv'
alias cv='source .venv/bin/activate'
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
alias n='nvim'

# AWS
alias chooseawslogin='aws sso login --profile $(aws configure list-profiles | sort | fzf)'

# disable interactive mode for kubectx
export KUBECTX_IGNORE_FZF=1
export EDITOR=vim

eval "$(zoxide init zsh)"

# github cli autocomplete
eval "$(gh completion -s zsh)"

random_uuid() {
	uuidgen | awk '{print tolower($0)}'
}
