# macOS setup

A setup guide for programmers, etc., on Windows.

!!! note "See also"
    [Linux setup guide](linux.md) and
    [Windows setup guide](windows.md)

## Initial setup

The obvious: Upgrade macOS, enable FileVault, and remove unneeded Login Items.

Install [Homebrew](https://brew.sh/) and update it: `brew update && brew upgrade`.
Install a few extra Linux utils:

```bash
brew install ssh-copy-id coreutils git bash zsh
```

Install the text editor [Sublime](https://www.sublimetext.com/)
(`brew install --cask sublime-text`).

And a couple of small things:

- Show hidden files: Run `defaults write com.apple.Finder AppleShowAllFiles true`.
  Then run `killall Finder`.
- Show filename extensions: Do this in Finder → Settings → Advanced.
- In Finder, add your home folder to the SideBar. File → add to sidebar.
- Finder → settings → Advanced → Show all filenames.

## SSH, GPG, & GitHub CLI

Install a version of OpenSSL (actually [LibreSSL](https://www.libressl.org/) that will receive updates:
`brew install libressl`.
The OpenSSL version in macOS by default was seriously out-of-date when
[Heartbleed](https://heartbleed.com/) was made public, and took a long time to  get patched.

Also install GPG: `brew install gnupg`.
And the GitHub CLI: `brew install gh`.

## Update command

I like running this to add a `brewing` command:

```bash
echo 'alias brewing="brew update && brew upgrade && brew cleanup; brew doctor"'\
  >> ~/.commonrc
```

From that, you can run `brewing` to update Brew and its packages, and fix problems.

!!! note
    Although Homebrew only recommends running `brew doctor` if there’s a problem, chances are you’ll
    eventually need to run it, so it’s not a bad idea to deal with those issues immediately rather than
    to accumulate a daunting stack of issues to fix simultaneously later.

## Install [Oh My Zsh](https://ohmyz.sh/)

You’ll thank me later. (You’ll need ZSH installed for this to work.)

```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

You should be prompted to change your shell.
If you are not, run

```bash
chsh -s $(which zsh)
```

Make sure it is set by running

```bash
sudo cat /etc/passwd | grep ${USER}
```

You may need to reboot for the change to your login shell to take effect.
You should now have a colorful shell, complete with a plugin for Git.

## `.commonrc` file

To keep the config for ZSH and Bash consistent, add a file called `.commonrc` in your home directory:

```bash
echo 'export PATH=/usr/local/sbin:$PATH\n' > ~/.commonrc
echo 'source ~/.commonrc\n' >> ~/.zshrc
echo 'source ~/.commonrc\n' >> ~/.bashrc
```

From here on, only modify `.commonrc` so that both Bash and ZSH have the same environment.

## Git, SSH, and GPG

**See [this guide](git-ssh-and-gpg.md).**

## Install Java and Rust

First, [Install the Rust toolchain](https://rustup.rs/).

Then, download [JDK 21 from Temurin](https://adoptium.net/temurin/releases/).
Do not use Java 8, java.com, or OpenJDK.
Make sure it’s on your `$PATH` by running `java --version` in a new shell.

## Generate a certificate

If you need a certificate, set a static IP address and generate a certificate with
[certbot](https://certbot.eff.org/). Choose “None of the above” for Software.
Then follow the instructions exactly, including the “Automating renewal” section.
This may not work through some company and university firewalls.

## Sudoers

The easiest way is to run

```bash
su  #(1)!
usermod -aG sudo $USER
```

1. This will require you to enter the root password.

See this [sudoers guide](https://www.cyberciti.biz/faq/how-to-sudo-without-password-on-centos-linux/) for more info.

## Dotfiles

Make a `~/bin` directory and add it to your `$PATH` in `.commonrc`:

```bash
mkdir ~/bin && echo 'export PATH=$HOME/bin:$PATH' >> ~/.commonrc
```

Consider grabbing some Bash scripts from
[awesome-dotfiles](https://github.com/webpro/awesome-dotfiles).
Clone your chosen dotfiles repo into `~/bin`.

I put some aliases and functions directly in `.commonrc`:

```bash
# Set the PATH environment variable to include various directories
export PATH
PATH=/opt/jdk22/bin:$PATH
PATH=/opt/maven-3.9/bin:$PATH
PATH=/opt/idea/bin:$PATH
export JAVA_HOME=/opt/jdk22

# Alias xdg-open to open on macOS for compatibility with scripts
if [[ $OSTYPE == 'darwin'* ]]; then
    alias xdg-open=open
fi

# Safety aliases to prevent accidental recursive operations on the root directory
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# Aliases for grep with color highlighting
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Alias to show open ports in a compact form using ss
# -t: TCP
# -u: UDP
# -l: listening
# -n: numeric
alias ports='ss -tuln'

# Alias to list open file handles for the current shell
# -l: long listing
# -a: all files
alias handles='ls -la /proc/$$/fd'

# Aliases for various system monitoring tools
# --human: human-readable memory usage
alias fre='free --human'
# --active: display active/inactive memory
alias usg='vmstat --active'
# --only: only show processes with I/O
# --batch: run in batch mode
alias iousg='sudo iotop --only --batch'

# Alias to set DNS servers using resolvectl
alias resolvedns='resolvectl dns'

# Alias to list threads of all processes
# -A: all processes
# -f: full format
# -L: threads
# -l: long format
# -y: resident set size
# --headers: repeat header
alias threads='ps -A -f -L -l -y -S --headers'

# Aliases to list sockets with process information
alias lssockets='sudo ss --listening --processes'
alias lstcp='sudo ss --listening --processes --tcp'  # TCP only
alias lsudp='sudo ss --listening --processes --udp'  # UDP only

# Aliases for the exa command, a modern replacement for ls
# --all: all files
# --sort=name: (obvious)
# --group-directories-first: (obvious)
# --icons: show icons
# --created: show creation time
# --modified: show modified time
# --git: show Git status
alias e='exa --all --sort=name --group-directories-first --icons --created --modified --git'
# --long: long format
alias ee='exa --all --sort=name --group-directories-first --icons --created --modified --git --long'
# --grid: grid format
alias eeg='exa --all --sort=name --group-directories-first --icons --created --modified --git --long --grid'

# Aliases for quick directory navigation
alias cd..='cd ..'  # cd ..
alias ..='cd ..'  # cd .. 2 times
alias ...='cd ../../../'  # cd .. 3 times
alias ....='cd ../../../../'  # cd .. 4 times
alias .....='cd ../../../../../'  # cd .. 5 times

# Alias for git pull with fast-forward only
alias ff='git pull -ff-only'

# Git configuration aliases for status and log

# Show short status with branch
git config --global alias.stat 'status --short --branch'
# Show log in one line per commit
git config --global alias.lg 'log --oneline'
# Show log as a graph
git config --global alias.graph 'log --graph'
# Show log graph with compact summary
git config --global alias.graphh 'log --graph --compact-summary'
# Show log graph with cumulative summary
git config --global alias.graphhh 'log --graph --compact-summary --cumulative'
# Show log with detailed diff
git config --global alias.logdiff 'log --full-diff --unified=1 --color=always --ignore-blank-lines --ignore-space-at-eol --diff-algorithm=histogram --find-renames=50 --find-copies=50 --color-moved=zebra --color-moved-ws'

# Function to create a directory and cd into it
cdd() {
    mkdir "$1" && cd "$1"
}

# Function to create the parent directory and cd into it
cdd.() {
    mkdir "../$1" && cd "../$1"
}

# Function to change ownership recursively
grab() {
    sudo chown -R ${USER}:${USER} ${1:-.}
}

# Function to extract various archive formats
extract () {
   if [[ ! -f "$1" ]] ; then
       >&2 echo "'$1' is not a file"
       return 2 # exit status 2: Missing file
   fi
   case "$1" in
       *.gz)        gunzip "$1"      ;;  # Gzip
       *.tar)       tar xvf "$1"     ;;  # TAR
       *.tar.bz2)   tar xvjf "$1"    ;;  # Bzip2-ed tar
       *.tbz2)      tar xvjf "$1"    ;;  # Bzip2-ed tar
       *.tar.gz)    tar xvzf "$1"    ;;  # Gzip-ed tar
       *.tgz)       tar xvzf "$1"    ;;  # Gzip-ed tar
       *.lzma)      unlzma  "$1"     ;;  # LZMA
       *.7z)        7z x "$1"        ;;  # LZMA 7-zip
       *.xz)        unxz "$1"        ;;  # XZ (AKA LZMA2)
       *.zip)       unzip "$1"       ;;  # ZIP
       *.Z)         uncompress "$1"  ;;  # ZIP
       *.bz2)       bunzip2 "$1"     ;;  # Bzip2
       *.rar)       unrar x "$1"     ;;  # RAR (proprietary)
       *.snappy)    snunzip "$1"     ;;  # Snappy
       *.sz)        snunzip "$1"     ;;  # Snappy
       *.br)        brotli -d "$1"   ;;  # Brotli
       *.lz4)       unlz4 "$1"       ;;  # Lempel-Ziv 4
       *.zst)       unzstd "$1"      ;;  # Zstandard
       *)           >&2 echo "I don't know how to extract '$1'"; return 1 ;; # exit status 1: Unknown file type
   esac
}

