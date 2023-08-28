# macOS setup

There are other guides for setting up macOS for development.
I found this guide useful for graduate students who are relatively new to programming.
Here’s what you’ll do:

- Basic setup and installing tools
- Set up a good shell environment
- Fix security problems and add SSH and GPG keys
- Install final software

!!! note "See also"
    [Linux setup guide](linux-setup.md) and
    [Windows setup guide](windows-setup.md)

## Initial setup

The obvious: Upgrade macOS, enable FileVault, and remove unneeded Login Items.

Install [Homebrew](https://brew.sh/) and update it: `brew update && brew upgrade`.
Install a few extra Linux utils: `brew install ssh-copy-id coreutils git` and an upgraded version of Bash (Bash 5):
`brew install bash` as well as ZSH: `brew install zsh`.
Install the text editor [Sublime](https://www.sublimetext.com/) (`brew cask install sublime-text`).

And a couple of small things:

- Show hidden files: Run `defaults write com.apple.Finder AppleShowAllFiles true`.
  Then: `killall Finder`
- Show filename extensions: Do this in Finder → Settings → Advanced.
- In Finder, add your home folder to the SideBar. File → add to sidebar.
- Finder → settings → Advanced → Show all filenames.

## Install SSH

Install a version of OpenSSL (actually [LibreSSL](https://www.libressl.org/) that will receive updates:
`brew install libressl`.
The OpenSSL version in macOS by default was seriously out-of-date when
[Heartbleed](https://heartbleed.com/) was made public, and took a long time to  get patched.

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
