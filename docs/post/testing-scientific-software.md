---
tags:
  - testing
  - science
  - coding
---

# Testing scientific software

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

This article is a plea for scientists who write code to test their software.

**Let’s get this out of the way – you must write tests.**

Tests are just as required in scientific software as in all other software.
_If you’re already convinced, skip this section._

!!! quote

    > Researchers are spending more and more time writing computer software to
    > model biological structures, simulate the early evolution of the Universe
    > and analyse past climate data, among other topics.
    > But **programming experts have little faith that most scientists are up to the task.**”
    ― [Merali 2010 (doi:10.1038/467775a)](https://pubmed.ncbi.nlm.nih.gov/20944712/) (bold added)

Here’s what happens:
[5 retractions in one lab due to a bug](https://science.sciencemag.org/content/314/5807/1856).
Yet because code is often not released and few others would bother to try to reproduce published
results, probably 90%+ of scientific software bugs remain uncaught.
A lack of deceptive intent doesn’t lessen the damage, and not testing is reckless.
**Not testing your software is as egregious a fault in scientific integrity as p‐hacking.**

On a software development team, you can’t push new code to a main branch without accompanying
tests – which must pass.
In fact, many good coders [write tests first](https://en.wikipedia.org/wiki/Test-driven_development),
before any other code.

Professional software developers are the world’s best coders, so the code they write presumably
has the lowest per‐line error rate.
Yet no decent programmer would trust themselves to write code that works without tests.
So why do scientists routinely write, use, and even publish on the basis of code without tests,
_code that is almost certainly faulty_?
Let’s not do that. You must write tests.

If you’re still not convinced, **let’s try a thought experiment.**
Count the number of times you’ve done this:

1. You run your code. It _raises an error_ or gives an unreasonable result.
2. You trace through to find the error and _fix the bug_.
3. Now your _code doesn’t error_ and _gives a reasonable result._

Each bug could _just as easily_ have not caused an error.
**This process does not make your code correct; it just selects for results that look reasonable.**
