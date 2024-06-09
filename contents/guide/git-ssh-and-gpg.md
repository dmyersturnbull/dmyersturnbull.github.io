# Git, SSH, and GPG

These instructions should work for Linux, macOS, and Windows.

!!! note
    Install Git, SSH, GPG, and the [GitHub CLI](https://cli.github.com/) before proceeding.
    Follow the
    [Linux setup guide](macos.md),
    [macOS setup guide](macos.md),
    or [Windows setup guide](windows.md).

## Configure Git

Configure your username and email:

```bash
git config --global user.name "your_username"
git config --global user.email "email_used_for_github@address.tld"
```

To clone with https, you may need to
[add the git https helper](https://stackoverflow.com/questions/8329485/unable-to-find-remote-helper-for-https-during-git-clone).
Run `sudo apt install libcurl4-openssl-dev ` in Ubuntu or `dnf install curl-devel` in Fedora.

## Set up SSH keys

!!! abstract "What you’ll be doing"
    SSH keys provide asymmetric cryptography for securing your
    connections. In asymmetric cryptography, there are two keys: a public one and a private one.
    The public key encrypt messages, while the private one is needed to decrypt them.
    This means that you could send your public key out to everyone.
    But your private key must remain on your computer and be secure.
    For historical reasons, SSH, OpenSSL, and GPG provide independent mechanisms, but they’re similar.

### [Generate a new SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key)
### [Add it to the ssh-agent](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent)
### [Add it to GitHub](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

### Configure SSH

!!! abstract "About these steps"
    Disable SSH agent forwarding, [which](https://security.stackexchange.com/questions/101783/are-there-any-risks-associated-with-ssh-agent-forwarding)
    [is](https://en.wikipedia.org/wiki/Ssh-agent#Security_issues)
    [very](https://github.com/microsoft/vscode-remote-release/issues/1222)
    [insecure](https://manpages.debian.org/buster/openssh-client/ssh.1.en.html#A).
    Also disable X forwarding, which also has
    [security concerns](https://security.stackexchange.com/questions/14815/security-concerns-with-x11-forwarding).
    These are usually the defaults.

Create or edit `~/.ssh/config`. Replace the contents with the following.

```
AddKeysToAgent yes
ForwardAgent no
ForwardX11 no
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

!!! tip
    If needed, fix permissions with this snippet:

    ```bash
    chmod 600 "~/.ssh/*"
    chmod 700 "~/.ssh/"
	[[ -e "~/.ssh/config" ]] && chmod 700 "~/.ssh/config"
	[[ -e "~/.ssh/known_hosts" ]] && chmod 700 "~/.ssh/known_hosts"
    chmod 644 "~/.ssh/*.pub"
	[[ -e "~/.ssh/authorized_keys" ]] && chmod 644 "~/.ssh/authorized_keys"

    ```

### _Optional:_ Connect to another server

To set up your keys to connect to another server, run `ssh-copy-id` to transfer your key.
Also add it to your config:

```
Host lab
HostName my.server.x
User kelly
IdentityFile ~/.ssh/id_ed25519
```

!!! note
    Some servers might not support EdDSA yet.
    If this is the case, generate another pair of keys:
    ```bash
    ssh-keygen -t rsa -b 4096 -o -a 100 -T ~/.ssh/id_rsa
    ```
    Substitute `id_ed25519` for `id_rsa` in your config.

### _Optional:_ Allow remote access

You will need to install and configure the SSH server.

=== "Ubuntu"

    ```bash
    sudo apt install openssh-server
    sudo systemctl enable ssh
    ```

    Open port 22:

    ```bash
    sudo ufw allow 22
    ```

=== "Fedora"

    ```bash
    sudo dnf install openssh-server
    sudo systemctl enable ssh
    ```

    `firewalld` should accept communications over port 22 without additional configuration.
    If not, look for firewalld guides (and shoot me a message).

=== "macOS"

    Enable "Remote Login" and "Allow full disk access for remote users" under Sharing settings.

=== "Windows"

    Enable "OpenSSH server" under Optional Features.


### _Alternative to GPG:_ Sign with SSH

As of August 2022, GitHub supports
[signing with SSH keys](https://github.blog/changelog/2022-08-23-ssh-commit-verification-now-supported/),
which you can use instead.
This is an alternative to signing with GPG keys.
However, this has no significant advantages, is more limited, and may be less secure.

??? warning "If you still want to sign with SSH keys"

    Run:
    ```bash
    git config --global gpg.format ssh
    git config --global user.signingkey ~/.ssh/id_ed25519
    git config --global commit.gpgsign true
    ```

    **Note:** Although the config keys are `gpg.format` and `gpg.format`, it will actually use SSH.

## Set up GPG keys

### Generate a key pair

Also see
[GitHub’s guide](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key)
to generating GPG keys.
You may consider using an  [`@users.noreply` email address](https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-email-preferences/setting-your-commit-email-address)
per their suggestion.

1. Install GPG:

    === "Ubuntu"

        `sudo apt install gnupg`

    === "Fedora"

        `sudo dnf install gnupg`

    === "macOS"

        `brew install gnupg`

    === "Windows"

        `choco install gnupg` (as an administrator)

2. Launch gpg-agent by running
    ```bash
    gpg-connect-agent reloadagent /bye
    ```

3. Then, generate a key pair by running

    ```bash
    gpg --full-generate-key -t ed25519
    ```

    Use your full name and the email address you used on GitHub.
    As with SSH keys, you may choose to use a passphrase.
    Choose a reasonable expiration date.

### Tell Git to use your GPG key

To see your generate key pair, run

```bash
gpg --list-keys --keyid-format long
```

```asc
sec   ed25519 2023-11-04 [SC] [expires: 2025-11-03]                (1)!
      983C8320158FBB03818D3910C01A28311C1501SH                     (2)!
uid           [ultimate] Kerri Johnson <kerri-johnson@hotmail.com>
ssb   cv25519 2023-11-04 [E] [expires: 2025-08-03]
```

1. Check the type: `pub` is public; `sec` is your private key. **Here, we want `sec`.**
2. This is your key ID. (Note: There may be a prefix, using `/` as a seperator.)

If you have multiple keys, make sure to select the one you want.
Using your secret key ID, run:

```bash
git config --global\
  --unset gpg.format
git config --global\
  commit.gpgsign true
git config --global\
  user.signingkey 983C8320158FBB03818D3910C01A28311C1501SH
```

### Upload the GPG key to GitHub

Using your secret key ID, run

```bash
gpg \
  --armor\
  --export 983C8320158FBB03818D3910C01A28311C1501SH\
  --output key.private.gpg
```

Then upload to GitHub by running the following.

```bash
gh gpg-key add key.private.gpg --title "IBM Laptop" # (1)!
```

1. Use a good title.

Delete the `key.private.gpg` file when done.

### _Optional:_ Publicize your public key

!!! note
    This assumes that you used a real email address, not a `@users.noreply.github.com` address.

To list your public keys, run

```bash
gpg --list-keys --keyid-format long
```

You’ll see this:

```asc
pub   ed25519 2023-11-04 [SC] [expires: 2025-11-03]                (1)!
      AC03281HD01A83C8DD50A9BEAA130FA03599207C                     (2)!
uid           [ultimate] Kerri Johnson <kerri.johnson@hotmail.com>
sub   cv25519 2023-11-04 [E] [expires: 2025-11-03]
```

1. Check the type: `pub` is public; `sec` is your private key. **Here, we want `pub`.**
2. This is your key ID. (Note: There may be a prefix, using `/` as a seperator.)

!!! warning
    Make sure you are using your public (`pub`) key, not your private key (`sec`).

Using your public key ID, run the following to get a key file called `kerri-johnson.pub.asc`:

```bash
gpg\
  --armor\
  --export AC03281HD01A83C8DD50A9BEAA130FA03599207C\
  --output kerri-johnson.asc
```

You can make this file available publicly, such as on your website.

!!! note "Thanks"
    Thank you to Cole Helsell for drafting this guide with me.
