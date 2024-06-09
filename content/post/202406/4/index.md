+++
author = "penguinit"
title = "MYSQL8.0에서 ONLY_FULL_GROUP_BY관련 에러"
date = "2024-06-09"
description = "이번 포스팅에서는 MYSQL에서 발생하는 ONLY_FULL_GROUP_BY에러 관련해서 왜 발생하고 어떻게 해결할 수 있는지에 대해서 알아보려고 합니다."
tags = [
"mysql"
]
categories = [
"database"
]
+++

## 개요
이번 포스팅에서는 MYSQL에서 발생하는 ONLY_FULL_GROUP_BY에러 관련해서 왜 발생하고 어떻게 해결할 수 있는지에 대해서 알아보려고 합니다.

## 문제상황

아래와 같이 테이블을 생성하고 GROUP BY 쿼리를 실행했습니다.

```sql
-- 예시 테이블 생성
CREATE TABLE example (
    id INT,
    name VARCHAR(50),
    value INT
);

-- 데이터 삽입
INSERT INTO example (id, name, value) VALUES
(1, 'Alice', 10),
(2, 'Bob', 20),
(3, 'Charlie', 30),
(1, 'Mike', 40),
(2, 'Bob', 50);

-- 쿼리 실행
SELECT id, name, SUM(value)
FROM example
GROUP BY id;
```

단순히 봤을 때 문제가 없어보이지만 에러가 발생합니다.

```
[42000][1055] Expression #2 of SELECT list is not in GROUP BY clause and
contains nonaggregated column 'example.name' 
which is not functionally dependent on columns in GROUP BY clause; 
this is incompatible with sql_mode=only_full_group_by
```

## ONLY_FULL_GROUP_BY 에러란
GROUP BY 절에 포함된 열 이외의 열을 선택할 때 그 열이 집계 함수(예: SUM(), COUNT(), AVG())에 포함되지 않으면 에러를 발생시킵니다.

> GROUP BY 절에 포함된 열 이외의 열을 SELECT 절에 사용할 때는 집계 함수를 사용해야합니다.

`MySQL 5.7.5 버전` 이후로 ONLY_FULL_GROUP_BY SQL 모드는 기본적으로 활성화되어 있습니다.

### 해결방법
1. GROUP BY 절에 포함된 열 이외의 열을 SELECT 절에 사용할 때 집계 함수를 사용합니다.
2. SQL 모드를 변경하여 ONLY_FULL_GROUP_BY를 비활성화합니다.

### SQL 모드 변경
```sql
-- 현재 SQL 모드 확인
SELECT @@sql_mode;

-- SQL 모드 변경 (해당 세션에서만 적용)
SET sql_mode = REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', '');
```

위와 같이 SQL 모드를 변경하면 ONLY_FULL_GROUP_BY 에러를 해결할 수 있습니다. 하지만 이 방법은 해당 세션에서만 적용되기 때문에 다시 접속하게 되면 원래대로 돌아가게 됩니다. 영구적으로 적용하려면 설정 파일을 변경해야 합니다.

### 설정 파일 변경
- 설정 파일 위치: `/etc/my.cnf`
- sql_mode를 확인하고 ONLY_FULL_GROUP_BY 필드를 제거해서 변경 
- MYSQL 재시작

```
[mysqld]
sql_mode = STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION
```

### ONLY_FULL_GROUP_BY 의의
ONLY_FULL_GROUP_BY는 SQL 표준을 준수하도록 도와주는 옵션입니다. 해당 옵션이 없다면 데이터의 무결성을 보장할 수 없기 때문에 에러를 발생시킵니다.

예를 들어서 GROUP BY 절에 포함된 열 이외의 열을 SELECT 절에 사용했을 때 집계 함수를 사용하지 않는 경우 데이터가 무작위로 출력될 수 있습니다. 

- ID 1번 데이터는 Alice, Mike가 있습니다.
- GROUP BY ID(1)로 묶었을 때 name은 Alice로 출력될지 Mike로 출력될지 알 수 없습니다.

## 정리
ONLY_FULL_GROUP_BY 에러는 GROUP BY 절에 포함된 열 이외의 열을 SELECT 절에 사용할 때 집계 함수를 사용하지 않았을 때 발생하는 에러입니다. 오늘 포스팅에서는 에러가 발생하는 이유와 해결 방법에 대해서 알아보았습니다.