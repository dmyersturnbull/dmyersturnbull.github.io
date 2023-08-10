# Research layout

!!! warning
This document is not finished.

There are some great resources on good data organization, such as the
[OSF’s guide](https://help.osf.io/hc/en-us/articles/360019738994-Organizing-files).
Here, I’ll document the aspects of my protocols that work well.

## Living and frozen data

!!! success "DO"
Designate data as either living or frozen. - Frozen data can never be changed. - Living data can be updated.
Code should never read these files directly.
Instead, copy living data into frozen files and timestamp them.

!!! failure "DO NOT"
Organize into `input/` and `output/` directories.
One source file’s input is another’s output.

## Example layout

```bash
├── src
│   └── pkg/
│       ├── __init__.py
│       ├── generate_name_mapping.py
│       └── analyze.py
├── data
│   ├── living/
│   │   ├── name-mapping.tsv
│   │   └── edited-figures/
│   └── frozen/
│       ├── name-mapping.tsv
│       ├── microscopy/
│       └── output-figures/
```
