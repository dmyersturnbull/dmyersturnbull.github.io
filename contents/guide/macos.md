# macOS setup

<!--
SPDX-FileCopyrightText: Copyright 2017-2024, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

A setup guide for programmers, etc., on Windows.

!!! related

    [Linux setup guide](linux.md) and
    [Windows setup guide](windows.md)

## Initial setup

First, upgrade macOS by running

```bash
softwareupdate --install --all --agree-to-license
```

Enable FileVault, and remove unneeded Login Items.

!!! note "Reminder"

    Remember to save your encryption key!

Install [Homebrew](https://brew.sh/) and update it: `brew update && brew upgrade`.
Install a few extra Linux utils and the text editor [Sublime](https://www.sublimetext.com/):

```bash
brew install ssh-copy-id coreutils git bash zsh
brew install --cask sublime-text
```

And a couple of small things:

- Show hidden files:

  ```bash
  defaults write com.apple.Finder AppleShowAllFiles true \
    && killall Finder
  ```

- Show filename extensions: Do this in _Finder ➤ Settings ➤ Advanced_.
- In Finder, add your home folder to the SideBar: _File ➤ add to sidebar_.
- _Finder ➤ settings ➤ Advanced ➤ Show all filenames_.

## Configure your shell

**Follow: _[Shell setup :fontawesome-solid-terminal:](nix-shells.md)_.**

### `brew-refill` alias

Run this to add a `brew-refill` command:

```bash
printf '
alias brew-refill="brew update; brew upgrade; brew cleanup; brew doctor"
' >> ~/.commonrc
```

From that, you can run `brew-refill` to update Brew and its packages, and to fix problems.

!!! note

    Although Homebrew only recommends running `brew doctor` if there’s a problem, chances are you’ll
    eventually need to run it, so it’s not a bad idea to deal with those issues immediately rather than
    to accumulate a daunting stack of issues to fix simultaneously later.

## Git, SSH, and GPG

Install a version of OpenSSL (actually [LibreSSL](https://www.libressl.org/)) that will receive updates:
`brew install libressl`.
The OpenSSL version in macOS by default was seriously out-of-date when
[Heartbleed](https://heartbleed.com/) was made public, and took a long time to get patched.

Also install GPG and the GitHub CLI:

```bash
brew install gnupg gh
```

Next, **follow: _[Shell setup :fontawesome-solid-shield-halved:](git-ssh-and-gpg.md)_.**

<!-- Toolkits; e.g. Java and Rust -->

{%
  include-markdown './files/_toolkits.md'
  heading-offset=1
%}

## Generate a certificate

If you need a certificate, set a static IP address and generate a certificate with
[certbot](https://certbot.eff.org/).
Choose “None of the above” for Software.
Then follow the instructions exactly, including the “Automating renewal” section.
This may not work through some company and university firewalls.

_[LTS]: Long-Term Support
_[JDK]: Java Development Kit

!!! thanks

    Thank you to Cole Helsell for drafting this guide with me.
