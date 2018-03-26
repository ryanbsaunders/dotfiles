# Load SSH Keys
ssh-add -K ~/.ssh/keys/*

# Source bash secrets
[[ -f ~/.bashrc.secrets ]] && . ~/.bashrc.secrets

# less shitty prompt
export PS1="\[\e[38;5;048m\]\A\[\e[m\]: \[\e[38;5;208m\]\u\[\e[m\]@\W >  "

#####ALIASES######
alias brup='brew update && brew upgrade && brew cleanup -s' #Update, Upgrade, and Cleanup Homebrew packages
alias lla='ls -la'
alias ll='ls -l'
alias vc='vimcat'
alias vundleupdate='vim +BundleUpdate +BundleClean! +qall'  # Vundle update
alias powercli='docker run --rm -it --entrypoint='/usr/bin/powershell' vmware/powerclicore'
alias pubip='curl ipecho.net/plain;echo'

# Github Aliases
alias gsb='git show-branch'
alias gco='git checkout'
alias gpo='git push origin'
alias gcl='git clone'
alias grh='git reset --hard'
alias gpr='git pull-request -o'
alias gst='git status'
alias gpl='git pull'
alias gdf='git diff'
alias gcam='git commit -am'
alias gcm='git commit -m'

# Vagrant Aliases
alias vs='vagrant ssh'
alias vd='vagrant destroy --force'
alias vr='vagrant reload'
alias vu='vagrant up'
alias vh='vagrant halt'
alias vp='vagrant provision'
alias vst='vagrant status'
alias vbu='vagrant box update'

# VirtualBox
alias vbm='VBoxManage'

# $dayjob alises
#alias infv="cd ~/code/cmm/infrastructure/vagrant" #Quickly move to the Vagrant working directory

# Set GitHub Hub Alias
eval "$(hub alias -s)" 

# Use Hub with GitHub Enterprise
function ghe() {
  GITHUB_HOST=$GITHUB_ENTERPRISE_DOMAIN git $*
  }

  function ghe-setup() {
    git config --add hub.host $GITHUB_ENTERPRISE_DOMAIN
}

# Manage Path
export PATH="/usr/local/sbin:$PATH"
export GOPATH="$HOME/go/bin"

# Set Ansible config
# export ANSIBLE_CONFIG="~/.ansible.cfg"

# Set the default editor to Vim
export EDITOR=/usr/bin/vim

# Grep color
alias grep='grep --color=auto'

# Set up rbenv
eval "$(rbenv init -)"
export PATH="$HOME/.rbenv/bin:$PATH"
