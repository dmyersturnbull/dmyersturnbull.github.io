---
title: "Install MariaDB without sudo"
date: 2021-04-27:13:50:00-08:00
draft: false
slug: local-mariadb
---

This describes how to install and configure MariaDB on Linux without sudo. We tried these
[mariadb non-sudo install instructions](https://mariadb.com/kb/en/installing-mariadb-binary-tarballs/#installing-mariadb-as-not-root-in-any-directory)
and had to make several changes. Here’s the script:

```bash
#!/usr/bin/env bash
# safe options
set -euo pipefail
IFS=$'\n\t'

default_mariadb_vr="10.5.9"

if (( $# == 1 )) && [[ "${1}" == "--help" ]]; then
	echo "Usage: ${0} [version=${default_mariadb_vr}]"
	echo "Sets up a local installation of MariaDB without root access."
	exit 0
fi

if (( $# > 1 )); then
	echo "Usage: ${0} [version=${default_mariadb_vr}]"
	exit 1
fi

mariavr="${default_mariadb_vr}"
if (( $# == 1)); then
	mariavr="${1}"
fi

pushd ~

# download mariadb
curl -O -J -L "https://downloads.mariadb.org/f/mariadb-${mariavr}/bintar-linux-x86_64/mariadb-${mariavr}-linux-x86_64.tar.gz/from/https%3A//ftp.osuosl.org/pub/mariadb/?serve"
gunzip < "mariadb-${mariavr}-linux-x86_64.tar.gz" | tar xf -
mv "mariadb-${mariavr}-linux-x86_64" mysql

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
cat >> ~/bin/mysqlstart
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

**Also see the [MariaDB best practices](https://dmyersturnbull.github.io/mariadb-best-practices) guide.**
