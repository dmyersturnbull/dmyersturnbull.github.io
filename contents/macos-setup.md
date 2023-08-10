# macOS setup

There are other guides for setting up macOS for development.
I found this guide useful for graduate students who are relatively new to programming.
Here’s what you’ll do:

- Basic setup and installing tools
- Set up a good shell environment
- Fix security problems and add SSH and GPG keys
- Install final software

Also see the [Windows setup guide](https://dmyersturnbull.github.io/windows-setup/).

### Initial setup

The obvious: Upgrade macOS, enable FileVault, and remove unneeded Login Items.

Install [Homebrew](https://brew.sh/) and update it: `brew update && brew upgrade`.
Install a few extra Linux utils: `brew install ssh-copy-id coreutils git` and an upgraded version
of Bash (Bash 5): `brew install bash` as well as ZSH: `brew install zsh`.
Install the text editors [Sublime](https://www.sublimetext.com/) (`brew cask install sublime-text`)
and/or [Atom](https://atom.io/) (`brew install atom`).
Make an account on [GitHub](https://github.com/) and request access to any orgs you need.

And a couple of silly things:

- Show hidden files: Run `defaults write com.apple.Finder AppleShowAllFiles true`.
  Then: `killall Finder`
- Show filename extensions: Do this in Finder → Settings → Advanced.
- In Finder, add your home folder to the SideBar. File → add to sidebar.
- Finder → settings → Advanced → Show all filenames.

### SSH, GPG, security, and other setup

Install a version of OpenSSL (actually [LibreSSL](https://www.libressl.org/) that will
receive updates: `brew install libressl`.
The OpenSSL version in macOS by default was seriously out-of-date when
[Heartbleed](https://heartbleed.com/) was made public, and took a long time to
get patched.

Now, **follow these [any-OS instructions](https://dmyersturnbull.github.io/linux-setup/)**
to set up everything else.

### Shell aliases

I like running this to add a `brewski` command:

```bash
echo 'alias brewski="brew update && brew upgrade && brew cleanup; brew doctor"' >> ~/.commonrc
```

From that, you can run `brewski` to update Brew and its packages, and fix problems.
Although Homebrew only recommends running `brew doctor` if there’s a problem, chances are you’ll
eventually need to run it, so it’s not a bad idea to deal with those issues immediately rather than
to accumulate a daunting stack of issues to fix simultaneously later.

### Update outdated software

macOS’s built-in Java is seriously out-of-date.
You can install via Homebrew: `brew install --cask oracle-jdk`.
Don’t use OpenJDK: The performance is poor.

### Final steps

Take a look at the
[data science setup guide](https://dmyersturnbull.github.io/data-science-setup)
for best practices when setting up programming development environments, especially Python.
