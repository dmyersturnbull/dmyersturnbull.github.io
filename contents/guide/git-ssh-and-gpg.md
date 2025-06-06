---
tags:
  - Git
  - OS-setup
  - security
---

# Git, SSH, and GPG

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

These instructions should work for Linux, macOS, and Windows.

!!! prerequisites

    Install Git, SSH, GPG, and the [GitHub CLI](https://cli.github.com/) before proceeding.
    Follow the
    [Linux setup guide](macos.md),
    [macOS setup guide](macos.md),
    or [Windows setup guide](windows.md).

## Configure Git

Configure your username and email:

```bash
git config --global user.name "your-username"
git config --global user.email "email-associated-with-github@address.tld"
```

To clone with https, you may need to add the
[git https helper](https://stackoverflow.com/q/8329485).
Run `sudo apt install libcurl4-openssl-dev ` in Ubuntu or `dnf install curl-devel` in Fedora.
I haven’t seen this problem on macOS or Windows.

Also set these config options:

!!! info "`git gc` and `git maintenance`"

    [`git gc --auto`](https://git-scm.com/docs/git-gc)
    is run by many Git commands, such as `git push`.
    `--auto` tells it to decide whether to run by simple rules, including the number of loose objects.
    The much newer [`git maintenance`](https://git-scm.com/docs/git-maintenance)
    employs different strategies, mostly running incrementally and on schedules.
    You can enable it per repository, which normally disables `gc.auto`.
    High-level documentation is limited as of early 2025.

```bash
# Options for `git gc --auto`.
# Repack if there are > 1000 loose objects (instead of 6700).
git config --global gc.auto 1000
```

## Configure SSH and set up keys

??? background

    SSH keys provide asymmetric cryptography for securing your
    connections. In asymmetric cryptography, there are two keys: a public one and a private one.
    The public key encrypt messages, while the private one is needed to decrypt them.
    This means that you could send your public key out to everyone.
    But your private key must remain on your computer and be secure.
    For historical reasons, SSH, OpenSSL, and GPG provide independent mechanisms,
    but they’re similar.

These steps cover hardening SSH, generating keys, adding a key to GitHub.

### _(If needed)_ Fix SSH permissions

Permissions in `~/.ssh/` need to be set precisely.
If they got messed up, use this to fix them:

```bash
chmod 600 "~/.ssh/*"
chmod 700 "~/.ssh/"
[[ -e "~/.ssh/config" ]] && chmod 700 "~/.ssh/config"
[[ -e "~/.ssh/known_hosts" ]] && chmod 700 "~/.ssh/known_hosts"
chmod 644 "~/.ssh/*.pub"
[[ -e "~/.ssh/authorized_keys" ]] && chmod 644 "~/.ssh/authorized_keys"
```

### Configuring the SSH client

The following instructions will

- Disable SSH agent forwarding,
  [which](https://security.stackexchange.com/questions/101783/are-there-any-risks-associated-with-ssh-agent-forwarding)
  [is](https://en.wikipedia.org/wiki/Ssh-agent#Security_issues)
  [very](https://github.com/microsoft/vscode-remote-release/issues/1222)
  [insecure](https://manpages.debian.org/buster/openssh-client/ssh.1.en.html#A)
  (disabled by default on most systems).
- Disable X forwarding, which also has
  [security concerns](https://security.stackexchange.com/questions/14815/security-concerns-with-x11-forwarding)
  (disabled by default on most systems).
- Tell the SSH agent to automatically add keys found in `~/.ssh/`.
- Tell macOS to use your keychain (ignored on other platforms).
  **Note:** This only applies to the OpenSSH variant that ships with macOS.
  I recommend replacing that software by running `brew install openssh`.
- Tell the client to try to keep connections alive.

!!! info "Important: How SSH reads `.ssh/config`"

    The
    [ssh config docs](https://manpages.debian.org/bookworm/openssh-client/ssh_config.5.en.html)
    ([man7 link](https://man7.org/linux/man-pages/man5/ssh_config.5.html))
    neglect to state this explicitly:
    **Options declared at the top of the file** – specifically, before any `Host` specification –
    **are global and non-overridable**.
    This is distinct from putting them under `Host *`.

    SSH merges config option–value pairs from all Host specifications that match.
    If two matching specifications set an option, the **first** takes precendent.
    So, follow this order:

    1. `ForwardAgent no`, etc. (no `Host`)
    2. `Host github.com`, `Host server1.puppy-rescue.org`, etc.
    3. `Host *.puppy-rescue.org` and other globs
    4. `Host *` for defaults

#### Global, non-overridable options

First, create `~/.ssh/config` doesn’t exist.
Add these lines at the **top** of the file:

```text
ForwardAgent no            # Disable SSH agent forwarding, which is insecure
ForwardX11 no              # Disable X11 forwarding, which is insecure
ForwardX11Trusted no       # Restrict X11 access (this line is probably redundant)
AddKeysToAgent yes         # Automatically add discovered keys to the agent
IgnoreUnknown UseKeychain  # Let Linux ignore this macOS/BSD-specific key
UseKeychain                # Tell macOS SSH to use the system keychain
```

#### Defaults for connection timeouts

Next, you can set defaults to keep connections alive for longer, subject to server policy.
You can instruct the client to send TCP `KeepAlive` packets periodically
by adding this section to the **end** of the file:

```text
Host *
ServerAliveInterval 60  # If no data was received for 1 minute, send a KeepAlive.
ServerAliveCountMax 360 # If no KeepAlive response was received, retry up to 360 times.
```

### Generate keys for GitHub

Using SSH to access a GitHub repository is preferable to using HTTPS
where authenticating via the GitHub API or installing the GitHub CLI would be difficult.
You’ll need to generate an SSH key pair and tell GitHub about it.

!!! info "See also"

    For extended instructions with explanations, see
    [GitHub’s SSH instructions](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/).

1. Generate a new SSH key pair, named `github`, by running this command.
   Use a reasonable passphrase.
   It doesn’t need to be overly strong; rely on
   keeping your private key safe and promptly revoking it if suspect it was is compromised.

   ```bash
   ssh-keygen -t ed25519 -C "kerri.johnson@gmail.com" -f ~/.ssh/github
   ```

2. Add it to the SSH agent immediately.
   (This might not be necessary if `AddKeysToAgent` is enabled.)

   ```bash
   $ eval "$(ssh-agent -s)"
   ```

3. Add a section to your config file.
   If your name is Kerri Johnson and you use `kerri.johnson@gmail.com` on GitHub,
   add this to the **middle** of `~/.ssh/config`:

   ```
   Host github github.com
   HostName github.com
   User kerri.johnson@gmail.com
   PreferredAuthentications publickey
   IdentityFile ~/.ssh/github
   ```

4. Send the key to GitHub.

   Using the GitHub CLI, run (choosing a better `title`):

   ```bash
   gh ssh-key add ~/.ssh/github.pub --type authentication --title personal
   ```

   Alternatively, go to [`https://github.com/settings/ssh/new`](https://github.com/settings/ssh/new)
   (as of 2025-01) and paste the contents of `~/.ssh/github.pub`.

### _(If needed)_ Connect to another remote host

!!! bug "Bug: Servers lacking EdDSA support"

    Some servers might not support EdDSA yet.
    If this is the case, generate another pair of keys:
    ```bash
    ssh-keygen -t rsa -b 4096 -o -a 100 -T ~/.ssh/id_rsa
    ```
    Replace `id_ed25519` with `id_rsa` in these instructions.

Follow these steps if you need to add a host other than GitHub.

When you first connect, you’ll see something like this:

```text
The authenticity of host '122.152.98.56' can't be established.
ED25519 key fingerprint is SHA256:RiB+VjEoRmclYEhNfn0iZ3E4X1xUM2N0OSV6azdsTDw.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

Verify it by running this on the remote machine and comparing the strings:

```bash
ssh-keygen -l -f /etc/ssh/ssh_host_ed25519_key.pub
```

Then, add a section to the **middle** of your `~/.ssh/config`:

```
Host lab
HostName my.server.x
User kelly
IdentityFile ~/.ssh/id_ed25519
```

Finally, use `ssh-copy-id` to transfer your key to the server’s authorized_keys.
Using the example above, run `ssh-copy-id -i ~/.ssh/id_ed25519 lab`.
(If you’re not a sysadmin, ask before doing this.)

### _(If needed)_ sshd server to allow remote access

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

    Toggle _Settings ➤ General ➤ Sharing ➤ Remote Login_.

=== "Windows"

    Navigate to _Settings ➤ Optional Features ➤ OpenSSH server_.

## Enabling commit signatures

### Sign with SSH – **NOT recommended**

!!! warning

    Doing this has no significant advantages, is more limited, and may be less secure.
    Unless you’re sure, proceed to the GPG instructions below.

As of August 2022, GitHub supports
[signing with SSH keys](https://github.blog/changelog/2022-08-23-ssh-commit-verification-now-supported/).
This is an alternative to signing with GPG keys.

If you really want to do this, run

```bash
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/github
git config --global commit.gpgsign true
```

**Note:** Although the config keys are `gpg.format` and `gpg.format`, it will actually use SSH.

### Generate GPG keys

Also see
[GitHub’s guide](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key)
to generating GPG keys.
You may consider using an [`@users.noreply` email address](https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-email-preferences/setting-your-commit-email-address)
per their suggestion.

1.  Install GPG:

    === "Ubuntu"

        `sudo apt install gnupg`

    === "Fedora"

        `sudo dnf install gnupg`

    === "macOS"

        `brew install gnupg`

    === "Windows"

        `choco install gnupg` (as an administrator)

2.  Launch gpg-agent by running

    ```bash
    gpg-connect-agent reloadagent /bye
    ```

3.  Then, generate a key pair by running

    ```bash
    gpg --full-generate-key
    ```

    Use the strongest algorithms.
    As of 2024, those are `ECC (sign and encrypt)` followed by `Curve 25519`.
    If GPG is up-to-date, these should be the default.

4.  Follow the rest of the instructions.
    Choose a reasonable expiration date (e.g. 1 year),
    set a passphrase (but don’t rely on it),
    and use the full name and the email address you used on GitHub,

### Tell Git to use your GPG key

You can use the GitHub CLI for this.
To see your generated key pair, run

```bash
gpg --list-keys --keyid-format long
```

```asc
sec   ed25519 2023-11-04 [SC] [expires: 2025-11-03]
      983C8320158FBB03818D3910C01A28311C1501SH
uid           [ultimate] Kerri Johnson <kerri-johnson@hotmail.com>
ssb   cv25519 2023-11-04 [E] [expires: 2025-08-03]
```

Check the type: `pub` is public; `sec` is your private key.
**Here, we want `sec`.**
If you have multiple keys, make sure to select the one you want.

`983C8320158FBB03818D3910C01A28311C1501SH` is your private key ID.
(Note: There may be a prefix, using `/` as a seperator. If so, ignore it.)
Using it, run:

```bash
git config --global --unset gpg.format
git config --global commit.gpgsign true
git config --global user.signingkey 983C8320158FBB03818D3910C01A28311C1501SH
```

### Send the GPG key to GitHub

Using your secret key ID, run this to write a temporary file called `github.key.private.gpg`:

```bash
gpg --armor \
  --export 983C8320158FBB03818D3910C01A28311C1501SH \
  --output key.private.gpg
```

Then upload to GitHub by running the following (choosing a better `title`):

```bash
gh gpg-key add key.private.gpg --title personal
```

Delete the `github.key.private.gpg` file when done.

### Optionally, publicize your public key

!!! note "Important"

    This assumes that you used a real email address, not a `@users.noreply.github.com` address.

You can put your public key on your website, include it in email signatures, etc.

First, list your public keys by running

```bash
gpg --list-keys --keyid-format long
```

You’ll see this:

```asc
pub   ed25519 2023-11-04 [SC] [expires: 2025-11-03]
      AC03281HD01A83C8DD50A9BEAA130FA03599207C
uid           [ultimate] Kerri Johnson <kerri.johnson@hotmail.com>
sub   cv25519 2023-11-04 [E] [expires: 2025-11-03]
```

!!! danger

    Make sure you are using your public (`pub`) key, not your private key (`sec`).

Check the type: `pub` is public; `sec` is your private key.
**Here, we want `pub`.**
Using your public key ID, run the following to get a key file called `kerri-johnson.pub.asc`,
which you can put wherever you want:

```bash
gpg --armor \
  --export AC03281HD01A83C8DD50A9BEAA130FA03599207C \
  --output kerri-johnson.asc
```

---

_Credits: Cole Helsell drafted the original version of this guide with me._
