+++
author = "penguinit"
title = "What is Common Table Expression (CTE)?"
date = "2024-02-21"
description = "When writing queries, we sometimes run into situations where we need to use multiple JOIN statements. This can lead to poor readability. Utilizing a Common Table Expression (CTE) can help make your queries more readable."
tags = [
"cte",
]
categories = [
"database",
]
+++

## Overview

When writing queries, you will sometimes encounter situations where you need to use multiple JOIN statements. This can lead to poor readability. You can make your queries more readable by utilizing the Common Table Expression (CTE).

## What is CTE

Common Table Expression (CTE) is a feature used in SQL to define temporary result sets. CTEs can break complex queries into multiple logical steps that are easier to read and manage. CTEs are defined using the **`WITH`** syntax, and are temporarily created within a query and exist only during the execution of that query.

CTEs are especially useful when writing **recursive queries** or simplifying hierarchical structures of data and complex **join operations**.

## Use cases

CTEs help make query statements easier to understand logically.

### Basic usage

```sql
WITH CTE_Name AS (
    SELECT ColumnName1, ColumnName2
    FROM table name
    WHERE Condition
)
SELECT
FROM CTE_Name;
```

It's as simple as the above, and the WITH statement can be referenced while performing the query.

### Used in recursive statements

```sql
WITH RECURSIVE SubCategories AS (
    SELECT
        CategoryId,
        ParentCategoryId,
        Name,
        1 AS Level -- Set the starting level to 1
    FROM
        Categories
    WHERE
        CategoryId = 1 -- starting category ID

    UNION ALL

    SELECT
        c.CategoryId,
        c.ParentCategoryId,
        c.Name,
        sc.Level + 1 -- increase child level
    FROM
        Categories c
            JOIN SubCategories sc ON c.ParentCategoryId = sc.CategoryId
)
SELECT * FROM
FROM SubCategories
ORDER BY Level, CategoryId;
```

The above example starts with a category with a `CategoryId` of 1 and retrieves that category and all of its subcategories. A CTE that starts with the `RECURSIVE` keyword consists of two parts. The base case and the recursive case.

- Base case: The first `SELECT` statement defines the starting point for the recursion. In this case, we select a category with a `CategoryId` of 1.
- Recursive case: The `SELECT` statement following the `UNION ALL` recursively looks up the subcategories. The query uses the **`SubCategories`** CTE, which references itself, to find the subcategories of the parent category at each step.

The **`Level`** column shows the hierarchy level, indicating how deep each category is from the initial category. This makes it easy to understand the hierarchy of each category.

**Hands-on**

1. DDL, insert test data

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
   (6, 5, 'DSLRs'),
   (7, 5, 'Point & Shoot');
   ```

2. execute query

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

### Complex JOIN statement

- The `Products` table: Stores product information.
- Sales` table: Stores details of each sales transaction.
- Employees` table: Stores employee information.

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

-- Main query
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

- ProductSales CTE: JOIN the `Products` and `Sales` tables to calculate the total number of sales (TotalQuantity) for each product.
- EmployeeSales CTE: JOIN the `Sales` and `Employees` tables to calculate the products sold by each employee and their quantity (QuantitySold).
- In the final `SELECT` statement, JOIN the `ProductSales` and `EmployeeSales` CTEs to produce a result that includes the total sales for each product and the name of the employee who sold that product and the amount sold.

**Hands-on**

1. DDL, insert test data

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

2. execute the query

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

## CTE Support

| DBMS        | WITH Support | WITH RECURSIVE Support | Remarks                                             |
|-------------|--------------|------------------------|-----------------------------------------------------|
| PostgresSQL | Yes          | Yes                    | Yes                                                 |
| MySQL       | Yes          | Partially supported    | WITH RECURSIVE support in version 8.0 and later     |
| SQLite      | Yes          | Yes                    | Yes                                                 |
| SQL Server  | Yes          | Yes                    | Yes                                                 |
| Oracle      | Yes          | Yes                    | Yes                                                 |
| IBM DB2     | yes          | yes                    | yes                                                 | 
| MariaDB     | Yes          | Partially supported    | Supports WITH RECURSIVE in version 10.2.2 and later |

## Summary

In this post, we've covered the concept of CTEs and how they can improve the readability and structure of SQL queries with examples of their use. While CTEs are a powerful tool for writing complex queries, you should keep performance considerations in mind when using them, such as the size of your dataset and the potential for infinite loops in recursive queries.