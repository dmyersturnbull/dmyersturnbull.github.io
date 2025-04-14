# Nix shells

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

These are instructions for setting up ZSH, dotfiles, etc.
These documents reference it:

- [macOS setup guide](linux.md)
- [macOS setup guide](macos.md)

## Install [Oh My Zsh](https://ohmyz.sh/)

You’ll thank me later.
(You’ll need ZSH installed for this to work.)

Run

```bash
sh -c "$(curl --fail https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
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

??? background "About `.bash_profile`, `.zshenv`, etc."

    | File              | Shell  | Read if shell is          | My advice                      |
    |-------------------|--------|---------------------------|--------------------------------|
    | `.profile`        | sh †   | login                     | delete                         |
    | `.bash_profile`   | Bash ‡ | login                     | source `.common-profile`       |
    | `.zprofile`       | ZSH    | login                     | source `.common-profile`       |
    | `.bashrc`         | Bash   | interactive and non-login | source `.commonrc`             |
    | `.zshrc`          | ZSH    | interactive               | source `.commonrc`; set up ZSH |
    | `.zshenv`         | ZSH    | non-interactive           | delete                         |
    | `.zlogout`        | ZSH    | logging out               | use if needed                  |
    | `.common-profile` | multi  | N/A (sourced)             | set env vars                   |
    | `.commonrc`       | multi  | N/A (sourced)             | add aliases, etc.              |

    <b>Footnotes:</b>

    - <b>†</b>
      `.profile` is the original Bourne shell config file,
      but Bash will also read it if `.bash_profile` doesn’t exist.
    - <b>‡</b> The default `.zprofile` sources `.bash_profile` if it exists.

    <b>Further reading:</b>

    - [`~/.bashrc` vs. `~/.bash_profile`](https://stackoverflow.com/questions/415403/whats-the-difference-between-bashrc-bash-profile-and-environment)
    - [`~/.zsh*` files](https://unix.stackexchange.com/questions/71253/what-should-shouldnt-go-in-zshenv-zshrc-zlogin-zprofile-zlogout)
    - [`~/.zsh*` files on macOS](https://apple.stackexchange.com/questions/388622/zsh-zprofile-zshrc-zlogin-what-goes-where)
    - [`~/.profile` file](https://unix.stackexchange.com/questions/83742/what-is-the-difference-between-profile-and-bash-profile-and-why-dont-i-have-a)

Create a new file, `~/.commonrc`, and have `~/.bashrc`, `~/.zshrc`, and any other Bash-compatible `~/.*rc` files source it.
Use `~/.commonrc` to set up your environment variables, aliases, etc.
This is a solid but extremely simple way to keep the shell configurations in sync.

I wrote a little script called [`commonrc-config.sh`](files/commonrc-config.sh), which manages this nicely.
It does nothing on its own; it just provides some functions.
Run these commands:

```bash
mkdir -p ~/bin
curl https://dmyersturnbull.github.io/guide/commonrc-config.sh -O ~/bin/commonrc-config.sh
source ~/bin/commonrc-config.sh
commonrc::init
commonrc::source_from bashrc # adds 'source $HOME/.commonrc'
commonrc::source_from zshrc
```

??? info "Fish shell"

    If you want to include the [Fish shell](https://fishshell.com), run

    ```bash
    mkdir -p ~/.config/fish/
    commonrc::add_to_rc ~/.config/fish/config.fish
    ```

??? info

    `commonrc-config.sh`’s functions are just idempotent, so you won’t end up with multiple `source` lines, etc.
    Otherwise, it’s mostly equivalent to this:

    ```bash
    printf 'source ~/.commonrc\n' | tee -a ~/.bashrc >> ~/.zshrc
    printf 'export PATH="$PATH:/usr/sbin:/usr/local/sbin:$HOME/bin"\n' >> ~/.commonrc
    ```

## Sudoers

The easiest way is to run

```bash
su #(1)!
usermod --append --gid sudo $USER
```

1. This will require you to enter the root password.

See this
[sudoers guide](https://www.cyberciti.biz/faq/how-to-sudo-without-password-on-centos-linux/)
for more info.

## Dotfiles

First, make sure `~/bin` exists and is in your PATH.
(If you used `commonrc-config.sh`, it already did this).

Consider using a dotfile manager like [chezmoi](https://www.chezmoi.io/).
You can let chezmoi manage your `~/.commonrc` file, too.

Grab useful Bash scripts from
[awesome-dotfiles](https://github.com/webpro/awesome-dotfiles):
Also see this simplified version of
[my `.commonrc`](files/commonrc.sh),
which contains some useful functions and aliases.
