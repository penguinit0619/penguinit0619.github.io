+++
author = "penguinit"
Title = "Array Type in RDB"
date = "2024-02-04"
Description = "I recently moved to a different company and I got to use MYSQL and got paid for it as a list, but I checked and found out that MYSQL itself doesn't have an ARRAY type, so I'd like to organize it simply."
tags = [
"mysql", "postgresql"
]

categories = [
"database",
]
+++

## Overview

Recently, I used MYSQL when I moved to a different company, and I had a chance to receive a price by listing, but when I checked, I found out that MYSQL itself does not have an ARRAY type, so I would like to organize it simply.

## Array Type

The RDBs I used so far are Oracle and PostgreSql, so I naturally thought that MYSQL also had an Array type. It wasn't really like that, but similarly, I summarized the DBs that support the Array type in RDB and the DBs that are not.

| Database   | Array Type Support | Note                                                                                    |
|------------|--------------------|-----------------------------------------------------------------------------------------|
| PostgreSQL | Support            | Native array type support for various data types.                                       |
| MySQL      | Not supported      | By default, the array type is not supported, but JSON can be used for similar purposes. |
| Oracle     | Support            | Support for collection types such as VARRAY.                                            |
| SQL Server | Not supported      | does not support array type by default.                                                 |
| SQLite     | Not supported      | does not support array type by default, but you can save a simple list with text.       |
| MariaDB    | Not supported      | Does not support array types by default, similar to MySQL.                              |
| IBM Db2    | Support            | Support array type via ARRAY data type.                                                 |

### Why doesn't MySQL have an Array Type?

When looking at MYSQL only, you need to understand the initial design philosophy and objectives. As the type of array came in, there were some areas that required more complex processing in terms of simplicity and performance, and from the perspective of relational data modeling, the Array type went against the principle of normalization and complicated integrity management. In particular, we designed it to easily transfer from database A to database B by following standard SQL, and this seems to have had a lot of influence.

### Why does PostgreSQL have an Array Type?

You also need to understand the philosophy that early PostgreSQL had at the time of its design. PostgreSQL has this phrase if you go to the site.

**“The World's Most Advanced Open Source Relational Database”**

From the design stage, we have tried to achieve this goal through a variety of advanced features and flexible data type support, and the array type is one of the key goals that PostgreSQL is pursuing.

There may be some misunderstanding, so PostgreSQL is a better database than MYSQL because it supports advanced queries and various types. However, as everything always has its pros, MYSQL has advantages over PostgreSQL and, on the other hand, PostgreSQL has advantages over MYSQL, so you can choose the right database for your business needs.

## Alternative

Then, since there is no Array type in MYSQL, you may think that it should be normalized and saved, but that is not true. Traditionally, there is a method of saving and importing text through a specific separator (","), and you can use the JSON type described below similarly.

### MySQL JSON Type

Advances in web technology and applications have made data storage and processing requirements more diverse and complex. In particular, with the advent of NoSQL database systems, the need to efficiently store and manage unstructured data has increased. To meet these market changes and the needs of the developer community, we officially began supporting JSON data types in MySQL version 5.7.

```sql
CREATE TABLE users (
id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(255),
hobbies JSON
);

INSERT INTO users (name, hobbies) VALUES ('Jane Doe', JSON_ARRAY('독서', '영화 감상', '요리'));

SELECT name, JSON_EXTRACT(hobbies, '$[0]') AS first_hobby FROM users;
```

This example shows a query that stores a user's hobby in an JSON array and queries the first hobby using the **JSON_EXTRACT** function.

### Processing in PostgreSQL

PostgreSQL allows you to declare the Array type, as mentioned above, and you can use query statements as you would normally approach an array.

```sql
name VARCHAR(255),
hobbies TEXT[]
);

INSERT INTOUSERS (name, hobbies) VALUES ("Jane Doe," "Reading," "Watching Movies," "Cooking");

SELECT name, hobbies[1] AS first_hobby FROM users;
```

## Clean up

We have summarized the RDBs that support the Array type and the RDBs that do not support the Array type. As mentioned earlier, DBs are absolutely not good, and depending on the design philosophy, we need to think a lot about which DB will be suitable for the service we are currently operating.