+++
author = "penguinit"
title = "Introducing Goose, the Golang migration tool"
date = "2024-02-26"
description = "DB migration seems to be a constant in any situation, whether it's at my previous job or my current job. In fact, in my case, I didn't utilize a tool until now, but rather wrote ad hoc code or scripts. In today's post, I'd like to introduce Goose, a DB-related migration tool for Golang."
tags = [
"golang", "migration", "goose"
]
categories = [
"language",
]
+++

![Untitled](./images/Untitled.png)

## Overview

In my previous job and my current job, DB migrations seem to be a constant in any situation. In fact, in my case, I didn't utilize a tool until now, but rather wrote ad hoc code or scripts. In today's post, I'd like to introduce Goose, a DB-related migration tool for Golang.

## What is DB migration?

DB migration has many different meanings and situations. When we say we're doing a DB migration, we can think of the following situations. The exact content may vary depending on the context.

- Performance / system upgrade improvements
- DB migration: moving to a lower cost instance or a different type of DB
- Consolidation/decoupling: bringing multiple data sources together in one place or vice versa
- Enhancements: Additions/modifications or deletions to existing datasets due to system changes.

DB migration often refers to a number of different tasks that come with a DB. The Goose tool we're going to talk about today is related to enhancements.

In the real world, you might be updating data for specific users, dropping columns that are no longer in use, or any of these types of things.

## Why did we use Goose?

Goose is a database migration tool written in the Go language. There are many other DB migration tools out there, but we were working on a project with Golang and didn't want to create another dependency for the migration tool.

As mentioned above, I had to choose between migration tools written in Golang, but I chose the one that was the most intuitive and had the smallest learning curve.

From a maintenance perspective, I also considered whether it had a history of commits within the last 3 months and issues were still being managed.

## Installing Goose

Let's start by simply installing Goose.

- On macOS

```bash
brew install goose
```bash brew install goose

- Linux

```bash
curl -fsSL \
    https://raw.githubusercontent.com/pressly/goose/master/install.sh |\
    GOOSE_INSTALL=$HOME/.goose sh -s v3.5.0
```

- Go Install

```bash
go install github.com/pressly/goose/v3/cmd/goose@latest
```

- Build directly from code

```bash
git clone https://github.com/pressly/goose
cd goose
go mod tidy
go build -o goose ./cmd/goose

./goose --version
# goose version:(devel)
```

