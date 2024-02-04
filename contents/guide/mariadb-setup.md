# MariaDB setup guide

This lists some best practices for MariaDB along with scripts.
They probably work well for MySQL, too.

## Global install

Global installation is recommended, unless you do not have sudo / administrator access.

=== "Ubuntu"

    ```bash
    mariadb_version="10.11" #(1)!
    sudo apt install software-properties-common
    sudo apt-key adv\
        --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
    sudo add-apt-repository '\
        deb [arch=amd64]\
        https://mariadb.mirror.liquidtelecom.com/repo/${mariadb_version}/ubuntu
        focal main\
     '
    sudo apt install -y mariadb-server mariadb-client
    sudo systemctl start mariadb
    sudo systemctl enable mariadb  #(2)!
    sudo mysql_secure_installation
    ```

    1. 10.11 is the latest LTS version as of August 2023.
    2. Run this to have MariaDB start on startup

=== "Fedora"

    ```bash
    fedora_version=$(( cat /etc/fedora-release )) #(1)!
    mariadb_version="10.11" #(2)!
    sudo tee /etc/yum.repos.d/mariad.repo<<EOF
    [mariadb]
    name = MariaDB
    baseurl = https://rpm.mariadb.org/10./rhel/$releasever/$basearch
    gpgkey= https://rpm.mariadb.org/RPM-GPG-KEY-MariaDB
    gpgcheck=1
    EOF
    sudo dnf -y install MariaDB-server MariaDB-client
    sudo systemctl start mariadb
    sudo systemctl enable mariadb  #(3)!
    sudo mysql_secure_installation
    ```

    1. This should get the current Fedora version.
    2. 10.11 is the latest LTS version as of August 2023.
    3. Run this to have MariaDB start on startup

=== "macOS"

    ```bash
    brew install mariadb
    brew services start mariadb
    ```

    You can then enable it to run on startup.

=== "Windows/Chocolatey"

    `choco install mariadb` (as an administrator)

    You can then enable it to run on startup.

=== "Windows/Scoop"

    `scoop install main/mariadb`

    You can then enable it to run on startup.

## Local install

