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
PROMPT_COMMAND="history -a;$PROMPT_COMMAND" #append history immediately
export HISTFILESIZE= #'umlimited' bash history
export HISTSIZE= #'unlimited' bash history

# prompt
export PS1="\[\e[38;5;048m\]\A\[\e[m\]: \[\e[38;5;208m\]\u\[\e[m\]@\W >  "

# general aliases
alias brup='brew update && brew upgrade && brew cleanup -s' #update, upgrade, and cleanup homebrew packages
alias lla='ls -la'
alias ll='ls -l'
alias vc='vimcat' #i never use this anymore.  can probably send it to space
alias vundleupdate='vim +BundleUpdate +BundleClean! +qall'  # vundle update
alias powercli='docker run --rm -it --entrypoint='/usr/bin/powershell' vmware/powerclicore' #run vmware powercli
alias pubip='curl https://ifconfig.co;echo -n' #show our current public ip
alias vbm='VBoxManage' #virtalbox manager

# github aliases
alias gsb='git show-branch'
alias gco='git checkout'
alias gpo='git push origin'
alias gcl='git clone'
alias grh='git reset --hard'
alias gpr='git pull-request -o'
alias gci='git ci-status -v'
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

# grep
alias grep='grep --color=auto' #colorize grep output

# set up rbenv
eval "$(rbenv init -)"

# on osx, put curl-openssl in path
export PATH="/usr/local/opt/curl-openssl/bin:$PATH"
export PATH="/usr/local/opt/openssl/bin:$PATH"
