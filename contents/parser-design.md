# Parser design

**TL; DR: Your parser doesn’t need to do any IO.**

This is a _draft_.

In 2015, I wrote parsers for the genomics formats VCF and BED.
I rewrote them a few months later and ended up with robust parsers for some 1990s formats
in [genomics-io](https://github.com/dmyersturnbull/genomics-io).
Also refer to the
[interface segregation principle](https://en.wikipedia.org/wiki/Interface_segregation_principle).
