# Any zsh-specific things should go in here!
autoload -Uz compinit
fpath=(~/scripts/autocompletion $fpath)
fpath=(${(u)fpath})  # remove duplicate directories, changes between non-login & login shells for some reason

# Check if the cache file is newer than 24 hours
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=3000
SAVEHIST=3000
# End of lines configured by zsh-newuser-install

# show git branch in prompt
autoload -Uz vcs_info
precmd() {
   if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      vcs_info
   else
      vcs_info_msg_0_=""
   fi

   if [[ -n ${__shell_started_at:-} ]]; then
      printf '[startup to prompt %.0f ms]\n' \
         "$(((EPOCHREALTIME - __shell_started_at) * 1000))" >&2
      unset __shell_started_at
   fi
}

zstyle ':vcs_info:git:*' formats '%b '

# prompt
setopt PROMPT_SUBST
PROMPT='%F{green}[%T]%f %n@%m %F{blue}%~%f %F{red}${vcs_info_msg_0_}%f$ '

# history
setopt INC_APPEND_HISTORY # append commands to history as soon as they are entered
setopt HIST_SAVE_NO_DUPS # do not include duplicates in the history
setopt SHARE_HISTORY # share history between zsh

# make ctrl-r reverse search work
bindkey -e

# allow ctrl X + ctrl E to edit line in kitty
autoload edit-command-line; zle -N edit-command-line
bindkey "^Xe" edit-command-line

## work needs to source first, since it sets MISE_ENV=work before mise initializes in ~/scripts/general.sh
[[ -f ~/work/work.sh ]] && source ~/work/work.sh
source ~/scripts/general.sh

