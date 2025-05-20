# Retooling Python builds

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

The landscape of Python build infrastructure is a mess.
I made over 100 commits to get a sensible, elegant, and secure build.
It took too long, but here’s the
**[example repository :fontawesome-solid-code:](https://github.com/dmyersturnbull/tyranno-sandbox)**

## Compared to other languages

In 2014 and 2015, I was mostly writing in Java and Scala.
In Java, there are two widely used build tools: Maven and Gradle.
They’re compatible and use the same repository.
To build your code, run `mvn package` or `gradle build`.
To add a dependency, add to `build.gradle` or `pom.xml`.
To test, run `mvn test` or `gradle test`.
In Scala, there’s just SBT. To compile your code, run `sbt build`.
To add a dependency, add to `build.sbt`.
To test, run `sbt test`.

## The state of Python build

But in Python, there’s setuptools, pip, virtualenv, pipenv, Poetry, and Conda.
There are wheels and eggs.
There are `setup.py`, `setup.cfg`, `pyproject.toml`, `requirements.txt`, `Piplock`,
`meta.yaml`, `environment.yml`, and `poetry.lock` — any of which can list dependencies.
`tox.ini` can contain its own dependencies.

More importantly, the traditional tools have serious problems.
To start, a `setup.py` can contain arbitrary code.
This is a serious
[security problem](https://www.zdnet.com/article/twelve-malicious-python-libraries-found-and-removed-from-pypi/)
and makes it impossible to get some metadata from a package before installing it.

Suppose you’re writing a project to show a dependency tree.
Well, you can’t.

### Pip

This is not how any reasonable modern build tool should operate.
Moreover,
[Pip doesn’t resolve dependencies](https://github.com/pypa/pip/issues/988)
or identify conflicts.
`requirements.txt` are especially bad: They’re order‐dependent and clobber earlier dependencies.
And if they’re run in parallel, builds become stochastic.

### Conda

Conda came after Pip.
In contrast to pip/setuptools,
Anaconda/Conda performed dependency resolution, specified package metadata,
easily linked C/C++, and tailored to scientific computing, drawing a specialized audience.
But Conda has multiple channels, lacks many packages, fights with pip,
falsely claims there are dependency conflicts, and can take literally hours large dependency graph,
only to balk with an incorrect complaint.
In fairness,
[Poetry’s resolver can be slow](https://python-poetry.org/docs/faq/)
due to a flaw in PyPi.

Conda can resolve dependencies correctly.
Unfortunately, many packages are not on Anaconda or Conda-Forge
and some recipes are unmaintained and out‐of‐date.
[Anaconda can corrupt itself](https://github.com/ContinuumIO/anaconda-issues/issues/11336).
I just wrote a
[StackOverflow answer](https://stackoverflow.com/a/61624747)
regarding this.

### Wheels, pipx, uv, Poetry, and Hatch

_**Update**: Fast-forward to 2025:_ Check out [uv](https://docs.astral.sh/uv/), too.

_Fast-forward to 2023:_
Pip now performs some dependency resolution – although it’s slow and somewhat unreliable.
Hatch, Poetry, and pipx fully resolve dependency DAGs.
These are way faster than Conda, are more clear about dependencies,
don’t fail on resolvable graphs, and are more reliable and easier to use.

Additionally, there are [wheels](https://pythonwheels.com/)!
Python [wheels](https://pythonwheels.com/)
are prebuilt, platform-specific packages which are distributed through PyPi.
They can be statically linked with compiled C/C++ libraries.
[Rdkit was a hold-out](https://github.com/rdkit/rdkit/issues/1812),
distributing prebuilt packages only for Conda.
They now provide wheels under [rdkit-pypi](https://github.com/kuelumbus/rdkit-pypi).

So, you can stop using Conda.
If needed, install [mambaforge](https://github.com/conda-forge/miniforge#mambaforge).
See [this Mambaforge setup guide](../guide/mamba-and-conda.md)

## A nice build

Getting the
**[example repository](https://github.com/dmyersturnbull/tyranno-sandbox)**
working perfectly took me an unacceptable number of hours.
You can go ahead and copy it to avoid that special kind of hell.

It primarily uses [Hatch(ling)](https://hatch.pypa.io/) and [uv](https://docs.astral.sh/uv/).
The repo also contains a suite of useful
[GitHub workflows](https://help.github.com/en/actions)
for cross-platform testing, publishing packages/docs/images, generating release notes, and more.
