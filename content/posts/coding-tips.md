---
title: "Coding tips"
date: 2021-02-13:34:22-08:00
draft: false
slug: coding-tips
---

A note to myself about things I’ve learned over the years.

- Don’t write “programs” – treat all code as an API.
- Sketch out an interface, then write the tests, then write the code.
- It’s ok to hack something together, but it still needs to work. You should fix it later.
- Wrap dependencies on complex systems into [facades](https://en.wikipedia.org/wiki/Facade_pattern)
  so that your code interacts through that facade.
- New tools really do tend to be better. Older systems often become ridiculously complex and hard
  to configure. For example, [Caddy](https://caddyserver.com/) is a fantastic swap‐in for httpd
  for 99% of applications.
- Strong typing is uniformly better than dynamic typing. The latter encourages
  programming malpractice, inefficient code, and silent bugs.
- Objects should be immutable unless mutability is clearly needed.
- Nullity is the enemy. Don’t allow null values unless you’ve made that clear and the meaning
  of a null value is clear.
- Avoid inheritence like the plague. Traits and interfaces are ok.
- Don’t use concurrency based on shared memory unless you’re writing firmware.
- Functional programming is fantastic.
- Don’t [over‐engineer](https://github.com/jezen/is-thirteen).
- Don’t use libraries with low traction or too few GitHub stars.
- Write comments to document tricky points, not because it’s a “good practice”. There can be entire
  classes that don’t need more than a class header. If you write unnecessary comments, you’ll
  likely end up with comments describing behavior that no longer exists, which can do real harm.
- It’s sometimes ok to copy a few lines to avoid an unwanted dependency.
- Think about the layers that your code has and don’t mix layers.
- Use config files and/or environment variables for dependency injection.
- [Property testing](https://en.wikipedia.org/wiki/Property_testing) is amazing. I’ve found bugs
  that would otherwise be almost impossible to find.

