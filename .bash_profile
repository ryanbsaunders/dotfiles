export EDITOR=/usr/bin/vim # set the default editor to vim

#set up homebrew path
#if type brew &>/dev/null; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
#fi

# set up bash completion
[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"

if type brew &>/dev/null
then
  HOMEBREW_PREFIX="$(brew --prefix)"
  if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]
  then
    source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
  else
    for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*
    do
      [[ -r "${COMPLETION}" ]] && source "${COMPLETION}"
    done
  fi
fi

# add Go binaries to PATH if Go is installed
if command -v go &> /dev/null; then
  export PATH="$PATH:$(go env GOPATH)/bin"
fi

# source bash secrets
[[ -f ~/.bashrc.secrets ]] && . ~/.bashrc.secrets

# set up bash history
HISTTIMEFORMAT="%Y/%m/%d %T " # set timestamps on history
shopt -s histappend # append history immediately
PROMPT_COMMAND="history -a;$PROMPT_COMMAND" # append history immediately
export HISTFILESIZE= # 'umlimited' bash history
export HISTSIZE= # 'unlimited' bash history

# prompt
export PS1="\[\e[38;5;048m\]\A\[\e[m\]: \[\e[38;5;208m\]\u\[\e[m\]@\W >  "

# colorize output
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# general aliases
alias lla='ls -la'
alias ll='ls -l'
alias brup='brew update && brew upgrade && brew upgrade --cask && brew cleanup -s --prune=all' # update, upgrade, and cleanup homebrew packages
alias vimplugupdate='vim +PlugUpgrade +PlugUpdate +PlugClean! +qall'  # vim-plug self-upgrade, plugin update + clean
alias powercli='docker run --rm -it --entrypoint='/usr/bin/powershell' vmware/powerclicore' # run vmware powercli
alias pubip='curl https://ifconfig.co;echo -n' # show our current public ip
alias grep='grep --color=auto' # colorize grep output
alias ip='ip -color' # colorize ip output
alias cdt='cd $(git rev-parse --show-toplevel)' # change directory to the top of the current git repo
alias wx='curl https://wttr.in' # print the weather
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
alias digs="dig +short"

# github aliases
alias gsb='git show-branch'
alias gco='git checkout'
alias gpo='git push origin'
alias gcl='git clone'
alias grh='git reset --hard'
alias gpr='gh pr create'
alias gci='gh pr checks'
alias gst='git status'
alias gpl='git pull'
alias gdf='git diff'
alias gcam='git commit -am'
alias gcm='git commit -m'

# terraform aliases
alias tfv='terraform validate'
alias tfp='terraform plan'
alias tfi='terraform init'

# remove old ssh host key
function rmssh() {
  ssh-keygen -R $1
}

# show umask for given file
function numask() {
  find $1 -maxdepth 1 -printf "%m:%f\n"
 }

# set up rbenv
if command -v rbenv &> /dev/null; then
  eval "$(rbenv init -)"
fi

# silence macos zsh warning
if [ "$(uname)" == "Darwin" ]; then
  export BASH_SILENCE_DEPRECATION_WARNING=1
fi

# set up fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# set up pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# set up pyenv
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# optional homebrew formula paths (only prepend if installed)
for _hb_path in \
  "${HOMEBREW_PREFIX}/opt/openssl@3/bin" \
  "${HOMEBREW_PREFIX}/opt/findutils/libexec/gnubin"; do
  [ -d "$_hb_path" ] && export PATH="$_hb_path:$PATH"
done
unset _hb_path

# set tmux window name for git repos
if [ -n "$TMUX" ]; then
  function getCustomWindowName() {
    if git rev-parse --git-dir &> /dev/null; then
       tmux rename-window $(basename `git rev-parse --show-toplevel`);
    else
      tmux setw automatic-rename
      #tmux rename-window $(basename "$PWD")
    fi
  }
  # set updated prompt command
  PROMPT_COMMAND="history -a;getCustomWindowName;$PROMPT_COMMAND" # append history immediately
fi

# set the 1password-cli subdomain if using a custom domain
# (only meaningful inside tmux; running `tmux set` without a server
# errors with "no server running")
if [ -n "$TMUX" ] && [ -n "${OP_SUBDOMAIN}" ]; then
  tmux set -g @1password-subdomain "$OP_SUBDOMAIN"
fi

[ -d "${HOMEBREW_PREFIX}/opt/postgresql@15/bin" ] && export PATH="${HOMEBREW_PREFIX}/opt/postgresql@15/bin:$PATH"

# set up path for pipx
export PATH="$PATH:$HOME/.local/bin"

# auto-attach to (or create) a default tmux session for interactive
# shells outside an existing tmux. -t 1 keeps non-interactive shells
# (scripts, scp, etc.) from getting hijacked.
if [ -z "$TMUX" ] && [ -t 1 ] && command -v tmux >/dev/null 2>&1; then
  exec tmux new-session -A -s main
fi
