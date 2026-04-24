---
tags:
  - software-setup
---

# MariaDB setup

<!--
SPDX-FileCopyrightText: Copyright 2017-2025, Douglas Myers-Turnbull
SPDX-PackageHomePage: https://dmyersturnbull.github.io
SPDX-License-Identifier: CC-BY-SA-4.0
-->

This lists some best practices for MariaDB along with scripts.
They probably work well for MySQL, too.

## Global install

Global installation is recommended, unless you do not have sudo / administrator access.

=== "Ubuntu"

    Follow the
    [MariaDB installation instructions](https://mariadb.com/kb/en/mariadb-package-repository-setup-and-usage/).
    Use the _MariaDB Repository Configuration Tool_ and run:

    ```bash
    sudo apt-get install -y mariadb-server mariadb-client mariadb-backup
    ```

    To have the MariaDB server dameon run at startup, run

    ```bash
    sudo systemctl enable mariadb
    ```

=== "Fedora"

    The _MariaDB Repository Configuration Tool_ does not support Feodra (as of 2024-12),
    but you can configure the repository semi-manually.
    URIs, architecture names, etc., unfortunately sometimes change, so you might need to tweak this script.

    ```bash
    mariadb_vr=11.rc #(1)!
    # DNF .repo files can use a few variables, which are listed:
    # /etc/dnf/vars/
    #   ├── arch        example: x86_64
    #   ├── basearch    example: x86_64
    #   └── releasever  example: 40
    # A valid repo URI like this:
    # https://mirror.mariadb.org/yum/11.rc/fedora40-amd64/
    # /yum/$mariadb_vr/fedora\$releasever-$fixed_arch/
    #      ^ Bash            ^^ DNF       ^ Bash (x86_64 -> amd64)
    fixed_arch=$(cat /etc/dnf/vars/arch) # or $(uname -m)
    [[ "$fixed_arch" == x86_64 ]] && fixed_arch=amd64
    repo_url="https://mirror.mariadb.org/yum/$mariadb_vr/fedora${fedora_vr}-${arch}/"
    sudo cat > /etc/yum.repos.d/mariadb.repo << EOF
    [mariadb]
    name=MariaDB
    baseurl=https://rpm.mariadb.org/$mariadb_vr/fedora\$releasever-$fixed_arch
    gpgkey=https://rpm.mariadb.org/RPM-GPG-KEY-MariaDB
    gpgcheck=1
    EOF
    sudo dnf install -y mariadb-server mariadb-client mariadb-backup
    sudo systemctl start mariadb
    sudo mysql_secure_installation
    ```

    1. Change to `11.rolling` for a non-LTS release.

    To have the MariaDB server dameon run at startup, run

    ```bash
    sudo systemctl enable mariadb
    ```

=== "Ubuntu (alt)"

    If the MariaDB Repository Configuration Tool failed, you can configure the repository semi-manually.
    URIs, architecture names, etc., unfortunately sometimes change, so you might need to tweak this script.

    ```bash
    mariadb_vr="11.rc" #(1)!
    sudo apt-get install -y software-properties-common
    sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
    sudo add-apt-repository -y '\
    deb [arch=amd64]\
    https://mariadb.mirror.liquidtelecom.com/repo/$mariadb_vr/ubuntu
    focal main\
    '
    sudo apt-get update -y -q
    sudo apt-get install -y -q mariadb-server mariadb-client mariadb-backup
    sudo systemctl start mariadb
    sudo mysql_secure_installation
    ```

    1. Change to `11.rolling` for a non-LTS release.

    To have the MariaDB server dameon run at startup, run

    ```bash
    sudo systemctl enable mariadb
    ```

=== "macOS"

    ```bash
    brew update
    brew install mariadb
    brew services start mariadb
    ```

=== "Windows – Chocolatey"

    `choco install mariadb` (as an administrator)

=== "Windows – Scoop"

    `scoop install main/mariadb`

## Local install

This describes how to install and configure MariaDB on Linux without sudo.
We tried these
[MariaDB non-sudo install instructions](https://mariadb.com/kb/en/installing-mariadb-binary-tarballs/#installing-mariadb-as-not-root-in-any-directory)
but had to make many changes.

[`install-mariadb-non-root.sh` :fontawesome-solid-code:](files/install-mariadb-non-root.sh){ .md-button }

### `$MYSQL_HOME` and `~/mysql/bin/`

Set `$MYSQL_HOME` to `~/mysql/`, and add `~/mysql/bin/` to your PATH.

If you have [`~/.commonrc`](nix-shells.md#commonrc-file), run

```bash
commonrc::prepend_to_path '$HOME/mysql/bin/'
commonrc::add_line 'MYSQL_HOME=$HOME/mysql/bin/'
```

### Usage

You can start the server with `nohup mysql_start &`
And log in as an admin user: `mysql --user=$USER`.

## Hardening

To improve security, I recommend following
**[dedicated security guides](https://www.google.com/search?q=mysql+security+best+practices)**.
_Note: your config file might be `my.cnf` or `.my.cnf` (with a dot)._
Basic steps might include:

- Install with `mysql_secure_installation`
- Drop the `test` database
- Disable remote access (e.g. with `bind-address=127.0.0.1` under `[mysqld]`)
- Require TLS for remote access; run with `--require_secure_transport=ON`
- Start the server with `-chroot`
- Remove the history file (e.g. `.mysql_history`)
- Set `set-variable=local-infile=0` under `[mysqld]`
- Obfuscate the port (something other than 3306)
- Obfuscate the root username (e.g. `rename user root to sadf346s9`)
- Set `max_connect_errors` under `[mysqld]` to something reasonable
- Consider encrypting the stored data, such as with storage device encryption,
  filesystem encryption, or [MariaDB Data-at-Rest Encryption](https://mariadb.com/kb/en/data-at-rest-encryption-overview/)

I recommend an admin user, a write-access user, and a read-only user per database.
(You might not need passwords if only local access via sockets is allowed.)

Here’s a single script for all of this (replace `MY_DB_NAME`):

```sql
create database MY_DB_NAME
    default character set utf8mb4
    collate utf8mb4_unicode_520_ci
;
create user readonly@localhost identified by 'hasread';
create user writeaccess@localhost identified by 'haswrite';
create user admin@localhost identified by 'hasallaccess';
grant select on MY_DB_NAME to readonly@localhost;
grant select, insert, update, delete on MY_DB_NAME to writeaccess@localhost;
grant all on MY_DB_NAME to admin@localhost;
flush privileges;
```

## Timezone

Add the timezone database to MariaDB:

```bash
sudo mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root mysql
```

I highly recommend using UTC everywhere.
Add this to your `my.cnf`:

```ini
[mysqld]
time_zone = '+00:00'
system_time_zone = '+00:00'
```

After restarting, check it:

```sql
select @@timezone;
select @@server_timezone;
```

## Other variables

Include the following options in your `my.cnf`.
Note that `[client]` affects `mysql`, `mysqldump`, etc.
Also note that `-` and `_` are interchangeable in keys; the docs indicate that hyphens are preferred.

```ini
[client]
default-character-set=utf8mb4

[mysqld]
# Timezone (if not set previously)
time-zone = '+00:00'
system-time-zone = '+00:00'

# Use real Unicode everywhere
character-set-client = utf8mb4
character-set-server = utf8mb4
character-set-system = utf8mb4
character-set-filesystem = utf8mb4
character-set-results = utf8mb4
character-set-database = utf8mb4

# Use the Unicode Collation Algorithm
# 9.0.0 is the current latest version
# '_ai' => accent-insensitive
# '_ci' => case-insensitive
# https://www.unicode.org/Public/UCA/9.0.0/allkeys.txt
collation-server = utf8mb4_0900_ai_ci
init-connect = 'SET NAMES utf8mb4 COLLATE utf8mb4_0900_ai_ci'

# Do not commit after each statement
# Use COMMIT or ROLLBACK instead
autocommit = 0

# have single-row inserts produce a warning
sql-warnings = 1

# use more precision during divide (default is 4)
div-precision-increment = 8

# disable weird behaviors
explicit-defaults-for-timestamp = 1
sql-mode = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,SIMULTANEOUS_ASSIGNMENT'

# Things to tweak
interactive-timeout = 604800
wait-timeout = 604800
innodb-page-size = 16k
max-allowed-packet = 1GB
query-cache-limit = 128K
query-cache-size = 64M

[mysqldump]
max-allowed-packet = 1GB
quote-names
```

## Robust backups

I recommend [MariaBackup](https://mariadb.com/kb/en/mariabackup-overview/) for general-purpose backups,
such as nightly snapshots.

!!! warning

    **I do not recommend mysqlpump** (with a **p**).
    In 2015, the MySQL team
    [did not recommend mysqlpump as a backup solution](http://mysqlserverteam.com/introducing-mysqlpump/), noting:

    > This makes it currently unsafe as a general purpose backup replacement (i.e. fully replacing mysqldump).

### Gzipped SQL backups

This script will generate robust backups.
Each table is written to one ZSTD-compressed file, with binary data hex-encoded.
Having one table per file means that we only lose one table if a file is corrupted.
Hex-encoding adds more robustness because tools can often fix corrupted compressed UTF-8 files.
Since compression is used, no additional storage is needed; the only downside is reduced write speed.

Here is the backup script:
**[`back-up-mariadb.sh`](../scripts/back-up-mariadb.sh)**.

It uses these environment variables:

1. `DB_NAME` (required)
2. either `DB_SOCKET` or `DB_USER` and `DB_PASSWORD` (required)
3. `DB_BACKUP_DIR` (defaults to `/bak/mariadb/$DB_NAME/`)
4. `ZSTD_LEVEL` (defaults to 2) and `ZSTD_THREADS` (defaults to 1)

## Schema files

Here’s a script to write the schema in a nice way:
**[`write-mariadb-schema.sh`](../scripts/write-mariadb-schema.sh)**.

It uses these environment variables:

1. `DB_NAME` (required)
2. either `DB_SOCKET` or `DB_USER` and `DB_PASSWORD` (required)

## ERDs

[This script by Andrea Agili](https://gist.github.com/agea/6591881)
will generate an
[ERD](https://en.wikipedia.org/wiki/Entity%E2%80%93relationship_model)
from a database connection.
It will write a [GraphML](https://en.wikipedia.org/wiki/GraphML) file,
which you can open in a tool like
[yEd](https://www.yworks.com/products/yed)
to apply a layout algorithm and
[crow’s foot notation](https://en.wikipedia.org/wiki/Entity%E2%80%93relationship_model#Crow's_foot_notation).
After generating an SVG from yEd, you can modify the SVG code to add an
[<a> element](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/a)
links to per-table anchors in a schema file.

After downloading the script, also download the
[MySQL Connector](https://dev.mysql.com/downloads/connector/j/).
Extract the JAR alongside.

Then output a graphml file by running:

```bash
groovy erd.groovy > erd.graphml
```
