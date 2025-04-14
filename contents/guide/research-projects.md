# Research projects

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

There are some great resources on good data organization, such as the
[OSF’s guide](https://help.osf.io/article/147-organizing-files).
Here, I’ll document the aspects of my protocols that work well.

## Main ideas

**✅ DO:**
Designate data as either **_living_ or _frozen_**.
Code should never read from living files and should never write to frozen files.

**✅ DO:**
Indicate manually curated / edited data as such.
When ready, make a frozen copy and add a timestamp.
Let scripts read the frozen copy.

**❌ DO NOT:**
Have scripts read living data.

**❌ DO NOT:**
Just organize into `input/` and `output/` directories.

**✅ DO:**
Store basic machine-readable metadata alongside the data.
(Don’t store information that can change, such as comments, project names, or people’s names.)

**✅ DO:**
Reorganize your files if your current structure isn’t working.

## Example

```bash
├── src/
│ └── pkg/
│ ├── __init__.py
│ ├── generate_raw_name_mapping.py
│ └── analyze.py
├── data/
│ ├── temp-output/
│ ├── raw-name-mapping.tsv
│ └── figures/
│ ├── living/
│ │ ├── name-mapping.tsv
│ │ └── figures/
│ │ │ └── samples.pdf
│ └── frozen/
│ ├── name-mapping-2022-01-14.tsv
│ ├── microscopy/
│ │ └── 20220615T164555.confocal3
│ │ ├── 20220615T164555.confocal3.tif
│ │ └── 20220615T164555.confocal3.json
│ └── reference/
│ └── weird-sample-analysis-2022-01-24.ipynb
│ └── weird-samples-2022-01-24.pdf
└── README.md
```

Here, `temp-output/` and `living/` both contain living data.
`temp-output/` can be overwritten any time, while `living/` contains manually curated files.
You should probably avoid checking `output/` into a repository.

### How the layout is used

`src/pkg/generate_raw_name_mapping.py` outputs `data/temp-output/raw-name-mapping.tsv`.
Maybe it maps microscope filenames to sample names, but that mapping can’t be fully automated.
So, we copy to `data/living/name-mapping.tsv` and edit it.
When we’re done, we copy it to `data/frozen/name-mapping-2022-01-14.tsv`.

We then run `src/pkg/analyze.py`, which outputs figures to `data/temp-output/figures/`.
They need a little tweaking, so we copy each to `living/figures/` and align labels, etc.
Or maybe we combine several figure panels into full figures.
We want to keep this exact analysis, so we copy it to `data/frozen/reference/`.
And we write a script to generate that figure (in this case, a Jupyter notebook).
The script writes to `data/temp-output/` (**not** `data/frozen`).

### JSON metadata

What's in `20220615T164555.confocal3.json`?

```json
{
  "id": "20220615T164555.confocal3",
  "instrument": "confocal3",
  "instrument-type": "microscope",
  "datetime": "2022-06-15T16:45:55",
  "duration-ms": 185.225075,
  "roi": {
    "type": "rectangle",
    "values": {
      "top": 4101,
      "bottom": 4358,
      "left": 528,
      "right": 744
    }
  }
}
```

## Further information

- [Ten simple rules for reproducible computational research](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1003285)
- [A quick guide to organizing computational biology projects](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1000424)
