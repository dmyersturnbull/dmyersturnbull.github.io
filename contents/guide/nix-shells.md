# Nix shells

These are instructions for setting up ZSH, dotfiles, etc.
These documents reference it:

- [macOS setup guide](linux.md)
- [macOS setup guide](macos.md)

## Install [Oh My Zsh](https://ohmyz.sh/)

You’ll thank me later.
(You’ll need ZSH installed for this to work.)

Run

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

Create a new file, `~/.commonrc`, and have `~/.bashrc`, `~/.zshrc`, and any other Bash-compatible `~/.*rc` files source it.
Use `~/.commonrc` to set up your environment variables, aliases, etc.
This is a solid but extremely simple way to keep the shell configurations in sync.

I wrote a little script called [`commonrc-config.sh`](commonrc-config.sh), which manages this nicely.
It does nothing on its own; it just provides some functions.
Run these commands:

```bash
mkdir -p ~/bin
wget https://dmyersturnbull.github.io/guide/commonrc-config.sh -O ~/bin/commonrc-config.sh
source ~/bin/commonrc-config.sh
commonrc::initialize
commonrc::add_to_rc bashrc # adds 'source $HOME/.commonrc'
commonrc::add_to_rc zshrc
commonrc::add_line 'source ~/bin/commonrc-config.sh'
```

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
su  #(1)!
usermod -aG sudo $USER
```

1. This will require you to enter the root password.

See this [sudoers guide](https://www.cyberciti.biz/faq/how-to-sudo-without-password-on-centos-linux/) for more info.

## Dotfiles

Make a `~/bin` directory and add it to your `$PATH` in `.commonrc`:

```bash
mkdir ~/bin && printf 'export PATH=$HOME/bin:$PATH\n' >> ~/.commonrc
```

Consider using a dotfile manager like [chezmoi](https://www.chezmoi.io/).
You can let chezmoi manage your `~/.commonrc` file, too.

Grab useful Bash scripts from
[awesome-dotfiles](https://github.com/webpro/awesome-dotfiles):
Clone your chosen dotfiles repo into `~/bin`.

I put some aliases and functions directly in
[my `.commonrc`](commonrc.sh).
