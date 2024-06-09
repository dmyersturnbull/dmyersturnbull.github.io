
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

See [awesome-dotfiles](https://github.com/webpro/awesome-dotfiles). Here are some I used:

```bash
# xdg-open occasionally assumed in scripts,
# so aliasing it to macOS's `open` is a good idea
# alias xdg-open=open

# These improve safety
# Accidentally running `chown -R xx . /` (on root) can brick your system
# The same goes for chmod and chgrp
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

alias wgetc='wget -c'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# list open file handles for the current shell session (also see lsof)
alias handles='ls -la /proc/$$/fd'

# Check free memory
alias fre='free --human'

# Check CPU, memory, and swap usage
alias usg='vmstat --active'

# Check IO usage
alias iousg='sudo iotop --only --batch'

# List listening sockets
alias lssockets='sudo --listening --processes'
alias lstcp='sudo --listening --processes --tcp'
alias lsudp='sudo --listening --processes --udp'

# List threads
# -A == all processes
# -f == full listing (show args)
# -L == show threads
# -l == long format
# -y == Hide flags and show resident set size (RSS; memory used) instead of addr
# --headers == repeat header line once per page
# In the output:
# - NLWP is # of threads
# - LWP is "light-weight process"
alias threads='ps -A -f -L -l -y -S --headers'

# Normal grid exa (--created, --modified, and --git have no effect unless we pass --list)
alias e='exa --all --sort=name --group-directories-first --icons --created --modified --git'
# Detailed view with --list
alias el='exa --all --sort=name --group-directories-first --icons --created --modified --git --list'
# Detailed view in a grid (for wide monitors)
alias elg='exa --all --sort=name --group-directories-first --icons --created --modified --git --list --grid'

# These are nice as navigation shorthands
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../'

# make a dir and cd to it
function mkcd {
    mkdir "$1" && cd "$1"
}

# This one chowns recursively for you
function grab() {
	sudo chown -R ${USER}:${USER} ${1:-.}
}

# This one's modified from https://serverfault.com/questions/3743/what-useful-things-can-one-add-to-ones-bashrc
function extract () {
   if [[ ! -f "$1" ]] ; then
       >&2 echo "'$1' is not a file"
       exit 2
   fi
   case "$1" in
       *.tar.bz2)   tar xvjf "$1"    ;;
       *.tar.gz)    tar xvzf "$1"    ;;
       *.bz2)       bunzip2 "$1"     ;;
       *.rar)       unrar x "$1"     ;;
       *.gz)        gunzip "$1"      ;;
       *.tar)       tar xvf "$1"     ;;
       *.tbz2)      tar xvjf "$1"    ;;
       *.tgz)       tar xvzf "$1"    ;;
       *.zip)       unzip "$1"       ;;
       *.Z)         uncompress "$1"  ;;
       *.snappy)    snunzip "$1"     ;;
       *.sz)        snunzip "$1"     ;;
       *.br)        brotli -d "$1"   ;;
       *.xz)        unxz "$1"        ;;
       *.lz4)       unlz4 "$1"       ;;
       *.lzma)      unlzma  "$1"     ;;
       *.zst)       unzstd "$1"      ;;
       *.7z)        7z x "$1"        ;;
       *)           >&2 echo "I don't know how to extract '$1'"; exit 1 ;;
   esac
 }
```

*[LTS]: Long-Term Support
*[UEFI]: Unified Extensible Firmware Interface
*[JDK]: Java Development Kit