See also: [https://pressly.github.io/goose/installation/](https://pressly.github.io/goose/installation/)

You'll want to install it for the environment and context in which you want to run it. The following instructions will cover the v3 version, so please install it after that version. (Latest version as of this writing: v3.18.0)

After installing, execute the **goose** command to display the help page like below.

```bash
goose ok 
Usage: goose [OPTIONS] DRIVER DBSTRING COMMAND

or

Set environment key
goose_driver=driver
goose_dbstring=dbstring

Usage: goose [OPTIONS] COMMAND

Drivers:
    postgres
    mysql
    sqlite3
    mssql
    redshift
    tidb
    clickhouse
    vertica
    ydb
    turso
...omit
```

Goose supports the following drivers (I only know the top 5, the rest are new to me)

- postgres
- mysql
- sqlite3
- mssql
- redshift
- tidb
- clickhouse
- vertica
- ydb
- turso

## Hands-on

Goose can perform migrations in three different ways.

- SQL Migrations
- Embedded sql migrations
- Go Migrations

For each case, we will explain in detail with example code. For the sake of speed, we will use SQLite only.

**SQLite test data

```bash
> sqlite3 example.db
Enter ".help" for usage hints.
sqlite> CREATE TABLE IF NOT EXISTS users(id INTEGER PRIMARY KEY, name TEXT);
sqlite> INSERT INTO users(name) VALUES('John Doe');
sqlite> INSERT INTO users(name) VALUES('Mike Cho');
sqlite> .exit
```

### SQL Migration

- Initialize the Goose script

```bash
> GOOSE_DRIVER=sqlite3 GOOSE_DBSTRING=./example.db goose create init sql
2024/02/27 21:01:39 Created new file: 20240227120139_init.sql
```

The above command creates a file in UnixTime format. The file is organized as shown below.

```sql
-- +goose Up
-- +goose StatementBegin
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
-- +goose StatementEnd

```

Goose commands must have the comments `+goose Up` `+goose Down`. The SQL statements below those comments are performed under the transaction, and inside `+goose StatementBegin` and `+goose StatementEnd`, you can perform complex queries. (ex. PL/pgSQL)

Below is the SQL syntax to delete and recover specific data.

```sql
-- +goose Up
DELETE FROM users WHERE name = 'John Doe';

-- +goose Down
INSERT INTO users(name) VALUES('John Doe');
```

- Check status

```sql
> GOOSE_DRIVER=sqlite3 GOOSE_DBSTRING=./example.db goose status
2024/02/27 21:01:41 Applied At Migration
2024/02/27 21:01:41 =======================================
2024/02/27 21:01:41 Pending -- 20240227120139_init.sql
```

- Performing Migration

```sql
> GOOSE_DRIVER=sqlite3 GOOSE_DBSTRING=./example.db goose up
2024/02/27 21:02:04 OK 20240227120139_init.sql (28.55ms)
2024/02/27 21:02:04 goose: successfully migrated database to version: 20240227120139
```

After performing this migration, the row named 'John Doe' will be deleted.

- Verify the migration result

```sql
> GOOSE_DRIVER=sqlite3 GOOSE_DBSTRING=./example.db goose status
2024/02/27 21:17:44 Applied At Migration
2024/02/27 21:17:44 =======================================
2024/02/27 21:17:44 Tue Feb 27 12:02:39 2024 -- 20240227120139_init.sql
```

- Cancel migration (rollback)

```sql
> GOOSE_DRIVER=sqlite3 GOOSE_DBSTRING=./example.db goose down
2024/02/27 21:02:11 OK   20240227120139_init.sql (28.35ms)
```

```sql
GOOSE_DRIVER=sqlite3 GOOSE_DBSTRING=./example.db goose status                     ok | % 
2024/02/27 21:02:17     Applied At                  Migration
2024/02/27 21:02:17     =======================================
2024/02/27 21:02:17     Pending                  -- 20240227120139_init.sql
```
### Embedded sql migrations

In this case, SQL statements are imported using go:embed and migrations are performed using the goose package.

- Installing

```go
go get github.com/mattn/go-sqlite3
go get github.com/pressly/goose/v3
```

- main.go

```go
package main

import (
	"database/sql"
	"embed"
	"log"

	_ "github.com/mattn/go-sqlite3" // import SQLite driver
	"github.com/pressly/goose/v3"
)

//go:embed 20240227120139_init.sql
var embedMigrations embed.FS

func main() {
	// Set the path to the SQLite database file
	db, err := sql.Open("sqlite3", "example.db")
	if err != nil {
		log.Fatalf("Failed to open database: %v", err)
	}
	} defer db.Close()

	// Set the file system embedded in Goose
	goose.SetBaseFS(embedMigrations)

	if err := goose.SetDialect("sqlite3"); err != nil {
		log.Fatalf("Failed to set dialect: %v", err)
	}

	// Run the migration
	if err := goose.Up(db, "."); err != nil {
		log.Fatalf("Failed to run migrations: %v", err)
	}
}

```

- 結果

```bash
2024/02/27 21:27:51 OK 20240227120139_init.sql (21.87ms)
2024/02/27 21:27:51 goose: successfully migrated database to version: 20240227120139
```

### Go Migration

In this case, the migration control is in the actual internal code, not the script. The two examples above were SQL-based migrations, so we needed SQL files, but in go, we don't need SQL syntax because we do the query statements directly internally.

Instead, we need to keep a history, so we use the filename of the perform as the version. The filename must start with a number and we use an underscore (_) as a separator.

`20240227125030_migration.go`

- main.go

```go
// 20240227125030_migration.go
package main

import (
	"context"
	"database/sql"
	"log"

	_ "github.com/mattn/go-sqlite3"
	"github.com/pressly/goose/v3"
)

func init() {
	// Register the migration function
	goose.AddMigrationContext(Up, Down)
}

func main() {
	db, err := sql.Open("sqlite3", "example.db")
	if err != nil {
		log.Fatal("Cannot open database", err)
	}
	} defer db.Close()

	// Set up Goose
	goose.SetDialect("sqlite3")

	// Run all migrations
	if err := goose.Up(db, "."); err != nil {
		log.Fatalf("Goose up error: %v", err)
	}
}

} func Up(ctx context.Context, tx *sql.Tx) error {
	if _, err := tx.Exec("DELETE FROM users WHERE name = 'John Doe';"); err != nil {
		return err
	}

	} return nil
}

func Down(ctx context.Context, tx *sql.Tx) error {
	if _, err := tx.Exec("INSERT INTO users(name) VALUES('John Doe');"); err != nil {
		return err
	}

	return nil
}

```

Executing the code above will generate a version of **20240227125030**.

```bash
2024/02/27 21:54:07 OK 20240227125030_main.go (21.19ms)
2024/02/27 21:54:07 goose: successfully migrated database to version: 20240227125030
```

## Summary

In this post, I introduced Goose, one of the Go Migration libraries. I found it intuitive and understood it well enough just by looking at the README. I think it's enough for those who don't expect to use it in a complex way, but if you want more advanced features, you can try other libraries or solutions.