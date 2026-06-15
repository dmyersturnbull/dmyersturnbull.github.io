---
tags:
- Unicode
---

# Box-drawing

<!--
SPDX-FileCopyrightText: Copyright 2017-2026, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

This table uses 🗸, **✔**, and 🗸🗸 to indicate the styles of joints.

| Character | Codepoint | Shape            | Weight | Stroke | N     | S     | E     | W     | NE | NW | SE | SW |
|-----------|-----------|------------------|--------|--------|-------|-------|-------|-------|----|----|----|----|
| ─         | U+2500    | line (E+W)       | light  |        |       |       | 🗸    | 🗸    |    |    |    |    |
| ━         | U+2501    | line (E+W)       | heavy  |        |       |       | **✔** | **✔** |    |    |    |    |
| │         | U+2502    | line (N+S)       | light  |        | 🗸    | 🗸    |       |       |    |    |    |    |
| ┃         | U+2503    | line (N+S)       | heavy  |        | **✔** | **✔** |       |       |    |    |    |    |
| ┄         | U+2504    | line (E+W)       | light  | 3-dash |       |       | 🗸    | 🗸    |    |    |    |    |
| ┅         | U+2505    | line (E+W)       | heavy  | 3-dash |       |       | **✔** | **✔** |    |    |    |    |
| ┆         | U+2506    | line (N+S)       | light  | 3-dash | 🗸    | 🗸    |       |       |    |    |    |    |
| ┇         | U+2507    | line (N+S)       | heavy  | 3-dash | **✔** | **✔** |       |       |    |    |    |    |
| ┈         | U+2508    | line (E+W)       | light  | 4-dash |       |       | 🗸    | 🗸    |    |    |    |    |
| ┉         | U+2509    | line (E+W)       | heavy  | 4-dash |       |       | **✔** | **✔** |    |    |    |    |
| ┊         | U+250A    | line (N+S)       | light  | 4-dash | 🗸    | 🗸    |       |       |    |    |    |    |
| ┋         | U+250B    | line (N+S)       | heavy  | 4-dash | **✔** | **✔** |       |       |    |    |    |    |
| ┌         | U+250C    | corner (S+E)     | light  |        |       | 🗸    | 🗸    |       |    |    |    |    |
| ┍         | U+250D    | corner (S+E)     | mixed  |        |       | 🗸    | **✔** |       |    |    |    |    |
| ┎         | U+250E    | corner (S+E)     | mixed  |        |       | **✔** | 🗸    |       |    |    |    |    |
| ┏         | U+250F    | corner (S+E)     | heavy  |        |       | **✔** | **✔** |       |    |    |    |    |
| ┐         | U+2510    | corner (S+W)     | light  |        |       | 🗸    |       | 🗸    |    |    |    |    |
| ┑         | U+2511    | corner (S+W)     | mixed  |        |       | 🗸    |       | **✔** |    |    |    |    |
| ┒         | U+2512    | corner (S+W)     | mixed  |        |       | **✔** |       | 🗸    |    |    |    |    |
| ┓         | U+2513    | corner (S+W)     | heavy  |        |       | **✔** |       | **✔** |    |    |    |    |
| └         | U+2514    | corner (N+E)     | light  |        | 🗸    |       | 🗸    |       |    |    |    |    |
| ┕         | U+2515    | corner (N+E)     | mixed  |        | 🗸    |       | **✔** |       |    |    |    |    |
| ┖         | U+2516    | corner (N+E)     | mixed  |        | **✔** |       | 🗸    |       |    |    |    |    |
| ┗         | U+2517    | corner (N+E)     | heavy  |        | **✔** |       | **✔** |       |    |    |    |    |
| ┘         | U+2518    | corner (N+W)     | light  |        | 🗸    |       |       | 🗸    |    |    |    |    |
| ┙         | U+2519    | corner (N+W)     | mixed  |        | 🗸    |       |       | **✔** |    |    |    |    |
| ┚         | U+251A    | corner (N+W)     | mixed  |        | **✔** |       |       | 🗸    |    |    |    |    |
| ┛         | U+251B    | corner (N+W)     | heavy  |        | **✔** |       |       | **✔** |    |    |    |    |
| ├         | U+251C    | tee (N+S+E)      | light  |        | 🗸    | 🗸    | 🗸    |       |    |    |    |    |
| ┝         | U+251D    | tee (N+S+E)      | mixed  |        | 🗸    | 🗸    | **✔** |       |    |    |    |    |
| ┞         | U+251E    | tee (N+S+E)      | mixed  |        | **✔** | 🗸    | 🗸    |       |    |    |    |    |
| ┟         | U+251F    | tee (N+S+E)      | mixed  |        | 🗸    | **✔** | 🗸    |       |    |    |    |    |
| ┠         | U+2520    | tee (N+S+E)      | mixed  |        | **✔** | **✔** | 🗸    |       |    |    |    |    |
| ┡         | U+2521    | tee (N+S+E)      | mixed  |        | **✔** | 🗸    | **✔** |       |    |    |    |    |
| ┢         | U+2522    | tee (N+S+E)      | mixed  |        | 🗸    | **✔** | **✔** |       |    |    |    |    |
| ┣         | U+2523    | tee (N+S+E)      | heavy  |        | **✔** | **✔** | **✔** |       |    |    |    |    |
| ┤         | U+2524    | tee (N+S+W)      | light  |        | 🗸    | 🗸    |       | 🗸    |    |    |    |    |
| ┥         | U+2525    | tee (N+S+W)      | mixed  |        | 🗸    | 🗸    |       | **✔** |    |    |    |    |
| ┦         | U+2526    | tee (N+S+W)      | mixed  |        | **✔** | 🗸    |       | 🗸    |    |    |    |    |
| ┧         | U+2527    | tee (N+S+W)      | mixed  |        | 🗸    | **✔** |       | 🗸    |    |    |    |    |
| ┨         | U+2528    | tee (N+S+W)      | mixed  |        | **✔** | **✔** |       | 🗸    |    |    |    |    |
| ┩         | U+2529    | tee (N+S+W)      | mixed  |        | **✔** | 🗸    |       | **✔** |    |    |    |    |
| ┪         | U+252A    | tee (N+S+W)      | mixed  |        | 🗸    | **✔** |       | **✔** |    |    |    |    |
| ┫         | U+252B    | tee (N+S+W)      | heavy  |        | **✔** | **✔** |       | **✔** |    |    |    |    |
| ┬         | U+252C    | tee (S+E+W)      | light  |        |       | 🗸    | 🗸    | 🗸    |    |    |    |    |
| ┭         | U+252D    | tee (S+E+W)      | mixed  |        |       | 🗸    | 🗸    | **✔** |    |    |    |    |
| ┮         | U+252E    | tee (S+E+W)      | mixed  |        |       | 🗸    | **✔** | 🗸    |    |    |    |    |
| ┯         | U+252F    | tee (S+E+W)      | mixed  |        |       | 🗸    | **✔** | **✔** |    |    |    |    |
| ┰         | U+2530    | tee (S+E+W)      | mixed  |        |       | **✔** | 🗸    | 🗸    |    |    |    |    |
| ┱         | U+2531    | tee (S+E+W)      | mixed  |        |       | **✔** | 🗸    | **✔** |    |    |    |    |
| ┲         | U+2532    | tee (S+E+W)      | mixed  |        |       | **✔** | **✔** | 🗸    |    |    |    |    |
| ┳         | U+2533    | tee (S+E+W)      | heavy  |        |       | **✔** | **✔** | **✔** |    |    |    |    |
| ┴         | U+2534    | tee (N+E+W)      | light  |        | 🗸    |       | 🗸    | 🗸    |    |    |    |    |
| ┵         | U+2535    | tee (N+E+W)      | mixed  |        | 🗸    |       | 🗸    | **✔** |    |    |    |    |
| ┶         | U+2536    | tee (N+E+W)      | mixed  |        | 🗸    |       | **✔** | 🗸    |    |    |    |    |
| ┷         | U+2537    | tee (N+E+W)      | mixed  |        | 🗸    |       | **✔** | **✔** |    |    |    |    |
| ┸         | U+2538    | tee (N+E+W)      | mixed  |        | **✔** |       | 🗸    | 🗸    |    |    |    |    |
| ┹         | U+2539    | tee (N+E+W)      | mixed  |        | **✔** |       | 🗸    | **✔** |    |    |    |    |
| ┺         | U+253A    | tee (N+E+W)      | mixed  |        | **✔** |       | **✔** | 🗸    |    |    |    |    |
| ┻         | U+253B    | tee (N+E+W)      | heavy  |        | **✔** |       | **✔** | **✔** |    |    |    |    |
| ┼         | U+253C    | cross            | light  |        | 🗸    | 🗸    | 🗸    | 🗸    |    |    |    |    |
| ┽         | U+253D    | cross            | mixed  |        | 🗸    | 🗸    | 🗸    | **✔** |    |    |    |    |
| ┾         | U+253E    | cross            | mixed  |        | 🗸    | 🗸    | **✔** | 🗸    |    |    |    |    |
| ┿         | U+253F    | cross            | mixed  |        | 🗸    | 🗸    | **✔** | **✔** |    |    |    |    |
| ╀         | U+2540    | cross            | mixed  |        | **✔** | 🗸    | 🗸    | 🗸    |    |    |    |    |
| ╁         | U+2541    | cross            | mixed  |        | 🗸    | **✔** | 🗸    | 🗸    |    |    |    |    |
| ╂         | U+2542    | cross            | mixed  |        | **✔** | **✔** | 🗸    | 🗸    |    |    |    |    |
| ╃         | U+2543    | cross            | mixed  |        | **✔** | 🗸    | 🗸    | **✔** |    |    |    |    |
| ╄         | U+2544    | cross            | mixed  |        | **✔** | 🗸    | **✔** | 🗸    |    |    |    |    |
| ╅         | U+2545    | cross            | mixed  |        | 🗸    | **✔** | 🗸    | **✔** |    |    |    |    |
| ╆         | U+2546    | cross            | mixed  |        | 🗸    | **✔** | **✔** | 🗸    |    |    |    |    |
| ╇         | U+2547    | cross            | mixed  |        | **✔** | 🗸    | **✔** | **✔** |    |    |    |    |
| ╈         | U+2548    | cross            | mixed  |        | 🗸    | **✔** | **✔** | **✔** |    |    |    |    |
| ╉         | U+2549    | cross            | mixed  |        | **✔** | **✔** | 🗸    | **✔** |    |    |    |    |
| ╊         | U+254A    | cross            | mixed  |        | **✔** | **✔** | **✔** | 🗸    |    |    |    |    |
| ╋         | U+254B    | cross            | heavy  |        | **✔** | **✔** | **✔** | **✔** |    |    |    |    |
| ╌         | U+254C    | line (E+W)       | light  | 2-dash |       |       | 🗸    | 🗸    |    |    |    |    |
| ╍         | U+254D    | line (E+W)       | heavy  | 2-dash |       |       | **✔** | **✔** |    |    |    |    |
| ╎         | U+254E    | line (N+S)       | light  | 2-dash | 🗸    | 🗸    |       |       |    |    |    |    |
| ╏         | U+254F    | line (N+S)       | heavy  | 2-dash | **✔** | **✔** |       |       |    |    |    |    |
| ═         | U+2550    | line (E+W)       | light  | double |       |       | 🗸🗸  | 🗸🗸  |    |    |    |    |
| ║         | U+2551    | line (N+S)       | light  | double | 🗸🗸  | 🗸🗸  |       |       |    |    |    |    |
| ╒         | U+2552    | corner (S+E)     | light  | mixed  |       | 🗸    | 🗸🗸  |       |    |    |    |    |
| ╓         | U+2553    | corner (S+E)     | light  | mixed  |       | 🗸🗸  | 🗸    |       |    |    |    |    |
| ╔         | U+2554    | corner (S+E)     | light  | double |       | 🗸🗸  | 🗸🗸  |       |    |    |    |    |
| ╕         | U+2555    | corner (S+W)     | light  | mixed  |       | 🗸    |       | 🗸🗸  |    |    |    |    |
| ╖         | U+2556    | corner (S+W)     | light  | mixed  |       | 🗸🗸  |       | 🗸    |    |    |    |    |
| ╗         | U+2557    | corner (S+W)     | light  | double |       | 🗸🗸  |       | 🗸🗸  |    |    |    |    |
| ╘         | U+2558    | corner (N+E)     | light  | mixed  | 🗸    |       | 🗸🗸  |       |    |    |    |    |
| ╙         | U+2559    | corner (N+E)     | light  | mixed  | 🗸🗸  |       | 🗸    |       |    |    |    |    |
| ╚         | U+255A    | corner (N+E)     | light  | double | 🗸🗸  |       | 🗸🗸  |       |    |    |    |    |
| ╛         | U+255B    | corner (N+W)     | light  | mixed  | 🗸    |       |       | 🗸🗸  |    |    |    |    |
| ╜         | U+255C    | corner (N+W)     | light  | mixed  | 🗸🗸  |       |       | 🗸    |    |    |    |    |
| ╝         | U+255D    | corner (N+W)     | light  | double | 🗸🗸  |       |       | 🗸🗸  |    |    |    |    |
| ╞         | U+255E    | tee (N+S+E)      | light  | mixed  | 🗸    | 🗸    | 🗸🗸  |       |    |    |    |    |
| ╟         | U+255F    | tee (N+S+E)      | light  | mixed  | 🗸🗸  | 🗸🗸  | 🗸    |       |    |    |    |    |
| ╠         | U+2560    | tee (N+S+E)      | light  | double | 🗸🗸  | 🗸🗸  | 🗸🗸  |       |    |    |    |    |
| ╡         | U+2561    | tee (N+S+W)      | light  | mixed  | 🗸    | 🗸    |       | 🗸🗸  |    |    |    |    |
| ╢         | U+2562    | tee (N+S+W)      | light  | mixed  | 🗸🗸  | 🗸🗸  |       | 🗸    |    |    |    |    |
| ╣         | U+2563    | tee (N+S+W)      | light  | double | 🗸🗸  | 🗸🗸  |       | 🗸🗸  |    |    |    |    |
| ╤         | U+2564    | tee (S+E+W)      | light  | mixed  |       | 🗸    | 🗸🗸  | 🗸🗸  |    |    |    |    |
| ╥         | U+2565    | tee (S+E+W)      | light  | mixed  |       | 🗸🗸  | 🗸    | 🗸    |    |    |    |    |
| ╦         | U+2566    | tee (S+E+W)      | light  | double |       | 🗸🗸  | 🗸🗸  | 🗸🗸  |    |    |    |    |
| ╧         | U+2567    | tee (N+E+W)      | light  | mixed  | 🗸    |       | 🗸🗸  | 🗸🗸  |    |    |    |    |
| ╨         | U+2568    | tee (N+E+W)      | light  | mixed  | 🗸🗸  |       | 🗸    | 🗸    |    |    |    |    |
| ╩         | U+2569    | tee (N+E+W)      | light  | double | 🗸🗸  |       | 🗸🗸  | 🗸🗸  |    |    |    |    |
| ╪         | U+256A    | cross            | light  | mixed  | 🗸    | 🗸    | 🗸🗸  | 🗸🗸  |    |    |    |    |
| ╫         | U+256B    | cross            | light  | mixed  | 🗸🗸  | 🗸🗸  | 🗸    | 🗸    |    |    |    |    |
| ╬         | U+256C    | cross            | light  | double | 🗸🗸  | 🗸🗸  | 🗸🗸  | 🗸🗸  |    |    |    |    |
| ╭         | U+256D    | arc (S+E)        | light  |        |       | 🗸    | 🗸    |       |    |    |    |    |
| ╮         | U+256E    | arc (S+W)        | light  |        |       | 🗸    |       | 🗸    |    |    |    |    |
| ╯         | U+256F    | arc (N+W)        | light  |        | 🗸    |       |       | 🗸    |    |    |    |    |
| ╰         | U+2570    | arc (N+E)        | light  |        | 🗸    |       | 🗸    |       |    |    |    |    |
| ╱         | U+2571    | diagonal (NS+EW) | light  |        |       |       |       |       | 🗸 |    |    | 🗸 |
| ╲         | U+2572    | diagonal (NW+SE) | light  |        |       |       |       |       |    | 🗸 | 🗸 |    |
| ╳         | U+2573    | diagonal cross   | light  |        |       |       |       |       | 🗸 | 🗸 | 🗸 | 🗸 |
| ╴         | U+2574    | half-line (W)    | light  |        |       |       |       | 🗸    |    |    |    |    |
| ╵         | U+2575    | half-line (N)    | light  |        | 🗸    |       |       |       |    |    |    |    |
| ╶         | U+2576    | half-line (E)    | light  |        |       |       | 🗸    |       |    |    |    |    |
| ╷         | U+2577    | half-line (S)    | light  |        |       | 🗸    |       |       |    |    |    |    |
| ╸         | U+2578    | half-line (W)    | heavy  |        |       |       |       | **✔** |    |    |    |    |
| ╹         | U+2579    | half-line (N)    | heavy  |        | **✔** |       |       |       |    |    |    |    |
| ╺         | U+257A    | half-line (E)    | heavy  |        |       |       | **✔** |       |    |    |    |    |
| ╻         | U+257B    | half-line (S)    | heavy  |        |       | **✔** |       |       |    |    |    |    |
| ╼         | U+257C    | line (E+W)       | mixed  |        |       |       | **✔** | 🗸    |    |    |    |    |
| ╽         | U+257D    | line (N+S)       | mixed  |        | 🗸    | **✔** |       |       |    |    |    |    |
| ╾         | U+257E    | line (E+W)       | mixed  |        |       |       | 🗸    | **✔** |    |    |    |    |
| ╿         | U+257F    | line (N+S)       | mixed  |        | **✔** | 🗸    |       |       |    |    |    |    |


/// table-caption
<b>Unicode box-drawing characters.</b>
///

<small>
**✔** (heavy check mark) ― heavy, single-stroke joint
<br />
🗸 (light check mark) ― light, single-stroke joint
<br />
🗸🗸 (two light check marks) ― double-stroke light joint
- </small>
