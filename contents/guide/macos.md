<!--
SPDX-FileCopyrightText: Copyright 2017-2024, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->
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
sudo cat /etc/passwd | grep $USER
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
I put some aliases and functions directly in my `.commonrc`:

[`add-bookmarks.sh.txt` :fontawesome-solid-code:](commonrc.sh.txt){ .md-button }


*[LTS]: Long-Term Support
*[UEFI]: Unified Extensible Firmware Interface
*[JDK]: Java Development Kit

!!! note "Thanks"
    Thank you to Cole Helsell for drafting this guide with me.
