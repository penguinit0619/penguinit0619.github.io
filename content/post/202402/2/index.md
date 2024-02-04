+++
author = "penguinit"
title = "RDB에서 Array 타입"
date = "2024-02-04"
description = "최근에 회사를 옮기면서 MYSQL을 사용하게 되었는데  리스트로 값을 받을 일이 있었는데 확인해보니 MYSQL 자체에 ARRAY 타입이 없다는 것을 알게 되어서 간단하게 정리를 해보고자 합니다."
tags = [
    "mysql", "postgresql"
]

categories = [
    "database",
]
+++

## 개요

최근에 회사를 옮기면서 MYSQL을 사용하게 되었는데  리스트로 값을 받을 일이 있었는데 확인해 보니 MYSQL 자체에 ARRAY 타입이 없다는 것을 알게 되어서 간단하게 정리를 해보고자 합니다.

## Array 타입

지금까지 사용했던 RDB가 Oracle과 PostgreSql이라서 너무 당연하게 MYSQL도 Array 타입이 있다고 생각했었습니다. 실제로는 그렇지 않았는데 비슷하게 RDB에서 Array 타입을 지원하는 DB와 아닌 DB에 대해서 정리를 해보았습니다.

| 데이터베이스     | 배열 타입 지원 | 비고                                              |
|------------|----------|-------------------------------------------------|
| PostgreSQL | 지원함      | 다양한 데이터 타입에 대한 네이티브 배열 타입 지원.                   |
| MySQL      | 지원하지 않음  | 기본적으로 배열 타입을 지원하지 않으나, 유사한 목적으로 JSON을 사용할 수 있음. |
| Oracle     | 지원함      | VARRAY와 같은 컬렉션 타입을 지원함.                         |
| SQL Server | 지원하지 않음  | 기본적으로 배열 타입을 지원하지 않음.                           |
| SQLite     | 지원하지 않음  | 기본적으로 배열 타입을 지원하지 않으나, 텍스트로 간단한 리스트를 저장할 수 있음.  |
| MariaDB    | 지원하지 않음  | MySQL과 유사하게 기본적으로 배열 타입을 지원하지 않음.               |
| IBM Db2    | 지원함      | ARRAY 데이터 타입을 통해 배열 타입을 지원함.                    |

### MYSQL에 Array 타입이 없는이유?

MYSQL만 한정해서 보았을 때 초기 설계 철학과 목표를 이해할 필요가 있습니다. 배열이라는 타입이 들어옴으로써 단순성과 성능 측면에서 더 복잡한 처리를 필요로 했던 부분도 있었고 관계형 데이터 모델링 관점에서 Array 타입은 정규화 원칙에 어긋나는 부분이 있고 무결성 관리를 복잡하게 만드는 측면이 있었습니다. 특히 표준 SQL을 따름으로써 A라는 데이터베이스에서 B라는 데이터베이스로 쉽게 이전할 수 있도록 설계를 했었는데 이 부분도 많은 영향을 주었던 것 같습니다.

### PostgreSQL에는 Array 타입이 있는 이유?

해당 부분도 초기 PostgreSQL이 설계 당시 가지고 있던 철학을 이해하고 있어야 합니다. PostgreSQL은 사이트에 들어가 보시면 이런 문구가 있습니다.

**“The World's Most Advanced Open Source Relational Database”**

설계 단계에서부터 다양한 고급 기능과 유연한 데이터 타입 지원을 통해서 이런 목표를 달성하려고 노력했고 배열 타입도 PostgreSQL이 추구하는 주요 목표를 이루기 위한 한 가지 일환이라고 보시면 될 것 같습니다.

약간 오해가 있을 수도 있는 부분이 그러면 PostgreSQL이 고급 쿼리도 지원하고 다양한 타입들도 지원하니깐 MYSQL 보다 더 좋은 데이터베이스가 아니냐라고 생각할 수 있는데 항상 모든 것에는 장단이 있듯이 MYSQL도 PostgreSQL보다 이점이 있는 부분이 있고 반대로 PostgreSQL이 MYSQL에 비해서 이점이 있는 부분들이 있으니 개발하시는 비즈니스 요구사항에 맞는 데이터베이스를 적절하게 선택하면 될 것 같습니다.

## 대안

그러면 MYSQL에서는 Array타입이 없으니 무조건 정규화해서 저장을 해야 하나라고 생각할 수 있지만 그렇지만도 않습니다. 전통적으로는 특정 구분자 (”,”) 를 통해서 텍스트로 저장해서 가져오는 방법도 있고 아래 설명한 JSON 타입을 이용해서 Array 타입을 유사하게 사용할 수 있습니다.

### MYSQL JSON 타입

웹 기술과 애플리케이션의 발전으로 인해 데이터 저장 및 처리의 요구 사항이 다양해지고 복잡해졌습니다. 특히, NoSQL 데이터베이스 시스템의 등장과 함께 비정형 데이터를 효율적으로 저장하고 관리할 수 있는 필요성이 증가했습니다. 이러한 시장의 변화와 개발자 커뮤니티의 요구에 부응하기 위해 MySQL 5.7 버전부터 공식적으로 JSON 데이터 타입을 지원하기 시작했습니다.

```sql
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    hobbies JSON
);

INSERT INTO users (name, hobbies) VALUES ('Jane Doe', JSON_ARRAY('독서', '영화 감상', '요리'));

SELECT name, JSON_EXTRACT(hobbies, '$[0]') AS first_hobby FROM users;
```

해당 예시는 사용자의 취미를 JSON 배열로 저장하고, **JSON_EXTRACT** 함수를 사용하여 첫 번째 취미를 조회하는 쿼리를 보여줍니다.

### PostgreSQL에서의 처리

PostgreSQL에서는 위에서 언급했듯이 Array 타입을 선언할 수 있고 일반적으로 배열에 접근하듯이 쿼리문을 사용할 수 있습니다.

```sql
name VARCHAR(255),
    hobbies TEXT[]
);

INSERT INTO users (name, hobbies) VALUES ('Jane Doe', ARRAY['독서', '영화 감상', '요리']);

SELECT name, hobbies[1] AS first_hobby FROM users;
```

## 정리

Array 타입을 지원하는 RDB와 지원하지 않는 RDB에 대해서 정리를 해보았고 특히 MYSQL에서 왜 Array 타입을 지원하지 않는지에 대해서 정리를 해보았습니다. 앞에서 언급했듯이 DB는 절대적으로 좋다는 것이 없고 설계 철학에 따라서 현재 운영하고 있는 서비스에 어떤 DB가 적합할지에 대해서 많은 고민들이 필요합니다.