# Function to search for TODO comments in Java files
findtodos() {
    local directory=$1
    local suffix='*.java'

    # Parse optional parameters
    shift  # Skip the first argument
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --suffix)
                suffix="$2"
                shift 2  # Shift to skip the parameter and its value
                ;;
            --)  # End of all options
                shift
                break
                ;;
            *)  # No more options
                break
                ;;
        esac
    done

    # Start the Markdown table
    echo "| File | Line | Comment |"
    echo "|------|------|---------|"

    # Grep to find TODO comments
    grep -rn --include="$suffix" 'TODO' "$directory" | awk -F':' '
        {
            # Remove "TODO" or "TODO:" from the beginning of the comment
            comment = substr($0, index($0, $3));
            sub(/^[ \t]*TODO[:]?[ \t]*/, "", comment);

            # Print as a Markdown table row
            print "| " $1 " | " $2 " | " comment " |";
        }
    '
}

# Function to update system packages
update() {
    sudo apt update  # Update the package list
    sudo apt upgrade  # Upgrade all installed packages
    sudo apt dist-upgrade  # Perform a distribution upgrade

```

*[LTS]: Long-Term Support
*[UEFI]: Unified Extensible Firmware Interface
*[JDK]: Java Development Kit

!!! note "Thanks"
    Thank you to Cole Helsell for drafting this guide with me.
