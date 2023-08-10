# MariaDB best practices

This lists some best practices for MariaDB and MySQL along with scripts.
_Also see: [install MariaDB without sudo](https://dmyersturnbull.github.io/software-testing/)_

## Database creation

The current best way to create a database is:

```sql
CREATE DATABASE `valar` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;
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
create database MY_DB_NAME default character set utf8mb4 collate utf8mb4_unicode_520_ci;
create user readonly@localhost identified by 'hasread';
create user writeaccess@localhost identified by 'haswrite';
create user admin@localhost identified by 'hasallaccess';
grant select on MY_DB_NAME to readonly@localhost;
grant select, insert, update, delete on MY_DB_NAME to writeaccess@localhost;
grant all on MY_DB_NAME to admin@localhost;
flush privileges;
```

## Generate robust backups

This script will generate robust backups.
Each table is written to one gzipped file, with binary data hex-encoded.
Having one table per file means that we only lose one table if a file is corrupted.
Hex-encoding adds more robustness because tools can often fix corrupted gzip and UTF-8 files.
Since gzip is used, no more storage is needed, and the only downside is reduced write speed.

**I do not recommend mysqlpump** (with a **p**). In 2015, the MySQL team
[did not recommend mysqlpump as a backup solution](http://mysqlserverteam.com/introducing-mysqlpump/),
noting:

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

for t in $(mysql -NBA -u "${db_user_}" --password="${db_password_}" -D "${db_name_}" -e 'show tables'); do
	echo "Backing up $t..."
	# 2147483648 is the max
	mysqldump \
	--single-transaction \
	--hex-blob \
	--max_allowed_packet=2147483648 \
	--port="${valar_port_}" \
	--user="${valar_user_}" \
	--password="${db_password_}" \
	"${db_name_}" \
	"${t}" \
	| gzip > "${loc_}/${t}.sql.gz"
done

echo "Backed up to ${loc_}"
```

## Write a schema file

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
valar_user_="${DB_USER}"
valar_password_="${DB_PASSWORD}"

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

## Generate an ERD

This will generate an [ERD](https://en.wikipedia.org/wiki/Entity%E2%80%93relationship_model)
from a database connection. The script will output a
[GraphML](https://en.wikipedia.org/wiki/GraphML) file, which you can open in a tool
like [yEd](https://www.yworks.com/products/yed) to apply a layout algorithm or apply
[crow’s foot notation](https://en.wikipedia.org/wiki/Entity%E2%80%93relationship_model#Crow's_foot_notation).
Thanks to [Andrea Agili](https://gist.github.com/agea) for most of the Groovy script.
Idea: After generating a SVG from yEd, you can modify the SVG code to add an
[<a> element](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/a) links to per-table anchors in
a schema file.

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

if (( $# == 1 )) && [[ "${1}" == "--help" ]]; then
	echo "Usage: ${0}"
	echo "Writes an ERD of the schema in graphml to erd.graphml."
	echo "Requires environment vars DB_NAME, DB_USER, and DB_PASSWORD"
	exit 0
fi

if (( $# > 0 )); then
	(>&2 echo "Usage: ${0}")
	exit 1
fi

if [[ ! -e "~/.groovy" ]]; then
  mkdir "~/.groovy"
fi
wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.23.zip
unzip mysql-connector-java-8.0.23.zip -d "~/.groovy"

groovy erd.groovy > erd.graphml
```

Include this Groovy script in the same directory:

```groovy
/*
Taken almost entirely from https://gist.github.com/agea/6591881
The author is Andrea Agili
To run, you'll need mysql-connector on the classpath
*/

import groovy.sql.*

def env = System.getenv()

def tables = [:]

def visitTable = { dbmd, schema, tableName ->
	if (!tables[tableName]) {
		tables[tableName] = new HashSet()
	}
	def keyRS = dbmd.getExportedKeys(null, schema, tableName)
	while (keyRS.next()) {
		tables[tableName] << keyRS.getString("FKTABLE_NAME")
	}
	keyRS.close()
}

def config = [
	host: "localhost", port: 3306,
	dbname: env['DB_NAME'], username: env['DB_USER'], password: env['DB_PASSWORD'],
	driver: "com.mysql.jdbc.Driver",
	schema: env['DB_NAME']
]
// we don't care about the timezone, so set it to UTC
def url = "jdbc:mysql://${config.host}/${config.dbname}?serverTimezone=UTC"

def sql = Sql.newInstance(url, config.username, config.password, config.driver)
def dbmd = sql.connection.metaData

def tableRS = dbmd.getTables(null, config.schema, null, "TABLE")
while (tableRS.next()) {
	visitTable(dbmd, config.schema, tableRS.getString("TABLE_NAME"))
	System.err.print "."
}
System.err.println ""
tableRS.close()

sql.connection.close()

println """
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<graphml xmlns="http://graphml.graphdrawing.org/xmlns/graphml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:y="http://www.yworks.com/xml/graphml" xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns/graphml http://www.yworks.com/xml/schema/graphml/1.0/ygraphml.xsd">
  <key for="node" id="d0" yfiles.type="nodegraphics"/>
  <key attr.name="description" attr.type="string" for="node" id="d1"/>
  <key for="edge" id="d2" yfiles.type="edgegraphics"/>
  <key attr.name="description" attr.type="string" for="edge" id="d3"/>
  <key for="graphml" id="d4" yfiles.type="resources"/>
  <graph id="${config.schema}" edgedefault="directed">
"""

tables.each { k,v ->
	nodeId = "${config.schema}_${k}"
	println """
<node id="${nodeId}">
<data key="d0">
<y:ShapeNode>
<y:Geometry height="30.0" width="${nodeId.length() * 8}.0" x="0.0" y="0.0"/>
<y:Fill color="#E8EEF7" color2="#B7C9E3" transparent="false"/>
<y:BorderStyle color="#000000" type="line" width="1.0"/>
<y:NodeLabel alignment="center" autoSizePolicy="content" fontFamily="Dialog" fontSize="13" fontStyle="plain" hasBackgroundColor="false" hasLineColor="false" height="19.92626953125" modelName="internal" modelPosition="c" textColor="#000000" visible="true" width="37.0" x="5.5" y="5.036865234375">${k}</y:NodeLabel>
<y:Shape type="rectangle"/>
<y:DropShadow color="#B3A691" offsetX="2" offsetY="2"/>
</y:ShapeNode>
</data>
</node>
"""
}

tables.each { k,v ->
	v.each { referer ->
		edgeId = "${config.schema}_${referer}_${k}"
		println """
<edge id="${edgeId}" source="${config.schema}_${referer}" target="${config.schema}_${k}">
<data key="d2">
<y:PolyLineEdge>
<y:Path sx="0.0" sy="13.5" tx="0.0" ty="-15.0"/>
<y:LineStyle color="#000000" type="line" width="1.0"/>
<y:Arrows source="none" target="crows_foot_many_mandatory"/>
<y:EdgeLabel alignment="center" distance="2.0" fontFamily="Dialog" fontSize="12" fontStyle="plain" hasBackgroundColor="false" hasLineColor="false" height="4.0" modelName="six_pos" modelPosition="tail" preferredPlacement="anywhere" ratio="0.5" textColor="#000000" visible="true" width="4.0" x="2.0000069969042897" y="18.5"/>
<y:BendStyle smoothed="false"/>
</y:PolyLineEdge>
</data>
</edge>
"""
	}
}

println """
  <data key="d4">
    <y:Resources/>
  </data>
  </graph>
</graphml>"""
```
