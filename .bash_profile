export EDITOR=/usr/bin/vim # set the default editor to vim

# set up homebrew path. This line is what puts brew ON the PATH, so the guard
# has to test the binary by path -- `type brew` is necessarily false this early
# and would stop brew from ever being bootstrapped. Skips cleanly on Linux.
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

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

# shared interactive config, also sourced by ~/.bashrc on Linux dev hosts
[ -r ~/.shrc.common ] && . ~/.shrc.common

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

# 1Password service-account token for the `op` CLI. This block previously
# lived only in ~/.zshrc, which this login shell (bash) never reads — so `op`
# silently had no token and every command needed a manual export.
#
# Must stay ABOVE the tmux block below: that block `exec`s, replacing the
# shell, so anything placed after it never runs on first login.
if [ -f ~/.config/op/service-account-token ]; then
  export OP_SERVICE_ACCOUNT_TOKEN=$(tr -d '\n' < ~/.config/op/service-account-token)
fi

# auto-attach to (or create) a default tmux session for interactive
# shells outside an existing tmux. -t 1 keeps non-interactive shells
# (scripts, scp, etc.) from getting hijacked.
if [ -z "$TMUX" ] && [ -t 1 ] && command -v tmux >/dev/null 2>&1; then
  exec tmux new-session -A -s main
fi
