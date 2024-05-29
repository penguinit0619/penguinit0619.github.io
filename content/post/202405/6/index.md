+++
author = "penguinit"
title = "Golang에서 Map을 사용할 때 고려해야하는 점들 "
date = "2024-05-29"
description = "Golang에서 Map은 자주 사용되는 자료구조 중 하나입니다. 하지만 Map을 사용할 때 주의해야할 점들이 있습니다. 이번 포스팅에서는 Golang에서 Map을 사용할 때 고려해야하는 점들에 대해서 알아보려고 합니다."
tags = [
"golang"
]
categories = [
"language"
]
+++

## 개요
Golang에서 Map은 자주 사용되는 자료구조 중 하나입니다. 하지만 Map을 사용할 때 주의해야할 점들이 있습니다. 이번 포스팅에서는 Golang에서 Map을 사용할 때 고려해야하는 점들에 대해서 알아보려고 합니다.

## Golang에서 Map의 선언

Golang에서 Map을 선언하는 방법은 아래와 같습니다.

- Map 선언 및 초기화

```go
myMap := make(map[string]int)

myMap["key1"] = 100
myMap["key2"] = 200

fmt.Println(myMap["key1"]) // 100
```

- 값 삭제

```go
delete(myMap, "key1")
```

- 값 존재 여부 확인

```go
value, exists := myMap["key2"]
if exists {
    fmt.Println("Value for key2:", value)
} else {
    fmt.Println("Key2 does not exist")
}
```

## 성능 관점에서의 Map
맵을 초기화할 때 예상되는 크기를 지정하면 성능 향상을 기대할 수 있습니다.

```go
package main

import (
    "fmt"
    "time"
)

func main() {
    // 크기를 지정하지 않은 맵
    start := time.Now()
    map1 := make(map[int]int)
    for i := 0; i < 1000000; i++ {
        map1[i] = i
    }
    elapsed := time.Since(start)
    fmt.Printf("Without size: %s\n", elapsed)

    // 크기를 지정한 맵
    start = time.Now()
    map2 := make(map[int]int, 1000000)
    for i := 0; i < 1000000; i++ {
        map2[i] = i
    }
    elapsed = time.Since(start)
    fmt.Printf("With size: %s\n", elapsed)
}
```

- 결과
```
Without size: 93.496583ms
With size: 39.520625ms
```

위에 보면 크기를 지정한 맵이 더 빠르게 초기화되는 것을 확인할 수 있습니다. 이는 맵이 커질수록 해시 테이블을 재조정해야하는데(리해싱), 초기에 크기를 지정하면 이 작업을 줄일 수 있기 때문입니다.

[해시 테이블 (hash table) 리해싱(rehashing)에 대해서 알아보기](/post/202405/5/)


## Map의 특성
Map의 특성을 이해하고 사용하는 것이 중요합니다. 그렇지 않으면 예상치 못한 결과가 발생할 수 있습니다.

### Golang의 맵은 키 순서대로 정렬되지 않음
Golang 맵은 키 순서대로 정렬되지 않습니다. for 루프를 사용하여 순회할 때마다 순서가 변경될 수 있습니다.

```go
package main

import "fmt"

func main() {
    myMap := map[string]int{
        "apple":  5,
        "banana": 3,
        "cherry": 8,
    }

    for key, value := range myMap {
        fmt.Println(key, value)
    }
}

```

- 결과
```
cherry 8
apple 5
banana 3
```

### Loop에서 Map에 추가된 요소는 그 회차에 생성되는 것을 보장할 수 없음
맵을 순회하는 동안 맵에 요소를 추가하면, 추가된 요소가 그 회차에 추가될 수도 있고 아닐 수도 있습니다.

```go
package main

import "fmt"

func main() {
    myMap := map[string]int{
        "apple":  5,
        "banana": 3,
    }

    for key, value := range myMap {
        fmt.Println(key, value)
        myMap["cherry"] = 8
    }

    fmt.Println("After loop:")
    for key, value := range myMap {
        fmt.Println(key, value)
    }
}
```

```
apple 5
banana 3
After loop:
apple 5
banana 3
cherry 8
```

## 정리
Golang에서 Map을 선언하고 사용하는 법에 대해서 간단하게 소개하였고 Map 사용시 성능적인 측면과 특성에 대해서 알아보았습니다. Map은 많이 사용되는 자료구조 중 하나이므로 잘 이해하고 사용하는 것이 중요합니다.