---
title: "New data science steps with Python"
date: 2020-10-30:10:00-08:00
draft: false
slug: data-science-setup
---

Here are steps for a typical initial setup for data science in Python.  
I’ve given similar instructions so much that I figured I’d write this down.

*Note:* These instructions should work on Linux, macOS, and Windows.
I recommend following the [Linux setup guide](https://dmyersturnbull.github.io/linux-setup/),
[macOS setup guide](https://dmyersturnbull.github.io/macos-setup/) or
[Windows setup guide](https://dmyersturnbull.github.io/windows-setup/) first.


### Install Miniconda

Miniconda is a much better choice than Anaconda.  
You don’t want to use your root environment anyway, so don’t bother with all of those extra packages.
Never install packages in your root environment.

```bash
curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh
chmod u+x miniconda.sh
./miniconda.sh
```

(On macOS and Windows, the graphical installers (.pkg and .msi) are good.)

Then, add this to `~/.condarc`:

```yml
ssl_verify: true
auto_activate_base: false
pip_interop_enabled: false
channel_priority: strict
auto_update_conda: true

channels:
  - conda-forge
```

The rationale is:
- `auto_activate_base` means you start in your environment (instead of the OS default).
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
First, make sure to set up SSH keys to your server.
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


### Final info

- You may need to install the [Rust toolchain](https://rustup.rs/), and the conda package may not be sufficient.
- Will Connell has a nice, hands-on [tutorial for git and conda](https://github.com/wconnell/intro-comp-wrkflw/blob/master/tutorial.txt).
- Read [Organization for research projects](https://dmyersturnbull.github.io/research-layout/)
- Read [Ten simple rules for reproducible computational research](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1003285)
- Read [A quick guide to organizing computational biology projects](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1000424)
