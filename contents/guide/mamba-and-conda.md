<!--
SPDX-FileCopyrightText: Copyright 2017-2024, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Mamba and Conda setup

!!! warning

    I have recommended against the Conda/Mamba ecosystem for many years.
    Consider using the PyPi ecosystem and tools like
    [uv](https://docs.astral.sh/uv/) and [Hatch](https://hatch.pypa.io/)
    instead.
    Refer to [“retooling Python builds”](../post/retooling-python-builds.md)
    for a detailed explanation and further recommendations.

These instructions should work on Linux, macOS, and Windows.

## Install and configure Micromamba

[Install Micromamba](https://mamba.readthedocs.io/en/latest/micromamba-installation.html).
Then add this to `~/.condarc`:

```yaml
ssl_verify: true
auto_activate_base: true
auto_update_conda: true
pip_interop_enabled: false #(1)!
channel_priority: strict #(2)!

channels:
  - conda-forge #(3)!
```

1. This feature is extremely slow and often doesn’t work anyway.
2. Do not use the default channel.
3. Only list conda-forge.

## Create a build environment

Create an environment for just building and packaging Python projects.

```bash
conda create \
  --name build \
  --force \
  --yes \
  python=3.11

conda activate build
pip install poetry hatch tox pytest pytest-cov
```

## Create a playground environment

You can add packages in here and wreck it.
If it’s ruined, just rebuild by running the same command.

Add and remove packages at the bottom as needed.

```bash
conda create \
  --name ds \
  --force \
  --yes \
  python=3.13 \
  numpy \
  pandas[performance,computation,parquet,feather,excel,compression] \
  polars[numpy,pandas,pyarrow] \
  pytorch scikit-learn tensorflow-gpu keras opencv3 \
  jupyterlab ipympl nb_conda_kernels plotly

conda activate ds
```

!!! bug

    If you are on Windows, add `pywin32` and `pywinutils`.
    Some versions of [pywin32 have issues](https://github.com/mhammond/pywin32/issues/1431),
    and the PyPi pywin32 package version 300 is broken.
    You may need to run `/path/to/your/environment/pywin32_postinstall.py -install` after.

## Configure Jupyter

Copy this to `~/.jupyter/jupyter_lab_config.py`:

```python
from pathlib import Path

c.ServerApp.root_dir = str(Path.home())
c.ServerApp.token = ""
c.ServerApp.password = ""
c.ServerApp.port = 8888
c.ServerApp.port_retries = 0
c.ServerApp.autoreload = False
```

Run a Jupyter server:

```bash
jupyter lab --no-browser &!
```

(The `&!` will keep it running even when the session quits.)
There’s no reason to set a password: It’s unlikely to add any security, and you shouldn’t rely on it.
Instead, if you want to access Jupyter remotely, use an SSH tunnel.
First, make sure to set up SSH keys to your server.
Now open the tunnel by running

```
ssh -L 8899:localhost:8888 myservername
```

Then leave that open and go to: `https://localhost:8899`.
Now you can lose the connection and your notebooks will still be there.

## Build real packages

The playground environment is your unreliable _I don’t care_ workspace.

You should use an isolated build procedure whenever you care about reproducibility.
Your project should list dependencies with version ranges and be rebuilt from scratch on each build.

Unfortunately, Conda’s dependency solver is buggy bugs, and Conda provides far fewer packages than PyPi.
Unfortunately, [mixing Conda and pip](https://www.anaconda.com/blog/understanding-conda-and-pip)
is problematic and can result in undetected dependency conflicts and package clobbering.
