+++
author = "penguinit"
title = "일급함수란 무엇인가? Golang을 통해서 알아보기"
date = "2024-03-12"
description = "일급 함수가 무엇인지에 대해서 알아보고 왜 사용하는지 Golang 에제를 통해서 자세히 알아보려고 합니다."
tags = [
"golang", "fp"
]
categories = [
"language"
]
+++

## 개요

일급 함수가 무엇인지에 대해서 알아보고 왜 사용하는지 Golang 에제를 통해서 자세히 알아보려고 합니다.

## 일급 함수란

일급 함수(First-Class Function)란 프로그래밍 언어에서 함수를 일급 시민(First-Class Citizen)으로 취급하는 개념을 말합니다. 즉, 함수를 다른 데이터 타입과 동일한 방식으로 처리할 수 있다는 뜻입니다. 이는 함수를 변수에 할당할 수 있고, 다른 함수의 인자로 전달할 수 있으며, 함수에서 다른 함수를 반환할 수 있음을 의미합니다

### 고차 함수

일급 함수를 지원하는 프로그래밍 언어는 자연스럽게 고차 함수 (Higher-Order Function)도 지원을 하게 됩니다. 고차 함수는 다른 함수를 매개변수로 받거나 함수를 결과로 반환하는 함수를 의미하고 함수가 값으로 취급이 되어야 하기 때문에 일급 함수를 기반으로 고차 함수는 존재하게 됩니다.

### 일급 함수를 지원하는 언어 리스트

이러한 특성을 가진 언어들은 대체로 함수형 프로그래밍 패러다임을 채택하거나 지원하는 경향이 있습니다.

- Javascript
- Python
- Ruby
- Scala
- Haskell
- Lisp
- Elixir
- Go
- Swift
- Rust

## 일급 함수 특징

- **재사용성:** 함수를 변수에 저장하고, 다른 함수로 전달할 수 있게 함으로써, 코드를 더욱 유연하게 재 사용할 수 있습니다.
- **추상화 :** 고차 함수(Higher-Order Functions)를 통해, 보다 추상화된 수준에서 코드를 조작할 수 있습니다. 이는 코드의 가독성과 유지 보수성을 향상시킵니다.

## Golang에서 일급함수 예시

### 변수에 할당

```go
package main

import "fmt"

func main() {
    // 함수를 변수에 할당
    add := func(x, y int) int {
        return x + y
    }

    // 변수를 통해 함수 호출
    result := add(3, 4)
    fmt.Println(result) // 출력: 7
}

```

### 함수를 인자로 받는 함수

```go
package main

import "fmt"

// 인자로 받는 함수의 타입을 정의
func operate(a, b int, operation func(int, int) int) int {
    return operation(a, b)
}

func main() {
    // 더하기 함수
    add := func(a, b int) int {
        return a + b
    }

    // 곱하기 함수
    multiply := func(a, b int) int {
        return a * b
    }

    // operate 함수를 사용하여 더하기와 곱하기 연산 실행
    sum := operate(5, 2, add)
    product := operate(5, 2, multiply)

    fmt.Println("Sum:", sum)       // 출력: Sum: 7
    fmt.Println("Product:", product) // 출력: Product: 10
}
```

Golang 기본 패키지 중 하나인 sort 패키지에서 이런 일급 함수의 특징을 이용해서 함수를 구현하고 있습니다.

### Sort 패키지

```go
package main

import (
    "fmt"
    "sort"
)

func main() {
    numbers := []int{4, 2, 3, 1, 5}

    // sort.Slice 함수는 슬라이스와 슬라이스 내 두 요소의 인덱스를 인자로 받는 비교 함수를 사용합니다.
    // 비교 함수가 true를 반환하면 요소들의 순서가 유지됩니다.
    sort.Slice(numbers, func(i, j int) bool {
        return numbers[i] < numbers[j]
    })

    fmt.Println(numbers) // [1, 2, 3, 4, 5] 출력
}
```

이 예시에서 **`sort.Slice`** 함수는 두 번째 인자로 익명 함수를 받습니다. 이 익명 함수는 슬라이스 내 두 요소의 인덱스를 인자로 하여, 정렬 순서를 결정하는 비교 로직을 구현합니다. 이렇게 함수를 다른 함수의 인자로 전달하는 것은 일급 함수의 전형적인 사용 방식입니다.

## 정리

해당 글을 통해서 일급 함수가 무엇인지 그리고 사용했을 때 어떤 이점을 얻을 수 있는지에 대해서 Golang 코드 예제를 통해서 알아보았습니다. 일전에 포스팅했던 [클로저](/post/202403/2/)와 비슷하게 일급 함수 또한 함수형 프로그래밍에서 핵심 개념으로 사용이 됩니다.

현대 프로그래밍 언어에서는 함수형 프로그래밍을 대다수 지원하고 있고 Java에서도 완전히 동일하지는 않지만 함수형 패러다임을 따라가기 위해서 1.8 버전 이후에 람다 표현식과 함수형 인터페이스를 도입하여 이런 추세를 따라가려고 노력했던 과정들이 있었습니다.

저도 현업에서 함수형 프로그래밍을 이용해서 개발을 진행해 본 적은 없지만 시간이 된다면 관련 내용들을 공부해서 포스팅을 하고 싶습니다.