+++
author = "penguinit"
title = "Learn DDL, DML, DCL, TCL in DBMS"
date = "2024-03-26"
description = "Usually, we say query statement as a whole, but I don't understand exactly what are the differences and features of DDL, DML, DCL, and TCL, so I'm going to summarize them in this post."
tags = [
"ddl","dcl","dml","tcl"
]
categories = [
"database"
]
+++

## Overview

In general, we often talk about query statements, but I don't understand exactly what the differences and features of DDL, DML, DCL, and TCL are, so I'm going to summarize them in this post.

## DDL

DDL stands for Data Definition Language and is a language used to create, change, and delete database schemas. The commands in this language are used to define the database structure, and you can create, change, and delete database objects such as tables, indexes, and constraints. The main commands in DDL include `CREATE`, `ALTER`, and `DROP`.

- CREATE: Creates a new database, table, index, etc.
- ALTER`: Modifies an existing database object.
- DROP`: Deletes an existing database object.

## DML

DML stands for Data Manipulation Language and is the language used to actually manipulate the data within a database. You can insert, retrieve, modify, and delete data. The main commands in DML include `SELECT`, `INSERT`, `UPDATE`, and `DELETE`.

- SELECT: Retrieves data from the database.
- INSERT: Inserts new data into the database.
- UPDATE: Modifies existing data in the database.
- DELETE: Deletes data from the database.

## DCL

DCL stands for Data Control Language and is a language used to control access to a database. It involves granting or revoking privileges to users to database objects. The main commands in DCL include `GRANT`, `REVOKE`, etc.

- GRANT: Grants a user permission to a database object.
- REVOKE: Revokes the permissions granted to a user.

## TCL

TCL stands for Transaction Control Language and is the language used to manage transactions in a database. A transaction is a logical unit of work, which can be processed as a single operation by combining multiple DML commands. Commands in TCL include `COMMIT`, `ROLLBACK`, and `SAVEPOINT`.

- COMMIT: Completes the transaction and reflects all changes to the database.
- ROLLBACK: Cancels the transaction and reverts the changes.
- SAVEPOINT: Sets the point within the transaction where you can roll back.

## Transaction Support

Recently, I've been using MYSQL and realized that it has some limitations in supporting DDL transactions. The following table shows the transaction support by DBMS for DDL, DML, and DCL except TCL.

| DBMS       | DDL Transaction Support | DML Transaction Support | DCL Transaction Support |
|------------|-------------------------|-------------------------|-------------------------|
| MySQL      | Partial[*]              | Support                 | Partial                 |
| PostgreSQL | Support                 | Support                 | Support                 |
| Oracle     | Support                 | Support                 | Support                 |
| SQL Server | Support                 | Support                 | Partial                 |

⚠️In MYSQL, some DDL jobs may run as part of a transaction, but not all DDL jobs are managed as transactions.

### DDL transactions in MYSQL

In the course of operations, there are many times when you need to add or delete columns. In the case of MYSQL based on the InnoDB engine, DDL transactions may not be guaranteed in certain situations, so you need to write queries with that in mind.

### DDL managed by transactions

- ALTER operations on tables: Operations that change the structure of a table can be managed as transactions and can be rolled back. For example, adding or deleting a new column to a table.

    ```sql
    START TRANSACTION;
    ALTER TABLE my_table ADD COLUMN new_column INT;
    ROLLBACK;
    ```

- CREATE INDEX and DROP INDEX operations on a table: operations that create or drop an index are also executed as part of a transaction and can be rolled back.

    ```sql
    START TRANSACTION;
    CREATE INDEX idx_name ON my_table(column_name);
    ROLLBACK;
    ```


### DDL not managed by transactions

- CREATE and DROP operations on databases and tables: Operations that create or drop a database or table are committed immediately and cannot be rolled back as a transaction.

    ```sql
    CREATE DATABASE test_db;
    DROP TABLE my_table;
    ```

- RENAME TABLE operation: The operation to rename a table is not managed as a transaction.

    ```sql
    RENAME TABLE old_table_name TO new_table_name;
    ```


## Cleanup

In this article, you've learned about the definitions of DDL, DML, DCL, and TCL used in DBMS and whether or not they support transactions. In particular, you can see that transactions are not guaranteed for certain DDLs in MYSQL, unlike other DBMSs.
In your work, I think it's good to communicate your intentions in more clear terms (DDL, DML, DCL, TCL) rather than using query statements.
