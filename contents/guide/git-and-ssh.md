# Git, SSH, and GPG guide

These instructions should work for Linux, macOS, and Windows.

## Generate SSH keys

!!! abstract "What you’ll be doing"
    SSH keys provide asymmetric cryptography for securing your
    connections. In asymmetric cryptography, there are two keys: a public one and a private one.
    The public key encrypt messages, while the private one is needed to decrypt them.
    This means that you could send your public key out to everyone.
    But your private key must remain on your computer and be secure.
    For historical reasons, SSH, OpenSSL, and GPG provide independent mechanisms, but they’re similar.

## 1. [Generate a new SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key)
## 2. [Add it to the ssh-agent](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent)
## 3. [Add it to GitHub](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

## 4. Configure Git

Configure your username and email:

```bash
git config --global user.name "your_username"
git config --global user.email "email_used_for_github@address.tld"
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519
git config --global commit.gpgsign true
```

!!! note
    Although it's the config keys are called 'gpg', it's actually using SSH.

To clone with https, you may need to
[add the git https helper](https://stackoverflow.com/questions/8329485/unable-to-find-remote-helper-for-https-during-git-clone).
Run `sudo apt install libcurl4-openssl-dev ` in Ubuntu or `dnf install curl-devel` in Fedora.

## 5. Configure SSH

!!! abstract "About these steps"
    Disable SSH agent forwarding, [which](https://security.stackexchange.com/questions/101783/are-there-any-risks-associated-with-ssh-agent-forwarding)
    [is](https://en.wikipedia.org/wiki/Ssh-agent#Security_issues)
    [very](https://github.com/microsoft/vscode-remote-release/issues/1222)
    [insecure](https://manpages.debian.org/buster/openssh-client/ssh.1.en.html#A).
    Also disable X forwarding, which also has [security concerns](https://security.stackexchange.com/questions/14815/security-concerns-with-x11-forwarding).
    You’re unlikely to need either.

Create or edit `~/.ssh/config`. Replace the contents with the following.

```
AddKeysToAgent yes
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

## Set up connections to another server

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


## Set up GPG keys

!!! warning
    You probably don't need this. As of August 2022, GitHub now supports
    [signing with SSH keys](https://github.blog/changelog/2022-08-23-ssh-commit-verification-now-supported/).

Install GPG: `apt install gnupg` or `dnf install gnupg`.
Then:

```
gpg --full-generate-key -t ed25519
```

Move your mouse or type some keys to help the pseudorandom number generator.
As with SSH keys, you may choose to use a passphrase.

Then follow GitHub’s guide to [add the GPG key to your account](https://docs.github.com/en/github/authenticating-to-github/adding-a-new-gpg-key-to-your-github-account).
The steps are: copy the output of
`gpg --list-secret-keys --keyid-format LONG` to GitHub.
Among other things, this will allow you to
[sign your commits](https://docs.github.com/en/github/authenticating-to-github/signing-commits): run
`git config --global commit.gpgsign true`.

!!! note
    Thank you to Cole Helsell for drafting this guide with me.
