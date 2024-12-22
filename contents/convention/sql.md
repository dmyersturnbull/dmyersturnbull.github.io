<!--
SPDX-FileCopyrightText: Copyright 2017-2024, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# SQL conventions

## Formatting

!!! tip

    IntelliJ can do this for you.
    Import the [IntelliJ formatter settings](intellij-style.xml).

Use lowercase for keywords, aliases, function names, and columns, and table names.

Wrap at 120 characters and do not align horizontally.
Multiline statements should follow this indentation format:

```sql
select
    pet.name as name,
    pet.age as age,
    owner.name as owner
from
    pet
    inner join species on pet.species = species.id
    left join owner on pet.owner = owner.id
where
    owner.name = 'Berk'
    and species.name like 'Canis%'
;
```
