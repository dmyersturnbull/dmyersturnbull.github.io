# macOS setup

A setup guide for programmers, etc., on Windows.

!!! note "See also"
    [Linux setup guide](linux-setup.md) and
    [Windows setup guide](windows-setup.md)

## Initial setup

The obvious: Upgrade macOS, enable FileVault, and remove unneeded Login Items.

Install [Homebrew](https://brew.sh/) and update it: `brew update && brew upgrade`.
Install a few extra Linux utils:

```bash
brew install ssh-copy-id coreutils git bash zsh
```
Install the text editor [Sublime](https://www.sublimetext.com/) (`brew install --cask sublime-text
`).

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
echo 'alias brewing="brew update && brew upgrade && brew cleanup; brew doctor"' >> ~/.commonrc
```

From that, you can run `brewing` to update Brew and its packages, and fix problems.

!!! note
    Although Homebrew only recommends running `brew doctor` if there’s a problem, chances are you’ll
    eventually need to run it, so it’s not a bad idea to deal with those issues immediately rather than
    to accumulate a daunting stack of issues to fix simultaneously later.

{!guide/_common-setup.md!}

!!! note "Thanks"
    Thank you to Cole Helsell for drafting this guide with me.
