# Python infrastructure

**The landscape of Python build infrastructure is a mess.**
I made over 100 commits to get a sensible, elegant, and secure build.
The result is a template project and tool called
[Tyrannosaurus](https://github.com/dmyersturnbull/tyrannosaurus).

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

This is not how any reasonable modern build tool should operate.
Moreover, Pip [does not resolve dependencies](https://github.com/pypa/pip/issues/988) or identify conflicts.
A `requirements.txt` is especially bad because it’s order‐dependent and might be run in parallel, making it stochastic.

Conda can resolve dependencies correctly.
Unfortunately, many packages are not on Anaconda or Conda-Forge, and some recipes are unmaintained and out‐of‐date.
[Anaconda can corrupt itself](https://github.com/ContinuumIO/anaconda-issues/issues/11336).
I just wrote a
[StackOverflow answer](https://stackoverflow.com/questions/61624631/using-anaconda-is-a-messy-base-root-going-to-be-a-problem-in-the-long-term/61624747#61624747)
regarding this.

## Finally a nice build

It took me an unacceptable number of hours and commits.
I’d change, push, wait for CI failures, and repeat.
To help others avoid that build hell, I set up a [template repository](https://github.com/dmyersturnbull/tyrannosaurus).

It heavily uses [Poetry](https://python-poetry.org/), [Tox](https://tox.readthedocs.io/en/latest/),
[GitHub actions](https://help.github.com/en/actions), and adds a package that syncs metadata (tyrannosaurus).
It doesn’t contain a `setup.py` or `setup.cfg`.
In fact, `pyproject.toml` is the only file that contains metadata to edit.
When you run `tox` (or `tyrannosaurus sync`), metadata is copied from `pyproject.toml` to other files,
such as `docs/requirements.txt`, `tox.ini`, `__init__.py`, `codemeta.json`, `meta.yaml`, and `environment.yml`.
So if you add a contributor, keyword, or dependency, it will be reflected everywhere.

When you push, it builds wheels, sdists, and a Docker image, and runs tests.
It lints on commit using [pre-commit](https://pre-commit.com/).
When you tag on GitHub, it publishes to PyPi and Docker Hub.
Getting your package initially on [Conda-Forge](https://conda-forge.org/) takes a
[few manual steps](https://tyrannosaurus.readthedocs.io/en/latest/usage.html#anaconda-recipes).

Run `pip install tyrannosaurus` and create a new project with `tyrannosaurus new`. Then
[check these steps](https://tyrannosaurus.readthedocs.io/en/latest/guide.html#to-do-list-for-new-projects) to finalize.

See [Tyrannosaurus here](https://github.com/dmyersturnbull/tyrannosaurus).
