+++
author = "penguinit"
title = "프로그래밍에서 단조시계(Monotonic Clock)와 벽시계(Wall Clock)란"
date = "2024-06-04"
description = "최근에 책을 읽으면서 단조시계(Monotonic Clock)와 벽시계(Wall Clock)에 대한 이야기가 나왔는데 개념 자체는 이해하고 있지만 생소한 용어라 정리해보고자 합니다."
tags = [
"time"
]
categories = [
"language"
]
+++

## 요약
최근에 책을 읽으면서 단조시계(Monotonic Clock)와 벽시계(Wall Clock)에 대한 이야기가 나왔는데 개념 자체는 이해하고 있지만 생소한 용어라 정리해보고자 합니다.

## 단조시계 (Monotonic Clock)
단조시계란 보통 경과한 시간을 위해서 사용되는 용어로 시스템 시간이 변경되어도 영향을 받지 않으며, 항상 일관된 경과 시간을 제공합니다. 단조시계는 주로 이벤트 간의 경과 시간을 측정하는 데 사용됩니다. 예를 들어, 코드 실행 시간, 네트워크 요청 시간

- 예시코드

```go
package main

import (
    "fmt"
    "time"
)

func main() {
    startTime := time.Now()
    
    // 일부 코드 실행
    time.Sleep(2 * time.Second)  // 예시로 2초 대기

    elapsedTime := time.Since(startTime)
    fmt.Printf("Elapsed time: %s\n", elapsedTime)
}
```

## 벽시계 (Wall Clock)
벽시계는 시스템 시간을 나타내는 시계로, 시스템 시간이 변경되면 영향을 받습니다. 벽시계는 주로 시간 기반의 작업을 수행할 때 사용됩니다. 예를 들어, 타임스탬프 기록, 로그 생성등에서 이용됩니다.

```go
package main

import (
    "fmt"
    "time"
)

func main() {
    currentTime := time.Now()  // 현재 로컬 시간

    // 현재 시간을 인간이 읽을 수 있는 형식으로 변환
    formattedTime := currentTime.Format("2006-01-02 15:04:05")
    fmt.Printf("Current local time: %s\n", formattedTime)

    // UTC 시간으로 변환
    utcTime := currentTime.UTC()
    formattedUTCTime := utcTime.Format("2006-01-02 15:04:05")
    fmt.Printf("Current UTC time: %s\n", formattedUTCTime)
}
```

## 정리
시간을 다룰 일이 많은데 대표적인 개념인 단조시계(Monotonic Clock)와 벽시계(Wall Clock)에 대해서 알아보았습니다. 단조시계는 시스템 시간이 변경되어도 영향을 받지 않는 시계로 경과 시간을 측정하는 데 사용되며, 벽시계는 시스템 시간이 변경되면 영향을 받는 시계입니다.
모두 이해하고 있는 개념이지만 자칫 용어가 생소할 수 있기에 이번 기회에 정리해보았습니다.