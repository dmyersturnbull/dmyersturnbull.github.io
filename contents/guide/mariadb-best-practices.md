# MariaDB best practices

This lists some best practices for MariaDB and MySQL along with scripts.
_Also see: [install MariaDB without sudo](../misc/mariadb-local-install.md)_

## Database creation

The current best way to create a database is:

```sql
CREATE DATABASE `mydatabase`\
    DEFAULT CHARACTER SET utf8mb4\
    COLLATE utf8mb4_unicode_520_ci\
;
```

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
create database MY_DB_NAME \
    default character set utf8mb4 \
    collate utf8mb4_unicode_520_ci \
;
create user readonly@localhost identified by 'hasread';
create user writeaccess@localhost identified by 'haswrite';
create user admin@localhost identified by 'hasallaccess';
grant select on MY_DB_NAME to readonly@localhost;
grant select, insert, update, delete on MY_DB_NAME to writeaccess@localhost;
grant all on MY_DB_NAME to admin@localhost;
flush privileges;
```

## Robust backups

This script will generate robust backups.
Each table is written to one gzipped file, with binary data hex-encoded.
Having one table per file means that we only lose one table if a file is corrupted.
Hex-encoding adds more robustness because tools can often fix corrupted gzip and UTF-8 files.
Since gzip is used, no more storage is needed, and the only downside is reduced write speed.

**I do not recommend mysqlpump** (with a **p**).
In 2015, the MySQL team
[did not recommend mysqlpump as a backup solution](http://mysqlserverteam.com/introducing-mysqlpump/), noting:

> This makes it currently unsafe as a general purpose backup replacement (i.e. fully replacing mysqldump).

Here is the backup script:

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
default_path_="/bak/mariadb/dbname/nightly"

if (( $# == 1 )) && [[ "${1}" == "--help" ]]; then
	echo "Usage: ${0} [<path=${default_path_}>]"
	echo "Exports all the data in a database as one gzipped sql file per table."
	echo "Requires environment vars DB_NAME, DB_USER, and DB_PASSWORD"
	exit 0
fi

if (( $# > 1 )); then
	(>&2 echo "Usage: ${0}")
	exit 1
fi

# Modify this
db_port_="3306"
db_name_="${DB_NAME}"
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

echo "Backed up to ${loc_}"
```

## Schema files

Here’s a script to write the schema in a nice way.

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

if (( $# == 1 )) && [[ "${1}" == "--help" ]]; then
	echo "Usage: ${0}"
	echo "Dumps the schema to schema.sql."
	echo "Requires environment vars DB_NAME, DB_USER, and DB_PASSWORD"
	exit 0
fi

db_port_="3306"
db_name_="${DB_NAME}"
db_user_="${DB_USER}"
db_password_="${DB_PASSWORD}"

if (( $# > 0 )); then
	(>&2 echo "Usage: ${0}")
	exit 1
fi

mysqldump \
  --skip-add-drop-table \
  --single-transaction \
  --host=127.0.0.1 \
  --port="${db_port_}" \
  --user="${db_user_}" \
  --password="${db_password_}" \
  --no-data \
  "${db_name_}" \
  > "schema-${db_name_}.sql"

# remove the auto_increment -- we don't care
sed -r -i -e 's/AUTO_INCREMENT=[0-9]+ //g' "schema-${db_name_}.sql"
```

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
