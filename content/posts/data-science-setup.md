---
title: "New data science steps with Python"
date: 2020-10-30:10:00-08:00
draft: false
slug: data-science-setup
---

This is a *draft*.

Here are steps for a typical initial setup for data science in Python.  
I’ve given similar instructions so much that I figured I’d write this down.


### Install [Oh My Zsh](https://ohmyz.sh/)

You’ll thank me later. (You’ll need ZSH installed for this to work.)

```bash

chsh -s /usr/bin/env zsh
zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```


###  Configure Git

First, configure your username and email:

```bash
git config --global user.name "your_username"
git config --global user.email "your_email@address.tld"
```

Generate SSH keys if needed:

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_rsa
```

Save to the default location and skip adding a passphrase. After,
[add the SSH key to GitHub](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account).
If you don’t already have a GPG key somewhere, run this, skipping the passphrase:

```bash
gpg --full-generate-key
```

Now add the output from this into GitHub:

```bash
gpg --list-secret-keys --keyid-format LONG
```


### Install Miniconda

Miniconda is a much better choice than Anaconda.  
You don’t want to use your root environment anyway, so don’t bother with all of those extra packages.
Never install packages in your root environment.

```bash
curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod u+x Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh -b
```

**Note:** On macOS and Windows, just use the .pkg/.exe [Miniconda installers](https://docs.conda.io/en/latest/miniconda.html).

Then, add this to `~/.condarc`:

```yml
pip_interop_enabled: false
channel_priority: strict
auto_update_conda: true

channels:
  - conda-forge
```

The rationale is:
- `pip_interop_enabled` is extremely slow and often doesn’t work anyway
- `strict` `channel_priority` greatly reduces conflicts
- removing the `default` channel from `channels` ensures that only conda-forge is ever used



### Create a build environment

Create an environment for just building and packaging Python projects.
You can also install reasonable other build software like pytest, but don’t go overboard.
Only use this environment for building.

```bash
conda create \
  --name build \
  --force \
  --yes \
  python=3.9

conda activate build
pip install poetry tox
```


### Create an ML playground environment

You can add packages in here and wreck it.
If it’s ruined, just rebuild by running the same command.

Add and remove packages at the bottom as needed.

```bash
conda create \
  --name playground \
  --force \
  --yes \
  python=3.9 \
  jupyterlab numpy pandas pytorch scikit-learn tensorflow-gpu keras opencv3 \
  jupyter-lab ipympl nb_conda_kernels

conda activate playground
```

If you are on Windows, add `pywin32` and `pywinutils`.
Some versions of [pywin32 have issues](https://github.com/mhammond/pywin32/issues/1431),
and the PyPi pywin32 package version 300 is broken.
You may need to run `/path/to/your/environment/pywin32_postinstall.py -install` after. 


#### Configure Jupyter

Copy this to `~/.jupyter/jupyter_lab_config.py`:

```python
from pathlib import Path
c.ServerApp.root_dir = str(Path.home())
c.ServerApp.token = ''
c.ServerApp.password = ''
c.ServerApp.port = 8888
c.ServerApp.port_retries = 0
c.ServerApp.autoreload = False
```

Run a Jupyter server:

```bash
jupyter lab --no-browser &!
```

(The `&!` will keep it running even when the session quits.)
There’s no reason to set a password: It’s unlikely to add any security, and I wouldn’t rely on it.
Instead, if you want to access Jupyter remotely, use an SSH tunnel.  
First, make sure to set up SSH keys to your server. For that, run this on your client:

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
eval $(ssh-agent -s)
ssh-add ~/.ssh/id_rsa
ssh-copy-id
```

Now open the tunnel:

```
ssh -L 8899:localhost:8888 myservername
```

Then leave that open and go to: `https://localhost:8899`.
Now you can lose the connection and your notebooks will still be there.


#### Building real packages for production

The playground environment is your unreliable *I don’t care* workspace.

You should use an isolated build procedure for real projects, or whenever you care about
reproducibility. Your project lists exact dependency ranges and gets rebuilt from scratch
in a new virtualenv or conda env each build. That’s actually
[a normal procedure](https://dmyersturnbull.github.io/#-the-python-build-landscape) for most
compiled languages. For example, Scala’s [sbt](https://www.scala-sbt.org/) downloads and
caches dependencies listed in a `build.sbt` file, packaging them into your project.
Your projects don’t rely on a global environment that could change with a misplaced `conda`
or `pip install`.

You could make a conda environment each build, but Conda is slow, its dependency solver has bugs,
and it provides far fewer packages than PyPi. Unfortunately,
[mixing Conda and Pip](https://www.anaconda.com/blog/understanding-conda-and-pip)
is problematic and can result in undetected dependency conflicts and package clobbering.
Consider instead using [Poetry](https://python-poetry.org/), which has more accurate dependency
resolution, better performance, and access to all packages that are on PyPi or are distributed
in [wheels](https://pythonwheels.com/). You can use
[Tyrannosaurus](https://github.com/dmyersturnbull/tyrannosaurus) to generate projects that
have excellent [CI/CD](https://en.wikipedia.org/wiki/CI/CD) via Poetry,
[Tox](https://tox.readthedocs.io), and [GitHub Actions](https://github.com/features/actions):
`tyrannosaurus new myprojectname --track`.

