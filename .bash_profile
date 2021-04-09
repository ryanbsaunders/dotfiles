# set up bash
export EDITOR=/usr/bin/vim # set the default editor to vim

# manage path
export PATH="/usr/local/sbin:$PATH"
export GOPATH="$HOME/go/bin"

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

# general aliases
alias lla='ls -la'
alias ll='ls -l'
alias vc='vimcat' # i never use this anymore.  can probably send it to space
alias brup='brew update && brew upgrade && brew upgrade --cask && brew cleanup -s --prune=all' # update, upgrade, and cleanup homebrew packages
alias vundleupdate='vim +BundleUpdate +BundleClean! +qall'  # vundle update
alias powercli='docker run --rm -it --entrypoint='/usr/bin/powershell' vmware/powerclicore' # run vmware powercli
alias pubip='curl https://ifconfig.co;echo -n' # show our current public ip
alias vbm='VBoxManage' # virtalbox manager
alias grep='grep --color=auto' # colorize grep output
alias ip='ip -color' # colorize ip output
alias cdt='cd $(git rev-parse --show-toplevel)' # change directory to the top of the current git repo
alias wx='curl https://wttr.in' # print the weather

# github aliases
alias gsb='git show-branch'
alias gco='git checkout'
alias gpo='git push origin'
alias gcl='git clone'
alias grh='git reset --hard'
alias gpr='git pull-request -o'
alias gci='git ci-status -v'
alias gcist='~/bin/hub_ci_status.sh'
alias gst='git status'
alias gpl='git pull'
alias gdf='git diff'
alias gcam='git commit -am'
alias gcm='git commit -m'

# vagrant aliases
alias vs='vagrant ssh'
alias vd='vagrant destroy --force'
alias vr='vagrant reload'
alias vu='vagrant up'
alias vh='vagrant halt'
alias vp='vagrant provision'
alias vst='vagrant status'
alias vbu='vagrant box update'

# set up hub if it is installed
# https://github.com/github/hub
if command -v hub &> /dev/null; then
  # set gitgub Hub alias
  eval "$(hub alias -s)" 

  # use hub with github enterprise on a custom domain
  # read custom ghe name from .bashsecrets
  function ghe() {
    GITHUB_HOST=$GITHUB_ENTERPRISE_DOMAIN hub $*
    }

    function ghe-setup() {
      git config --add hub.host $GITHUB_ENTERPRISE_DOMAIN
  }
fi

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

# load homebrew gnubin path
if command -v brew &> /dev/null; then
  PATH="/usr/local/opt/findutils/libexec/gnubin:$PATH"
  export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
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

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
