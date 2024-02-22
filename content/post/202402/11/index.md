+++
author = "penguinit"
title = "CTE(Common Table Expression)란 무엇인가?"
date = "2024-02-21"
description = "쿼리를 작성하다 보면, 때때로 JOIN 문을 여러 개 사용해야 하는 상황이 발생합니다. 이런 경우 가독성이 저하될 수 있습니다. CTE(Common Table Expression)를 활용하면 쿼리의 가독성을 높일 수 있습니다."
tags = [
"cte",
]
categories = [
"database",
]
+++

## 개요

쿼리를 작성하다 보면, 때때로 JOIN 문을 여러 개 사용해야 하는 상황이 발생합니다. 이런 경우 가독성이 저하될 수 있습니다. CTE(Common Table Expression)를 활용하면 쿼리의 가독성을 높일 수 있습니다.

## CTE란 무엇인가

CTE(Common Table Expression)는 SQL에서 일시적인 결과 집합을 정의하는 데 사용되는 기능입니다. CTE는 복잡한 쿼리를 더 쉽게 읽고 관리할 수 있는 여러 논리적 단계로 분할할 수 있습니다. CTE는 **`WITH`** 구문을 사용해 정의되며, 쿼리 내에서 일시적으로 생성되어 해당 쿼리 실행 동안에만 존재합니다.

CTE는 특히 **재귀 쿼리**를 작성하거나 데이터의 계층적 구조와 복잡한 **조인 연산**을 단순화할 때 유용합니다.

## 활용 예

CTE는 쿼리문을 논리적으로 쉽게 이해할 수 있도록 도와줍니다.

### 기본 사용

```sql
WITH CTE_Name AS (
    SELECT 컬럼명1, 컬럼명2
    FROM 테이블명
    WHERE 조건
)
SELECT *
FROM CTE_Name;
```

위와 같이 간단하게 사용할 수 있으며, WITH 구문은 쿼리 수행 동안 참조할 수 있습니다.

### 재귀문에 사용

```sql
WITH RECURSIVE SubCategories AS (
    SELECT
        CategoryId,
        ParentCategoryId,
        Name,
        1 AS Level -- 시작 레벨을 1로 설정
    FROM
        Categories
    WHERE
        CategoryId = 1 -- 시작 카테고리 ID

    UNION ALL

    SELECT
        c.CategoryId,
        c.ParentCategoryId,
        c.Name,
        sc.Level + 1 -- 하위 레벨 증가
    FROM
        Categories c
            JOIN SubCategories sc ON c.ParentCategoryId = sc.CategoryId
)
SELECT *
FROM SubCategories
ORDER BY Level, CategoryId;
```

위 예제에서는 `CategoryId`가 1인 카테고리를 시작점으로 하여, 해당 카테고리 및 모든 하위 카테고리를 조회합니다. `RECURSIVE` 키워드로 시작하는 CTE는 두 부분으로 구성됩니다. 기본 케이스와 재귀적 케이스입니다.

- **기본 케이스**: 최초의 `SELECT` 문은 재귀의 시작점을 정의합니다. 여기서는 `CategoryId`가 1인 카테고리를 선택합니다.
- **재귀적 케이스**: `UNION ALL` 다음의 `SELECT` 문은 재귀적으로 하위 카테고리를 조회합니다. 이 쿼리는 자기 자신을 참조하는 **`SubCategories`** CTE를 사용하여, 각 단계에서 부모 카테고리의 하위 카테고리를 찾습니다.

**`Level`** 열은 각 카테고리가 최초 카테고리로부터 얼마나 깊이 있는지를 나타내는 계층 레벨을 보여줍니다. 이를 통해 각 카테고리의 계층 구조를 쉽게 이해할 수 있습니다.

**실제수행**

1. DDL, 테스트 데이터 삽입

   ```sql
   CREATE TABLE Categories (
       CategoryId INT AUTO_INCREMENT PRIMARY KEY,
       ParentCategoryId INT NULL,
       Name VARCHAR(255),
       FOREIGN KEY (ParentCategoryId) REFERENCES Categories(CategoryId)
   );
   
   INSERT INTO Categories (CategoryId, ParentCategoryId, Name) VALUES
   (1, NULL, 'Electronics'),
   (2, 1, 'Computers'),
   (3, 2, 'Laptops'),
   (4, 2, 'Desktops'),
   (5, 1, 'Cameras'),
   (6, 5, 'DSLR'),
   (7, 5, 'Point & Shoot');
   ```

2. 쿼리수행

   ```sql
   +------------+------------------+---------------+-------+
   | CategoryId | ParentCategoryId | Name          | Level |
   +------------+------------------+---------------+-------+
   |          1 |             NULL | Electronics   |     1 |
   |          2 |                1 | Computers     |     2 |
   |          5 |                1 | Cameras       |     2 |
   |          3 |                2 | Laptops       |     3 |
   |          4 |                2 | Desktops      |     3 |
   |          6 |                5 | DSLR          |     3 |
   |          7 |                5 | Point & Shoot |     3 |
   +------------+------------------+---------------+-------+
   ```

### 복잡한 JOIN문

