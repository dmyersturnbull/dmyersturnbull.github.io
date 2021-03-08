---
title: "Setup for macOS for development"
date: 2021-01-25:10:00-08:00
draft: false
slug: macos-setup
---


This is a *draft*.

There are other guides for setting up macOS for development.
I found this guide useful for graduate students who are relatively new to programming.  
Here’s what you’ll do:
- Basic setup and installing tools
- Set up a good shell environment
- Fix security problems and add SSH and GPG keys
- Install final software


### Initial setup

The obvious: Upgrade macOS, enable FileVault, and remove unneeded Login Items.

Install [Homebrew](https://brew.sh/) and update it: `brew update && brew upgrade`.
Install a few extra Linux utils: `brew install ssh-copy-id coreutils git` and an upgraded version
of Bash (Bash 5): `brew install bash` as well as ZSH: `brew install zsh`.
Install the text editors [Sublime](https://www.sublimetext.com/) (`brew cask install sublime-text`)
and/or [Atom](https://atom.io/) (`brew install atom`).
Make an account on [GitHub](https://github.com/) and request access to any orgs you need.


### Shell profile

Now that ZSH is installed, let’s improve it. Install [Oh My Zsh](https://ohmyz.sh/)
and switch to ZSH as your default shell: `chsh -s $(which zsh)` and 
Restart your terminal. You should now have a colorful shell, complete with a plugin for Git.

To keep the config for ZSH and Bash consistent, add a common config file:
```bash
echo 'export PATH=/usr/local/git/bin:/usr/local/sbin:$PATH' > ~/.commonrc
echo 'alias brewski="brew update && brew upgrade && brew cleanup; brew doctor"' >> ~/.commonrc
echo 'source ~/.commonrc' >> ~/.zshrc
echo 'source ~/.commonrc' >> ~/.bashrc
```

From here on, only modify `.commonrc` so that both Bash and ZSH have the same environment.
Note the _brewski_ line: you can run `brewski` to update Brew and its packages, and fix problems.
Although Homebrew only recommends running `brew doctor` if there’s a problem, chances are you’ll
eventually need to run it, so it’s not a bad idea to deal with those issues immediately rather than
to accumulate a daunting stack of issues to fix simultaneously later.
You can also add some nice aliases (below).


### Security, SSH, & GPG

First, install a version of OpenSSL (actually [LibreSSL](https://www.libressl.org/)) that will
receive updates: `brew install libressl`.
The OpenSSL version in macOS by default was seriously out-of-date when
[Heartbleed](https://heartbleed.com/) was made public, and took a long time to
get patched.

_A note about what you’ll be doing:_ SSH keys provide asymmetric cryptography for securing your
connections. In asymmetric cryptography, there are two keys: a public one and a private one.
The public key encrypt messages, while the private one is needed to decrypt them. This means that
– although you shouldn’t – you could send your public key out to everyone. But your private key
must remain on your computer and be secure. For historical reasons, SSH and OpenSSL provide two
independent mechanisms for, but they’re similar in this functionality.


Follow [GitHub’s SSH keys guide](
https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
to generate SSH keys and add them to GitHub. The path should be `~/.ssh/id_rsa`, unless you prefer
keeping separate keys for GitHub. Don’t bother to add a passcode: If someone has access 
to your files you have bigger problems. (Instead, rely on encryption (FileVault) and
a strong password.) Make sure to run the `git config` commands.

Create or edit `~/.ssh/config`:
- Disable SSH agent forwarding, [which](
https://security.stackexchange.com/questions/101783/are-there-any-risks-associated-with-ssh-agent-forwarding)
[is](https://en.wikipedia.org/wiki/Ssh-agent#Security_issues)
[very](https://github.com/microsoft/vscode-remote-release/issues/1222)
[insecure](https://manpages.debian.org/buster/openssh-client/ssh.1.en.html#A).
Also disable X forwarding, which also has [security concerns](
https://security.stackexchange.com/questions/14815/security-concerns-with-x11-forwarding).
You’re unlikely to need either.

Your config might look something like this:
```
# Disable SSH agent forwarding
# https://heipei.io/2015/02/26/SSH-Agent-Forwarding-considered-harmful/
ForwardAgent no
ForwardX11 no
# turn off X forwarding for better security
ForwardX11Trusted no

Host github
	HostName github.com
	IdentityFile ~/.ssh/tirith-github
	User dmyersturnbull@gmail.com

```

If you need to connect to another server, add this and run `ssh-copy-id` to transfer your key:
```
Host lab
	HostName my.server.x
	User kelly
    IdentityFile ~/.ssh/id_rsa
```


Install GPG: `brew install gnupg`. Then follow GitHub’s guides to
[generate a GPG key](https://docs.github.com/en/github/authenticating-to-github/generating-a-new-gpg-key)
and [add the GPG key to your account](
https://docs.github.com/en/github/authenticating-to-github/adding-a-new-gpg-key-to-your-github-account).
Again, skip the passphrase.
The general steps are: `gpg --full-generate-key` and copying the output of
`gpg --list-secret-keys --keyid-format LONG` to GitHub.
Among other things, this will allow you to
[sign your commits](https://docs.github.com/en/github/authenticating-to-github/signing-commits): run
`git config --global commit.gpgsign true`.


If you need a certificate, set a static IP address and generate a certificate with 
[certbot](https://certbot.eff.org/). Choose “None of the above” for Software and “macOS” for
Operating System. Then follow the instructions exactly, including the “Automating renewal” section.
This may not work through some company and university firewalls.


### Final software

macOS’s built-in Java is seriously out-of-date.
You can install via Homebrew: `brew install --cask oracle-jdk`.
You can alternatively download it from Oracle:
[JDK 15](https://www.oracle.com/java/technologies/javase-jdk15-downloads.html).
Do *not* use OpenJDK: The performance is nowhere near as high.
(You might only need the runtime platform, but the Development Kit isn’t large.)
For Python, I recommend [Miniconda](). Take a look at
[these steps](https://dmyersturnbull.github.io/#-simple-setup).



### Supplement: aliases

Also see [awesome-dotfiles](https://github.com/webpro/awesome-dotfiles).

```bash
# xdg-open occasionally assumed in scripts,
# so aliasing it to macOS's `open` is a good idea
alias xdg-open=open

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

# This one's super useful:
# open finder with f or f /path/to/folder
function f { if (( $# > 0 )); then open -a Finder "$1";  else open -a Finder ./; fi }

# This one chowns recursively for you
grab() {
	sudo chown -R ${USER}:${USER} ${1:-.}
}


# This one's modified from https://serverfault.com/questions/3743/what-useful-things-can-one-add-to-ones-bashrc
extract () {
   if [[ -f "$1" ]] ; then
       case "$1" in
           *.tar.bz2)   tar xvjf $1    ;;
           *.tar.gz)    tar xvzf $1    ;;
           *.bz2)       bunzip2 $1     ;;
           *.rar)       unrar x $1       ;;
           *.gz)        gunzip $1      ;;
           *.tar)       tar xvf $1     ;;
           *.tbz2)      tar xvjf $1    ;;
           *.tgz)       tar xvzf $1    ;;
           *.zip)       unzip $1       ;;
           *.Z)         uncompress $1  ;;
           *.7z)        7z x $1        ;;
           *)           echo "don't know how to extract '$1'..." ;;
       esac
   else
       echo "'$1' is not a valid file!"
   fi
 }
```