---
title: "Linux setup"
date: 2021-04-16:13:30-08:00
draft: false
slug: linux-setup
---


This documents best practice setup for shell profiles, security, SSH, and GPG
that work in Linux, macOS, and the Windows subsystem.

Also see the [macOS setup guide](https://dmyersturnbull.github.io/macos-setup/) or
[Windows setup guide](https://dmyersturnbull.github.io/windows-setup/),
which I recommend checking out first.


### Install [Oh My Zsh](https://ohmyz.sh/)

You’ll thank me later. (You’ll need ZSH installed for this to work.)

```bash
chsh -s /usr/bin/env zsh
zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

Switch to ZSH as your default shell: `chsh -s $(which zsh)` and 
Restart your terminal. You should now have a colorful shell, complete with a plugin for Git.

To keep the config for ZSH and Bash consistent, add a common config file:

```bash
echo 'export PATH=/usr/local/git/bin:/usr/local/sbin:$PATH' > ~/.commonrc
echo 'source ~/.commonrc' >> ~/.zshrc
echo 'source ~/.commonrc' >> ~/.bashrc
```

From here on, only modify `.commonrc` so that both Bash and ZSH have the same environment.



### Generate SSH keys

_What you’ll be doing:_ SSH keys provide asymmetric cryptography for securing your
connections. In asymmetric cryptography, there are two keys: a public one and a private one.
The public key encrypt messages, while the private one is needed to decrypt them. This means that
– although you shouldn’t – you could send your public key out to everyone. But your private key
must remain on your computer and be secure. For historical reasons, SSH and OpenSSL provide two
independent mechanisms for, but they’re similar in this functionality.

*Note:*
You can follow
[GitHub’s guide to create keys](https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent),
which is almost identical.


To generate SSH keys, I recommend:
```bash
ssh-keygen -t ed25519 -a 100
```

Some servers might not support EdDSA yet.
If needed, you can instead use:
```bash
ssh-keygen -t rsa -b 4096 -o -a 100 -T ~/.ssh/id_rsa
```

The output path (`-T`) should be the default, but you may want to name it with something that reflects the server it’s meant for.
In either case, don’t bother to set a passcode: If someone has access 
to your files you have bigger problems. (Instead, rely on encryption (e.g. FileVault) and
a strong password.) Start the SSH agent: `eval $(ssh-agent -s)`.


### Configure SSH securely

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


# Modify these as needed
Host *
ServerAliveInterval 60
ServerAliveCountMax 1200
	

Host github
HostName github.com
IdentityFile ~/.ssh/id_ed25519
User kelly@gmail.com
```

If you need to connect to another server, add this and run `ssh-copy-id` to transfer your key:
```
Host lab
HostName my.server.x
User kelly
IdentityFile ~/.ssh/id_ed25519
```

On macOS, `AddKeysToAgent yes` might be wanted.
After saving the config, run:

```bash
chmod 644 ~/.ssh/config
```

### Create GPG keys

Install GPG: `apt install gnupg`, `dnf install gnupg`, `brew install gnupg`, or `choco install gpg4win`.
Then:

```
gpg --full-generate-key -t ed25519
```

Again, skip the passphrase. Move your mouse or type some keys to help the pseudorandom number generator.

 Then follow GitHub’s guide to [add the GPG key to your account](
https://docs.github.com/en/github/authenticating-to-github/adding-a-new-gpg-key-to-your-github-account). 
The steps are: copy the output of
`gpg --list-secret-keys --keyid-format LONG` to GitHub.
Among other things, this will allow you to
[sign your commits](https://docs.github.com/en/github/authenticating-to-github/signing-commits): run
`git config --global commit.gpgsign true`.


###  Configure Git

First, configure your username and email:

```bash
git config --global user.name "your_username"
git config --global user.email "your_email@address.tld"
```

Follow GitHub’s instructions to add [SSH keys to GitHub](https://docs.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account)
To clone with https, you may need to [add the git https helper](https://stackoverflow.com/questions/8329485/unable-to-find-remote-helper-for-https-during-git-clone).
Run `sudo apt install libcurl4-openssl-dev ` in Ubuntu
or `dnf install curl-devel` in Fedora.


### Generate a certificate

If you need a certificate, set a static IP address and generate a certificate with 
[certbot](https://certbot.eff.org/). Choose “None of the above” for Software.
Then follow the instructions exactly, including the “Automating renewal” section.
This may not work through some company and university firewalls.


### Final software

First, update Java.
You can alternatively download it from Oracle:
[JDK 16](https://www.oracle.com/java/technologies/javase-jdk16-downloads.html).
Do *not* use OpenJDK: The performance is nowhere near as high.
(You might only need the runtime platform, but the Development Kit isn’t large.)

For Python, I recommend [Miniconda](https://docs.conda.io). Take a look at
[these steps](https://dmyersturnbull.github.io/#-simple-setup).


### Supplement: aliases

Also see [awesome-dotfiles](https://github.com/webpro/awesome-dotfiles).

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