- `Products` 테이블: 제품 정보를 저장합니다.
- `Sales` 테이블: 각 판매 거래의 세부 사항을 저장합니다.
- `Employees` 테이블: 직원 정보를 저장합니다.

```sql
-- ProductSales CTE
WITH ProductSales AS (
    SELECT
        p.ProductId,
        p.ProductName,
        SUM(s.Quantity) AS TotalQuantity
    FROM
        Products p
            JOIN
        Sales s ON p.ProductId = s.ProductId
    GROUP BY
        p.ProductId, p.ProductName
),

-- EmployeeSales CTE
     EmployeeSales AS (
         SELECT
             e.EmployeeId,
             e.EmployeeName,
             s.ProductId,
             SUM(s.Quantity) AS QuantitySold
         FROM
             Sales s
                 JOIN
             Employees e ON s.EmployeeId = e.EmployeeId
         GROUP BY
             e.EmployeeId, e.EmployeeName, s.ProductId
     )

-- 메인 쿼리
SELECT
    ps.ProductName,
    ps.TotalQuantity,
    es.EmployeeName,
    es.QuantitySold
FROM
    ProductSales ps
        JOIN
    EmployeeSales es ON ps.ProductId = es.ProductId
ORDER BY
    ps.ProductName, es.EmployeeName;
```

- ProductSales CTE: `Products`와 `Sales` 테이블을 JOIN하여 각 제품별 총 판매량(TotalQuantity)을 계산합니다.
- EmployeeSales CTE: `Sales`와 `Employees` 테이블을 JOIN하여 각 직원별로 판매한 제품과 그 수량(QuantitySold)을 계산합니다.
- 최종 `SELECT` 문에서 `ProductSales`와 `EmployeeSales` CTE를 JOIN하여, 각 제품별로 총 판매량과 해당 제품을 판매한 직원의 이름 및 판매량을 포함하는 결과를 생성합니다.

**실제수행**

1. DDL, 테스트 데이터 삽입

   ```sql
   CREATE TABLE Products (
       ProductId INT PRIMARY KEY,
       ProductName VARCHAR(255)
   );
   
   INSERT INTO Products (ProductId, ProductName) VALUES
   (1, 'Laptop'),
   (2, 'Smartphone'),
   (3, 'Tablet');
   
   CREATE TABLE Employees (
       EmployeeId INT PRIMARY KEY,
       EmployeeName VARCHAR(255)
   );
   
   INSERT INTO Employees (EmployeeId, EmployeeName) VALUES
   (1, 'John Doe'),
   (2, 'Jane Smith'),
   (3, 'Emily Jones');
   
   CREATE TABLE Sales (
       SaleId INT PRIMARY KEY,
       ProductId INT,
       EmployeeId INT,
       Quantity INT,
       FOREIGN KEY (ProductId) REFERENCES Products(ProductId),
       FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId)
   );
   
   INSERT INTO Sales (SaleId, ProductId, EmployeeId, Quantity) VALUES
   (1, 1, 1, 10),
   (2, 1, 2, 5),
   (3, 2, 1, 8),
   (4, 2, 3, 6),
   (5, 3, 2, 3),
   (6, 3, 3, 2),
   (7, 1, 3, 7),
   (8, 2, 2, 4);
   ```

2. 쿼리수행

   ```sql
   +-------------+---------------+--------------+--------------+
   | ProductName | TotalQuantity | EmployeeName | QuantitySold |
   +-------------+---------------+--------------+--------------+
   | Laptop      |            22 | Emily Jones  |            7 |
   | Laptop      |            22 | Jane Smith   |            5 |
   | Laptop      |            22 | John Doe     |           10 |
   | Smartphone  |            18 | Emily Jones  |            6 |
   | Smartphone  |            18 | Jane Smith   |            4 |
   | Smartphone  |            18 | John Doe     |            8 |
   | Tablet      |             5 | Emily Jones  |            2 |
   | Tablet      |             5 | Jane Smith   |            3 |
   +-------------+---------------+--------------+--------------+
   ```

## CTE 지원여부

| DBMS       | WITH 지원 | WITH RECURSIVE 지원 | 비고                               |
|------------|---------|-------------------|----------------------------------|
| PostgreSQL | 예       | 예                 |                                  |
| MySQL      | 예       | 일부지원              | 버전 8.0 이상에서 WITH RECURSIVE 지원    |
| SQLite     | 예       | 예                 |                                  |
| SQL Server | 예       | 예                 |                                  |
| Oracle     | 예       | 예                 |                                  |
| IBM DB2    | 예       | 예                 |                                  |
| MariaDB    | 예       | 일부지원              | 버전 10.2.2 이상에서 WITH RECURSIVE 지원 |

## 정리

이 포스팅에서는 CTE의 개념과 활용 예제를 통해 CTE가 SQL 쿼리의 가독성과 구조를 개선하는 방법을 살펴보았습니다. CTE는 복잡한 쿼리 작성 시 강력한 도구이지만, 사용 시 데이터 셋의 크기나 재귀 쿼리의 무한 루프 가능성 등 성능과 관련된 사항을 유의해야 합니다.