+++
author = "penguinit"
title = "DBMS에서 DDL, DML, DCL, TCL 알아보기"
date = "2024-03-26"
description = "보통은 쿼리문이라고 통쳐서 업무중에 자주 말하게 되는데 DDL, DML, DCL, TCL 각 용어에 대해서 어떤 차이와 특징들이 있는지에 대해서 정확히 이해를 하고 있지 않아서 포스팅을 통해서 정리하려고 합니다."
tags = [
"ddl","dcl","dml","tcl"
]
categories = [
"database"
]
+++

## 개요

보통은 쿼리문이라고 통쳐서 업무중에 자주 말하게 되는데 DDL, DML, DCL, TCL 각 용어에 대해서 어떤 차이와 특징들이 있는지에 대해서 정확히 이해를 하고 있지 않아서 포스팅을 통해서 정리하려고 합니다.

## DDL

DDL은 Data Definition Language의 약어로 데이터베이스 스키마를 생성, 변경, 삭제하는데 사용되는 언어입니다. 이 언어의 명령어는 데이터베이스 구조를 정의하는데 사용되며, 테이블, 인덱스, 제약조건 등의 데이터베이스 객체를 생성, 변경, 삭제할 수 있습니다. DDL의 주요 명령어에는 `CREATE`, `ALTER`, `DROP` 등이 있습니다.

- `CREATE`: 새로운 데이터베이스, 테이블, 인덱스 등을 생성합니다.
- `ALTER`: 기존의 데이터베이스 객체를 수정합니다.
- `DROP`: 기존의 데이터베이스 객체를 삭제합니다.

## DML

DML은 Data Manipulation Language의 약어로 데이터베이스 내의 데이터를 실제로 조작하는 데 사용되는 언어입니다. 데이터를 삽입, 조회, 수정, 삭제하는 작업을 수행할 수 있습니다. DML의 주요 명령어에는 `SELECT`, `INSERT`, `UPDATE`, `DELETE` 등이 있습니다.

- `SELECT`: 데이터베이스에서 데이터를 조회합니다.
- `INSERT`: 데이터베이스에 새로운 데이터를 삽입합니다.
- `UPDATE`: 데이터베이스의 기존 데이터를 수정합니다.
- `DELETE`: 데이터베이스에서 데이터를 삭제합니다.

## DCL

DCL은 Data Control Language의 약어로 데이터베이스에 대한 접근을 제어하는 데 사용되는 언어입니다. 사용자에게 데이터베이스 객체에 대한 권한을 부여하거나 회수하는 작업을 포함합니다. DCL의 주요 명령어에는 `GRANT`, `REVOKE` 등이 있습니다.

- `GRANT`: 사용자에게 데이터베이스 객체에 대한 권한을 부여합니다.
- `REVOKE`: 사용자에게 부여된 권한을 회수합니다.

## TCL

TCL은 Transaction Control Language의 약어로 데이터베이스에서의 트랜잭션을 관리하는 데 사용되는 언어입니다. 트랜잭션은 하나의 논리적 작업 단위로, 여러 DML 명령어들을 묶어서 하나의 작업으로 처리할 수 있습니다. TCL의 명령어로는 `COMMIT`, `ROLLBACK`, `SAVEPOINT` 등이 있습니다.

- `COMMIT`: 트랜잭션을 완료하고, 모든 변경 사항을 데이터베이스에 반영합니다.
- `ROLLBACK`: 트랜잭션을 취소하고, 변경 사항을 되돌립니다.
- `SAVEPOINT`: 트랜잭션 내에서 롤백할 수 있는 지점을 설정합니다.

## 트랜잭션 지원 여부

최근에 MYSQL을 사용하고 있는데 DDL 트랜잭션 지원에 일부 제약이 있다라는 것을 알게되었습니다. TCL을 제외하고 DDL, DML, DCL에 대해서 DBMS 별 트랜잭션 지원 여부를 표로 나타내 보았습니다.

| DBMS       | DDL 트랜잭션 지원 | DML 트랜잭션 지원 | DCL 트랜잭션 지원 |
|------------|-------------|-------------|-------------|
| MySQL      | 부분적[*]      | 지원          | 부분적         |
| PostgreSQL | 지원          | 지원          | 지원          |
| Oracle     | 지원          | 지원          | 지원          |
| SQL Server | 지원          | 지원          | 부분적         |

⚠️MYSQL에서는 일부 DDL 작업이 트랜잭션의 일부로 실행될 수 있지만, 모든 DDL 작업이 트랜잭션으로 관리되는 것은 아닙니다.

### MYSQL에서 DDL 트랜잭션

운영을 하다보면 컬럼을 추가하거나 삭제하거나 하는 경우가 많이 있습니다. InnoDB 엔진기반의 MYSQL의 경우에는 특정 상황에서는 DDL의 트랜잭션을 보장하지 못할 수 있기에 해당 부분을 고려해서 쿼리를 작성하실 필요가 있습니다.

### 트랜잭션으로 관리되는 DDL

- 테이블에 대한 ALTER 작업: 테이블 구조를 변경하는 작업은 트랜잭션으로 관리될 수 있으며, 롤백이 가능합니다. 예를 들어, 테이블에 새로운 컬럼을 추가하거나 삭제하는 경우입니다.

    ```sql
    START TRANSACTION;
    ALTER TABLE my_table ADD COLUMN new_column INT;
    ROLLBACK;
    ```

- 테이블에 대한 CREATE INDEX와 DROP INDEX 작업: 인덱스를 생성하거나 삭제하는 작업도 트랜잭션의 일부로 실행되며 롤백될 수 있습니다.

    ```sql
    START TRANSACTION;
    CREATE INDEX idx_name ON my_table(column_name);
    ROLLBACK;
    ```


### 트랜잭션으로 관리되지 않는 DDL

- 데이터베이스와 테이블의 CREATE와 DROP 작업: 데이터베이스 또는 테이블을 생성하거나 삭제하는 작업은 즉시 커밋되며, 트랜잭션으로 롤백할 수 없습니다.

    ```sql
    CREATE DATABASE test_db;
    DROP TABLE my_table;
    ```

- RENAME TABLE 작업: 테이블 이름을 변경하는 작업은 트랜잭션으로 관리되지 않습니다.

    ```sql
    RENAME TABLE old_table_name TO new_table_name;
    ```


## 정리

DBMS에서 사용되는 DDL, DML, DCL, TCL각 용어들의 정의에 대해서 알아보았고 트랜잭션 지원 여부도 같이 알아보았습니다. 특히 MYSQL의 경우에는 다른 DBMS와 다르게 특정 DDL의 경우에는 트랜잭션이 보장되지 않는다는 것을 알 수 있습니다.
업무를 하시면서 쿼리문으로 모두 퉁쳐서 말하는 것보다는 좀 더 명확한 용어(DDL, DML, DCL, TCL)로 의사를 전달하시는 것도 좋은 것 같습니다.
