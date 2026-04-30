---
tags:
  - macOS
  - OS-setup
---

# macOS setup

<!--
SPDX-FileCopyrightText: Copyright 2017-2026, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

A setup guide for programmers, etc., on macOS.

!!! abstract "Also see"

    - [Linux setup guide](linux.md)
    - [Windows setup guide](windows.md)

## Initial setup

First, upgrade macOS by running

```bash
softwareupdate --install --all --agree-to-license
```

!!! danger

    Remember to save your encryption key securely!

Enable FileVault.

### Homebrew

Install [Homebrew](https://brew.sh/) and update it with `brew update && brew upgrade`.
macOS ships with severely outdated versions of ZSH and especially Bash.
Use Brew to install both shells, along with the
[GNU core utils](https://www.gnu.org/software/coreutils/):

```bash
brew install bash zsh coreutils
```

## Configure your shell

First, navigate to _Settings... ➤ Privacy & Security ➤ Full Disk Access_.
Add _Terminal_ to the list of apps that can access all files.

**Follow: _[Shell setup :fontawesome-solid-terminal:](nix-shells.md)_.**

### `brew-refill` alias

!!! abstract "Prerequisites"

    This uses [`commonrc-config.sh`](files/commonrc-config.sh) functions,
    which `~/.commonrc` should source.
    `commonrc::add_line <line>` simply adds `<line>` in `~/.commonrc` if it doesn’t exist.

Add a `brew-refill` command:

```bash
commonrc::add_line \
  'alias brew-refill="brew update && brew upgrade && brew cleanup printf '\n\n\n\n\n' && brew doctor"'
```

From that, you can run `brew-refill` to update Brew and its packages, and to fix problems.

Although Homebrew only recommends running `brew doctor` if there’s a problem, chances are you’ll
eventually need to run it, so it’s not a bad idea to deal with those issues immediately rather than
to accumulate a daunting stack of issues to fix simultaneously later.
Note that `doctor` does nothing on its own: You need to follow the instructions it outputs.

### Xcode

You will probably need
[Xcode](https://developer.apple.com/xcode/)
to build some software package.
Install it through the App Store.

## Replace or supplement macOS utilities

First, declare this `gnu_brew` function for GNU packages that Brew does not automatically add to PATH.
This function makes the GNU tool the default.
It runs `brew install pkg`, uses `brew --prefix pkg` to get a path like `/opt/homebrew/opt/pkg`,
and adds the subdirectory `libexec/gnubin/` or `bin/` to the PATH in `~/commonrc`.

```bash
gnu_brew() {
  local p
  brew install "$1" || return $?
  bash -c 'which $1 | grep homebrew' && return $?
  p=$(brew --prefix $1 || exit $?)
  commonrc::prepend_to_path "$p"/libexec/gnubin "$p"/bin || return $?
}
```

### GNU diffutils

The `diff` from macOS is outdated, so install
[GNU diffutils](https://www.gnu.org/software/diffutils/) via Brew.
The package provides GNU `diff` (2-way), `diff3` (3-way), `sdiff` (merge), and `cmp` (binary).
To override the default `diff`, you may need to adjust your `PATH` as shown.

```bash
gnu_brew diffutils
```

### Curl

macOS’s [Curl](https://curl.se/) is outdated, so replace it using Brew.

```bash
brew install curl
_curl=$(brew --prefix curl)
commonrc::prepend_to_path "$_curl/bin"
commonrc::add_line "export LDFLAGS=\"-L$_curl/lib\""
commonrc::add_line "export CPPFLAGS=\"-I$_curl/include\""
commonrc::add_line "export PKG_CONFIG_PATH=\"$_curl/lib/pkgconfig\""
```

### OpenSSH

??? note "Note: How Heartbleed barely affect macOS"

    macOS mostly uses its own SSL/TLS implementation but continued to ship with OpenSSL.
    When [Heartbleed](https://heartbleed.com/) was discovered in 2014,
    macOS was shipping with OpenSSL so ancient that it was rendered immune.
    That was luck, not good security policy.

macOS ships with a strange custom SSH server and an outdated copy of LibreSSL.
(They recently switched from OpenSSL to [LibreSSL](https://www.libressl.org/), which is good.)
Install OpenSSH and `ssh-copy-id`, and add `ssh-copy-id` your PATH:

```bash
gnu_brew openssl
gnu_brew ssh-copy-id
```

!!! bug "Bug: Brew OpenSSH and LibreSSL"

    The OpenSSH from Brew comes with OpenSSL, not LibreSSL.
    That’s unfortunate but not really a problem.
    You can install LibreSSL with `brew install libressl`.
    But, to get OpenSSH to use it, you’ll need to find an alternate package or build from source.

### GPG and the GitHub CLI

Install GnuPG and the GitHub CLI:

```bash
brew install gnupg gh
```

### vim

Get an improved copy of vi improved from Brew.
Run these commands, checking the output from `which vim`:

```bash
brew install vim && bash -c 'which vim'
```

### grep, find, sed, and awk

To install these and add them to your PATH, run

```bash
gnu_brew grep
gnu_brew findutils
gnu_brew gnu-sed
gnu_brew gawk
```

### Additional utilities

These are useful utilities that macOS doesn’t provide, optional but **strongly recommended**.

- [eza](https://github.com/eza-community/eza) (`ls` replacement)
- [ydiff](https://github.com/ymattw/ydiff) (`diff` replacement)
- [bat](https://github.com/sharkdp/bat) (`cat` replacement)
- [delta](https://github.com/dandavison/delta) (`diff` replacement)
- [ripgrep (rg)](https://github.com/BurntSushi/ripgrep) (`grep` replacement)
- [fd](https://github.com/sharkdp/fd) (`find` replacement)
- [fzw](https://github.com/junegunn/fzf) (fuzzy finder)
- [jq](https://jqlang.github.io/jq/) (like `sed`/`awk` but for JSON)
- [yq](https://mikefarah.gitbook.io/yq) (same as `jq` but for YAML)
- [btop](https://github.com/aristocratos/btop) (`top`/`htop` replacement)
- [p7zip](https://formulae.brew.sh/formula/p7zip) ([7zip](https://www.7-zip.org/))

To install them all, run

```bash
brew install eza ydiff bat ripgrep fd fzw jq yq p7zip
```

??? tip "Suggested packages"

    These packages may be useful:

    - [ack](https://github.com/beyondgrep/ack3/)
    - [difftastic](https://github.com/Wilfred/difftastic)

## Security and connections

### Sudoers

!!! abstract "Also see"

    - [sudoers in the Linux guide](linux.md#sudoers)

If you don’t have sudo access, add your username to
the `admin` group:

```bash
sudo dseditgroup -o edit -a $USER -t user admin
```

If you use `sudo visudo` to edit `/etc/sudoers`, the file is checked for syntax before save.
You can also check syntax with `visudo -c my-sudoers.txt`.
Find the line covering the relevant group (`sudo`, `wheel`, or `admin`), and prepend `NOPASSWD:` to `ALL`.
The line will probably look like this:

```text
%admin ALL=(ALL) NOPASSWD:ALL
```


### Disable quarantining downloads

!!! tip

    To remove the attribute from a single file, use `xattr -d com.apple.quarantine <path>`.

Some applications on macOS choose to mark all downloaded files with the extended file attribute
([xattr](https://en.wikipedia.org/wiki/Extended_file_attributes))
`com.apple.quarantine`.
That includes mainstream browsers.

```bash
defaults write com.apple.LaunchServices LSQuarantine -bool NO
```

### Optionally, disable Gatekeeper

Run this to enable the option to disable Gatekeeper:

```bash
sudo spctl --master-disable
```

!!! warning

    Gatekeeper also does useful things like code signing.
    Only disable it if it’s still getting in the way after disabling the auto-quarantine.

Then, if needed, you can disable Gatekeeper altogether by navigating to
_System Settings ➤ Privacy & Security ➤ Security ➤ Allow applications from_
and choosing the newly appearing option _Anywhere_.

### Configure Git, SSH, and GPG

**Follow: _[Shell setup :fontawesome-solid-shield-halved:](git-ssh-and-gpg.md)_.**

### Generate a certificate

If you need a certificate, set a static IP address and generate a certificate with
[certbot](https://certbot.eff.org/).
Choose “None of the above” for Software.
Then follow the instructions exactly, including the “Automating renewal” section.
This may not work through some company and university firewalls.

## Programming languages and frameworks

### C/C++

!!! abstract "Prerequisites"

    `gnu_brew` is defined in a section above.

```bash
gnu_brew make
brew install autoconf cmake
```

### Java, Rust, and Python

See the [toolkits guide](toolkits.md).

## Tweaks

### Finder

Make a few adjustments to Finder settings.

- Show hidden files by running

  ```bash
  defaults write com.apple.Finder AppleShowAllFiles true \
    && killall Finder
  ```

- Show filename extensions: Do this in _Finder ➤ Settings... ➤ Advanced_.
- Add your home folder to the SideBar: _File ➤ Add to sidebar_.
- Show full filenames: Check _Finder ➤ Settings... ➤ Advanced ➤ Show all filename extensions_.
- (Optional) Show folders on top: Check _Finder ➤ Settings... ➤ Advanced ➤ Keep folders on top_.
- Show directory size: Check _View ➤ Show View Options ➤ Show item info ➤ Use as Defaults_.

### Use 24-hour time and yyyy-mm-dd.

Under _System Settings ➤ General ➤ Date & Time_, enable _24-hour time_ and _Show 24-hour time on Lock Screen_.
Under _System Settings ➤ General ➤ Language & Region_, change _Date Format_.
You can also change _Number Format_ to the
[IEEE-](https://www.ieee.org/content/dam/ieee-org/ieee/web/org/conferences/style_references_manual.pdf),
[NIST-](https://www.nist.gov/pml/nist-technical-note-1297),
and [JCGM-](https://www.bipm.org/en/committees/jc/jcgm/publications) recommended
`1 234 567.89`.

### Make the Dock show/hide instantly.

You can have the Dock auto-hide but pop up instantly by running

```bash
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -int 0
killall Dock
```

### Set shortcuts and Hot Corners.

Under _System Settings ➤ Desktop & Dock_,
see (at the very bottom) _Shortcuts..._ and _Hot Corners..._.
I use this:

- top right: _Launchpad_
- bottom right: _Mission Control_
- bottom left: _Application Windows_

### Stop macOS from adding `.` after two spaces.

Annoyingly, this happens even when typing code in an IDE.
Under _System Settings ➤ Keyboard ➤ Text Input ➤ Input Sources ➤ Edit..._,
uncheck _Add period with double-space_.

### Repurpose the mostly useless 🌐︎ key.

_**Caution:** This has the unfortunate downside of disabling the F1 … F12 keys._
You can do this under
_System Settings ➤ Keyboard ➤ Keyboard Shortcuts... ➤ Modifier Keys ➤ Globe (🌐︎) key_.
I mapped it to ⌘ (retaining ⌘) to make it easier to switch to/from Windows,
where CTRL is in the same position.

### Cleanup

1. Remove GarageBand files under _System Settings ➤ General ➤ Storage ➤ Music Creation_.
2. Disable unwanted startup apps under _System Settings ➤ General ➤ Login Items_.

### Optional apps

- Terminal: For the much-loved [iTerm2](https://iterm2.com/), run `brew install --cask iterm2`.
- Text editor: For [Sublime](https://www.sublimetext.com/), run `brew install --cask sublime-text`.

### Aliases to find things

I keep forgetting where macOS puts certain files, so I use aliases to find them:

```bash
# List my notes in the Stickies app.
alias ls-stickies='eza -l -s created $HOME/Library/Containers/com.apple.Stickies/Data/Library/Stickies/*.rtfd/TXT.rtf'

# List screenshots I just took.
alias ls-screenshots='eza -l -s created $HOME/Desktop/Screenshot *.png'
```

---

_Credits: Cole Helsell drafted the original version of this guide with me._
