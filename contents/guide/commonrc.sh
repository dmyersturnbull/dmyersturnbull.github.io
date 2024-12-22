
###################################################################################################
#                                   Set environment variables
###################################################################################################
export JAVA_HOME=/opt/jdk22

export PATH
PATH="$PATH:/usr/sbin:/usr/local/sbin:$HOME/bin:$JAVA_HOME/bin"



###################################################################################################
#                                            Self-aliases
###################################################################################################

# allows user aliases to be used as SU
# https://unix.stackexchange.com/a/349290
#alias sudo='sudo '
alias sudo-e='sudo -E '

# Prevent `chown -R xx . /`.
# The same goes for chmod and chgrp
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# These are colorful/nice variants of commands
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'


###################################################################################################
#                                          Aliases for processes, ports, etc.
###################################################################################################

# This will show open ports in a compact form
ports() {
  netstat \
    --tcp \
    --udp \
    --listening \
    --numeric \
    --programs
  return $?
}

strain() {
  vmstat --active
  return $?
}

memory() {
  free --human
  return $?
}

# List open file handles for this shell
file-handles() {
  ls \
    --long \
    --all \
    /proc/$$/fd
  return $?
}

thread-io() {
  sudo iotop \
    --only \
    --batch \
    --iter 1
  return $?
}

process-io() {
  sudo iotop \
    --only \
    --batch \
    --iter 1 \
    --processes
  return $?
}

resolve-dns() {
  resolvectl dns
  return $?
}

threads() {
  ps \
    --all \
    --full \
    --long \
    --threads \
    --sort=y \
    --headers
  return $?
}

sockets() {
  sudo ss \
    --listening \
    --processes
  return $?
}

tcp-sockets() {
  sudo ss \
    --listening \
    --processes \
    --tcp
  return $?
}

udp-sockets() {
  sudo ss \
    --listening \
    --processes \
    --udp
  return $?
}

# Also remember 'dig' and 'lsof'

# like ls
ez() {
  eza \
    --all \
    --sort=name \
    --group-directories-first \
    --icons \
    --created \
    --modified \
    --git \
    "$@"
  return $?
}

# like ls -l
el() {
  eza \
    --all \
    --sort=name \
    --group-directories-first \
    --icons \
    --git \
    --long \
    "$@"
  return $?
}

# shows more
eel() {
  eza \
    --header \
    --all \
    --sort=name \
    --group-directories-first \
    --icons \
    --created \
    --modified \
    --git \
    --long \
    --octal-permissions \
    "$@"
  return $?
}

# prints in a grid
eeg() {
  eza \
    --header \
    --all \
    --sort=name \
    --group-directories-first \
    --icons \
    --created \
    --modified \
    --git \
    --long \
    --grid \
    "$@"
  return $?
}

# emphasizes permissions
# to show ONLY octal permissions, add --no-permissions
eep() {
  eza \
    --all \
    --sort=name \
    --group-directories-first \
    --long \
    --grid \
    --no-time \
    --smart-group \
    --octal-permissions \
    "$@"
  return $?
}

git-root() {
  git rev-parse --show-toplevel
  return $?
}



###################################################################################################
#                                        Convenience utils
###################################################################################################

# These are nice as navigation shorthands
alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../'

# 'cd', but make it if it doesn't exist
cdd() {
  mkdir "$1" || return $?
  cd "$1" || return $?
}
cdd..() {
  mkdir "../$1" || return $?
  cd "../$1" || return $?
}

# Run chown recursively
grab() {
  sudo "$SHELL" -c chown -R "$USER:$USER" "${1:-.}" || return $?
}

# Replacement for 'cp' that is secretly rsync
copy() {
  rsync \
    --preserve-permissions \
    --owner \
    --group \
    --backup \
    --relative \
    --human-readable \
    --human-readable \
    --progress \
    || return $?
}

# Extract any archive type
# Modified from https://serverfault.com/questions/3743/what-useful-things-can-one-add-to-ones-bashrc
extract() {
  if (( $# != 1 )); then
    >&2 echo "Usage: extract <archive-file>"
    return 2
  fi
  if [[ ! -f "$1" ]]; then
    >&2 echo "'$1' is not a file or does not exist"
    return 1
  fi
  case "$1" in
    *.tar.bz2)   tar xvjf "$1"   ; return $? ;;
    *.tar.gz)    tar xvzf "$1"   ; return $? ;;
    *.bz2)       bunzip2 "$1"    ; return $? ;;
    *.rar)       unrar x "$1"    ; return $? ;;
    *.gz)        gunzip "$1"     ; return $? ;;
    *.tar)       tar xvf "$1"    ; return $? ;;
    *.tbz2)      tar xvjf "$1"   ; return $? ;;
    *.tgz)       tar xvzf "$1"   ; return $? ;;
    *.zip)       unzip "$1".     ; return $? ;;
    *.Z)         uncompress "$1" ; return $? ;;
    *.snappy)    snunzip "$1"    ; return $? ;;
    *.sz)        snunzip "$1"    ; return $? ;;
    *.br)        brotli -d "$1"  ; return $? ;;
    *.xz)        unxz "$1"       ; return $? ;;
    *.lz4)       unlz4 "$1"      ; return $? ;;
    *.lzma)      unlzma  "$1"    ; return $? ;;
    *.zst)       unzstd "$1"     ; return $? ;;
    *.7z)        7z x "$1"       ; return $? ;;
    *)           >&2 echo "Unknown format: $1" ; return 1 ;;
  esac
}


