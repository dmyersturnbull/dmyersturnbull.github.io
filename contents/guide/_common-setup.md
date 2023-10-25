
## Install [Oh My Zsh](https://ohmyz.sh/)

You’ll thank me later. (You’ll need ZSH installed for this to work.)

```bash
chsh -s $(which zsh)
zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
chsh -s $(which zsh)
```

Restart your terminal. You should now have a colorful shell, complete with a plugin for Git.

## `.commonrc` file

To keep the config for ZSH and Bash consistent, add a file called `.commonrc` in your home directory:

```bash
echo 'export PATH=/usr/local/git/bin:/usr/local/sbin:$PATH' > ~/.commonrc
echo 'source ~/.commonrc' >> ~/.zshrc
echo 'source ~/.commonrc' >> ~/.bashrc
```

From here on, only modify `.commonrc` so that both Bash and ZSH have the same environment.

## Git, SSH, and GPG

**See [this guide](git-ssh-gpg.md).**

## Install Java and Rust

First, [Install the Rust toolchain](https://rustup.rs/).

Then, **download [JDK 21 from Temurin](https://adoptium.net/temurin/releases/).
Do not use Java 8, java.com, or OpenJDK.**
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

## Allow SSH login

Install ssh to allow for remote logins.

```
sudo apt update
sudo apt install openssh-server
sudo ufw allow 22
```

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

# These are colorful/nice variants of commands
alias la='ls -l --almost-all --no-group --group-directories-first --escape --human-readable --time-style=long-iso'
alias wgetc='wget -c'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# This will show open ports in a compact form
alias ports='netstat -tulanp'

# And this will list open file handles
# It's really useful when a file handle is incorrectly lingering
# Also see `losf`
alias handles='ls -la /proc/$$/fd'

# These are nice as navigation shorthands
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../'
function cdd { mkdir "$1" && cd "$1" } # make a dir and cd to it
function cdd. { mkdir "../$1" && cd "../$1" }

# This one's super useful on macOS:
# open finder with f or f /path/to/folder
#function f { if (( $# > 0 )); then open -a Finder "$1";  else open -a Finder ./; fi }

# This one chowns recursively for you
grab() {
	sudo chown -R ${USER}:${USER} ${1:-.}
}

# This one's modified from https://serverfault.com/questions/3743/what-useful-things-can-one-add-to-ones-bashrc
extract () {
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
