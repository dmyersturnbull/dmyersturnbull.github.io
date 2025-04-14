""" """

from packaging.specifiers import SpecifierSet
from packaging.version import Version

for vr, spec in [
    ("0.6.0", "~=0.5.0"),
    ("0.6.0", "~=0.5"),
    ("0.6.0.dev1", "~=0.5"),
    ("0.5.0.dev1", "~=0.5"),
    ("1.1.0.a1", ">=1.0"),
    ("1.1.0.a1", ">=1.1.0a0"),
    ("1.1.0.rc0", ">=1.1.0.dev0"),
    ("1.1.0", ">=1.1.0a0"),
]:
    match = Version(vr) in SpecifierSet(spec)
    print(f"{'✔' if match else '✘'}  {vr:<10} {spec:<10}")