This describes how to install and configure MariaDB on Linux without sudo.
We tried these
[mariadb non-sudo install instructions](https://mariadb.com/kb/en/installing-mariadb-binary-tarballs/#installing-mariadb-as-not-root-in-any-directory)
and had to make several changes.
Here’s the script:

??? info "Script"

    ```bash
    #!/usr/bin/env bash
    # safe options
    set -euo pipefail
    IFS=$'\n\t'
    _usage="Usage: ${0} [version=${default_mariadb_vr}]"
    default_mariadb_vr="10.11.0"  # latest LTS release

    if (( $# == 1 )) && [[ "${1}" == "--help" ]]; then
      >&2 echo "${_usage}"
      >&2 echo "Sets up a local installation of MariaDB without root access."
      exit 0
    fi

    if (( $# > 1 )); then
      >&2 echo "${_usage}"
      exit 2
    fi

    vr="${default_mariadb_vr}"
    if (( $# == 1)); then
      vr="${1}"
    fi

    pushd ~

    # download mariadb
    _base_url="https://downloads.mariadb.org/f"
    _dir="/mariadb-${vr}/bintar-linux-x86_64"
    _file="/mariadb-${vr}-linux-x86_64.tar.gz"
    curl -O -J -L "${_base_url}${_dir}${_file}?serve"
    gunzip < "mariadb-${vr}-linux-x86_64.tar.gz" | tar xf -
    mv "mariadb-${vr}-linux-x86_64" mysql

    # create a local defaults file
    touch ~/.my.cnf

    # install MariaDB
    chmod u+x mysql/scripts/mariadb-install-db
    mysql/scripts/mariadb-install-db  --defaults-file=~/.my.cnf

    # optional: declare a specific, local socket
    cat >> ~/.my.cnf <<- EOM
    [mysqld]
    socket = ~/mysql/socket
    [mysql]
    socket = ~/mysql/socket
    EOM

    # add a script 'mysqlstart' to start the server with the right defaults file
    mkdir -p ~/bin
    cat >> ~/bin/mysqlstart <<- EOM
    nohup ~/mysql/bin/mysqld_safe --defaults-file=~/.my.cnf &
    EOM

    # add symlinks to other commands
    # (you could also add ~/mysql/bin to your PATH)
    ln -s ~/mysql/bin/mysql_safe ~/bin/mysqlstart
    ln -s ~/mysql/bin/mysqldump ~/bin/mysqldump
    ln -s ~/mysql/bin/mysqladmin ~/bin/mysqladmin
    ln -s ~/mysql/bin/mysqlimport ~/bin/mysqlimport
    ln -s ~/mysql/bin/mysqlcheck ~/bin/mysqlcheck
    ln -s ~/mysql/bin/mysql ~/bin/mysql

    popd
    ```

Note that `~/bin/` must be on your `PATH`.
You can start the server with `nohup mysql_start &`
And log in as an admin user: `mysql --user=${USER}`

## Hardening

To improve security, I recommend following **[dedicated security guides](https://www.google.com/search?q=mysql+security+best+practices)**.
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

Add this to your `my.cnf`

```ini
[mysqld]
# Timezone (if not set previously)
time_zone = '+00:00'
system_time_zone = '+00:00'

# Use real Unicode everywhere
character_set_client = utf8mb4
character_set_server = utf8mb4
character_set_system = utf8mb4
character_set_filesystem = utf8mb4
character_set_results = utf8mb4
character_set_database = utf8mb4
# Case-insensitive Unicode Collation Algorithm
# 520 is the current latest version
# https://www.unicode.org/Public/UCA/5.2.0/allkeys.txt
collation_server = utf8mb4_unicode_520_ci

# Do not commit after each statement
# Use COMMIT or ROLLBACK instead
autocommit = 0

# have single-row inserts produce a warning
sql_warnings = 1

# use more precision during divide (default is 4)
div_precision_increment = 8

# disable weird behaviors
explicit_defaults_for_timestamp = 1
sql_mode = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,SIMULTANEOUS_ASSIGNMENT'

# Things to tweak
interactive_timeout = 604800
wait_timeout = 604800
innodb_page_size = 16k
max_allowed_packet = 1GB
query_cache_limit = 128K
query_cache_size = 64M

[mysqldump]
max_allowed_packet = 1GB
quote-names
```

## Database creation

The current best way to create a database is by running

```sql
create database `mydatabase`
    default character set utf8mb4
    collate utf8mb4_unicode_520_ci
;
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
Each table is written to one gzipped file, with binary data hex-encoded.
Having one table per file means that we only lose one table if a file is corrupted.
Hex-encoding adds more robustness because tools can often fix corrupted gzip and UTF-8 files.
Since gzip is used, no more storage is needed, and the only downside is reduced write speed.


Here is the backup script:

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
default_path_="/bak/mariadb/dbname/nightly"
_usage="Usage: ${0} [<path=${default_path_}>]"

if (( $# == 1 )) && [[ "${1}" == "--help" ]]; then
	>&2 echo "${_usage}"
	>&2 echo "Exports all the data in a database as one gzipped sql file per table."
	>&2 echo "Requires environment vars DB_NAME, DB_USER, and DB_PASSWORD"
	exit 0
fi

if (( $# > 1 )); then
	>&2 echo "${_usage}"
	exit 2
fi

# Modify this
db_port_="3306"
db_name_="${DB_NAME}"  # (1)!
db_user_="${DB_USER}"
db_password_="${DB_PASWORD}"
loc_="${default_path_}"

if (( $# > 0 )); then
	loc="${1}"
fi

tables=$(\
  mysql -NBA \
  -u "${db_user_}" \
  -P="${db_password_}" \
  -D "${db_name_}" \
  -e 'show tables'\
);
for t in $tables do
	echo "Backing up $t..."
	# 2147483648 is the max
	mysqldump \
    --single-transaction \
    --hex-blob \
    --max_allowed_packet=2147483648 \
    --port="${db_port_}" \
    --user="${db_user_}" \
    --password="${db_password_}" \
    "${db_name_}" \
    "${t}" | gzip > "${loc_}/${t}.sql.gz"
done

>&2 echo "Backed up to ${loc_}"
```

1. Set these environment variables before running.

## Schema files

Here’s a script to write the schema in a nice way.

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
_usage="Usage: ${0}"

if (( $# == 1 )) && [[ "${1}" == "--help" ]]; then
	>&2 echo "${_usage}"
	>&2 echo "Dumps the schema to schema.sql."
	>&2 echo "Requires environment vars DB_NAME, DB_USER, and DB_PASSWORD"
	exit 0
fi

db_name_="${DB_NAME}"  # (1)!
if [ -v "${DB_SOCKET}" ]; then
    db_socket_="${DB_SOCKET}"  # (2)!
else
    db_socket_=""
    db_port_="3306"
    db_user_="${DB_USER}"          # (3)!
    db_password_="${DB_PASSWORD}"
fi

if (( $# > 0 )); then
	>&2 echo "${_usage}"
	exit 2
fi

out_file="schema-${db_name_}.sql"

if "${db_socket_}"; then
    mysqldump \
        --protocol=socket \
        --socket="${db_socket_}" \
        --skip-add-drop-table \
        --single-transaction \
        --no-data \
        "${db_name_}" \
        > "${out_file}"
else
    mysqldump \
        --host=127.0.0.1 \
        --port="${db_port_}" \
        --user="${db_user_}" \
        --password="${db_password_}" \
        --skip-add-drop-table \
        --single-transaction \
        --no-data \
        "${db_name_}" \
        > "${out_file}"

# remove the auto_increment -- we don't care
sed -r -i -e 's/auto_increment=[0-9]+ //g' "${out_file}"
>&2 echo "Wrote to ${out_file}"
```

1. Set `DB_NAME` to the database before running.
2. Option 1: Set `DB_SOCKET`
3. Option 2: Set `DB_USER` and `DB_PASSWORD`

## ERDs

[This script by Andrea Agili](https://gist.github.com/agea/6591881)
will generate an [ERD](https://en.wikipedia.org/wiki/Entity%E2%80%93relationship_model) from a database connection.
It will write a [GraphML](https://en.wikipedia.org/wiki/GraphML) file, which you can open in a tool like [yEd](https://www.yworks.com/products/yed) to apply a layout algorithm
and [crow’s foot notation](https://en.wikipedia.org/wiki/Entity%E2%80%93relationship_model#Crow's_foot_notation).
After generating an SVG from yEd, you can modify the SVG code to add an
[<a> element](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/a) links to per-table anchors in a schema file.

After downloading the script, also download [the MySQL Connector](https://dev.mysql.com/downloads/connector/j/).
Extract the JAR alongside.

Then output a graphml file by running:

```bash
groovy erd.groovy > erd.graphml
```
