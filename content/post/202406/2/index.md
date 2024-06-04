+++
author = "penguinit"
title = "MYSQL에서 Collation 관련 유의사항"
date = "2024-06-04"
description = "기존에 MYSQL 5.x 버전을 8.x 버전으로 업그레이드하면서 Collation 관련 문제를 겪었는데 이번 포스팅에서는 MYSQL에서 Collation 관련 유의사항에 대해서 알아보려고 합니다."
tags = [
"mysql", "collation", "charater-set"
]
categories = [
"database"
]
+++

## 개요
기존에 MYSQL 5.x 버전을 8.x 버전으로 업그레이드하면서 Collation 관련 문제를 겪었는데 이번 포스팅에서는 MYSQL에서 Collation 관련 유의사항에 대해서 알아보려고 합니다.

## Collation이란?
Collation은 데이터베이스에서 문자열을 비교하거나 정렬할 때 사용하는 규칙을 의미합니다. 문자열을 비교할 때 대소문자를 구분하거나, 문자열의 길이를 비교할 때 사용하는 규칙을 Collation이라고 합니다.

## Charater-Set이란?
Charater-Set은 문자열을 저장할 때 사용하는 문자 집합을 의미합니다. 좀 더 쉽게 설명하면 저장된 문자열 데이터를 어떻게 인코딩하고 처리할지를 결정하는 중요한 값이고 대표적으로 utf8mb4, utf8등이 있습니다.


## 문제상황
내부에서 특정 테이블끼리 JOIN문 수행시 아래와 같이 에러가 발생했습니다.

```
Illegal mix of collations (utf8mb4_unicode_ci,IMPLICIT) and (utf8mb4_0900_ai_ci,IMPLICIT)
```

원인은 서로 다른 Collation끼리 비교를 하게 되면서 발생한 문제였습니다. MYSQL 8.x 버전에서는 기본적으로 utf8mb4_0900_ai_ci로 설정되어 있어서 기존에 utf8mb4_unicode_ci로 설정되어 있는 테이블과 비교를 하게 되면서 발생한 문제였습니다.

### 왜 알지 못하였을까?
기존에 Collation 관련해서 확인했을 때 특별한 문제가 없었기 때문에 알지 못했습니다. 테이블의 상세 속성들을 조회해 보았을 때 Collation이나 Charater-Set이 utf8mb4_unicode_ci로 설정되어 있었기 때문에 문제가 없다고 생각했습니다.

하지만 MYSQL 8.x에서 생성되었던 테이블들의 컬럼이 모두 utf8mb4_0900_ai_ci로 설정되어 있었고 이전에 만들었던 테이블들 끼리는 문제가 없었지만 새로 만든 테이블과 JOIN을 하게 되면서 문제를 인지하게 되었습니다.

## 관련 스크립트
문제 해결과정에서 참고하였던 SQL 구문들에 대해서 정리를 해보았습니다. `{value}` 값은 각자의 환경에 맞게 변경하시면 됩니다. 

- Collation은 `utf8mb4_unicode_ci`로 변경하였습니다.
- Character-Set은 `utf8mb4`로 변경하였습니다.

### 테이블의 Collation 확인

```sql
SHOW TABLE STATUS WHERE Name = '{table_name}';
```

### 테이블의 Collation 변경

```sql
ALTER TABLE {table_name} CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 테이블의 Column Collation 확인

```sql
SELECT COLUMN_NAME, COLLATION_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = '{database_name}' AND TABLE_NAME = '{table_name}';
```

### 테이블의 Column Collation 변경
해당 부분은 테이블 컬럼을 일괄적으로 변경할 수 있는 명령은 없기 때문에 각 컬럼별로 변경해야 합니다. 이를 위한 스크립트를 출력하는 SQL문 입니다.

```sql
SELECT Concat('ALTER TABLE {table_name} MODIFY ', column_name, ' ', column_type,
              ' CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;') AS
           sql_statement
FROM   information_schema.columns
WHERE  table_schema = '{database_name}'
AND table_name = '{table_name}'
AND data_type IN ( 'char', 'varchar', 'text', 'mediumtext', 'longtext' ); 
```

## 정리
Collation 관련 문제는 MYSQL 8.x 버전에서는 더욱 더 엄격하게 검사를 하기 때문에 이러한 문제가 발생할 수 있습니다. 특히 MYSQL 5.x 버전에서는 Collation 관련해서 큰 문제가 없었기 때문에 이러한 문제를 인지하지 못할 수 있습니다. 따라서 MYSQL 8.x 버전으로 업그레이드를 할 때는 Collation 관련해서 유의해야 합니다. 테이블 생성은 데이터베이스의 전역설정을 따라가기 때문에 이러한 문제를 방지하기 위해서 테이블을 생성할 때 Collation을 명시적으로 설정하는 것도 좋은 방법이라고 생각합니다.