###################################################################################################
#                                                Git utils
###################################################################################################

set_up_git_aliases() {

  # 'stat' alias -- Show working tree status in short format with branch info
  # Arguments:
  #   status                 # Show the working tree status
  #   --short                # Output in the short-format
  #   --branch               # Show branch information
  git config \
    --global \
    alias.stat \
    '
    status
      --short
      --branch
    '

  # 'lg' alias -- Show commit logs in a condensed single line per commit
  # Arguments:
  #   --oneline             # Condense each commit to a single line
  git config \
    --global \
    alias.lg \
    '
    log
      --oneline
    '

  # 'graph' alias -- Show commit logs with an ASCII graph of branch and merge history
  # Arguments:
  #   --graph               # Display an ASCII graph of the branch and merge history
  git config \
    --global \
    alias.graph \
    '
    log
      --graph
    '

  # 'long-graph' alias -- Show commit logs with cumulative counts, compact summary, and ASCII graph
  # Arguments:
  #   --graph               # Display an ASCII graph of the branch and merge history
  #   --compact-summary     # Display a compact summary of the commit log
  #   --cumulative          # Display cumulative commit counts
  git config \
    --global \
    alias.long-graph \
    '
    log
      --graph
      --compact-summary
      --cumulative
    '

  # 'log-diff' alias -- Show commit logs with full diff and various diff options
  # Arguments:
  #   --full-diff                  # Display full diff
  #   --unified=1                  # Show diff with one line of context
  #   --color=always               # Always show colored diff
  #   --ignore-blank-lines         # Ignore changes whose lines are all blank
  #   --ignore-space-at-eol        # Ignore changes in whitespace at EOL
  #   --diff-algorithm=histogram   # Use histogram diff algorithm
  #   --find-renames=50            # Detect renames with a threshold of 50%
  #   --find-copies=50             # Detect copies with a threshold of 50%
  #   --color-moved=zebra          # Highlight moved lines in a "zebra" pattern
  #   --color-moved-ws             # Highlight moved whitespace
  git config \
    --global \
    alias.log-diff \
    '
    log
      --full-diff
      --unified=1
      --color=always
      --ignore-blank-lines
      --ignore-space-at-eol
      --diff-algorithm=histogram
      --find-renames=50
      --find-copies=50
      --color-moved=zebra
      --color-moved-ws
    '

}

# Run the setup function if git is available
if command -v git >/dev/null 2>&1; then
  set_up_git_aliases # don't exit on error
else
  >&2 echo "Git is not installed or not found in PATH"
fi


###################################################################################################
#                                                Misc utils
###################################################################################################

# Function to search for T/O/D/O comments (without the /)
find-todos() {
  local _directory=.
  local _files='*.*'
  local _todo=TODO

  # Parse optional parameters using a while loop
  while (( $# > 0 )); do
    case "$1" in
      --files) _files="$1" ; shift 2 ;;
      --dir)   _dir="$1"   ; shift 2 ;;
      --todo)  _todo="$1"  ; shift 2 ;;
      --)      shift       ; break   ;;
      *)       >&2 echo "Unknown arg $1" ; return 1 ;;
    esac
  done

  # Start the Markdown table
  # https://stackoverflow.com/questions/4409399/padding-characters-in-printf
  local fmt='%-20s | %-4s | %-90s\n'
  # shellcheck disable=SC2059
  printf '%s%s | %s | %s |\n' \
    "$( printf "$fmt" File Line Comment )" \
    "$( printf '%0.1s' "-"{1..20} )" \
    "----" \
    "$( printf '%0.1s' "-"{1..90} )"

  # Grep to find T/O/D/O comments
  grep \
    --binary-files=without-match \
    --recursive \
    --line-number \
    --include="$_files" \
    "$_todo" \
    "$_directory" \
    | awk -F':' -v fmt="$fmt" '
      {
        # Extract filename, line number, and comment
        comment = substr($0, index($0, $3));
        sub(/^[ \t]*TODO[:]?[ \t]*/, "", comment);
        printf fmt, $1, $2, comment;
      }
  '
  exit $?
}

update-system() {
  # assume arguments like --quiet and --yes are being delegated
  sudo apt update "$@" || return $?
  sudo apt upgrade "$@" || return $?
  sudo apt dist-upgrade "$@" || return $?
  sudo snap refresh || return $?
}
