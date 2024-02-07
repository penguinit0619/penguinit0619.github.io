+++
author = "penguinit"
title = "Golang에서 Thread Safe하다는 의미"
date = "2024-02-06"
description = "개발을 하다 보면 최소 한번은 비동기 함수들을 다루는 상황을 맞게 됩니다. 예전에 버릇 처럼했던 말중에 하나가 Thread Safe 라는 용어였는데요 해당 포스팅에서는 해당 용어의 의미와 동시성 처리에 강점이 있다는 Golang에서의 Thread Safe는 어떤 의미를 가지고 있는지 코드를 통해서 알아보려고 합니다."
tags = [
    "golang"
]

categories = [
    "language"
]
+++

## 개요

개발을 하다 보면 최소 한번은 비동기 함수들을 다루는 상황을 맞게 됩니다. 예전에 버릇 처럼했던 말중에 하나가 Thread Safe 라는 용어였는데요 해당 포스팅에서는 해당 용어의 의미와 동시성 처리에 강점이 있다는 Golang에서의 Thread Safe는 어떤 의미를 가지고 있는지 코드를 통해서 알아보려고 합니다.

## Thread Safe란?

멀티 스레드 프로그래밍에서 일반적으로 어떤 함수나 변수, 혹은 객체가 여러 스레드로부터 동시에 접근이 이루어져도 프로그램의 실행에 문제가 없음을 뜻한다. 보다 엄밀하게는 하나의 함수가 한 스레드로부터 호출되어 실행 중일 때, 다른 스레드가 그 함수를 호출하여 동시에 함께 실행되더라도 각 스레드에서의 함수의 수행 결과가 올바로 나오는 것으로 정의한다고 설명되어 있습니다. ([위키문서참조](https://ko.wikipedia.org/wiki/%EC%8A%A4%EB%A0%88%EB%93%9C_%EC%95%88%EC%A0%84))

이해하기 복잡할 수 있는데 간단하게 설명하면 **동시에 수행되는 두 작업이 의도대로 작업을 수행하는 것**을 보장하는 걸 Thread Safe라고 합니다. 그래서 이걸 해결하기 위한 방법도 가지각색이고 문제가 일어나는 상황도 다양한 곳에 산재되어 있어서 동시성 프로그래밍을 할 일이 있으면 항상 내 코드가 Thread Safe 한지 반복적으로 머릿속에서 시뮬레이션 돌렸던 기억이 있습니다.

### Thread Safe 하지 않으면 발생하는 일들

동시성 문제로 일어날 수 있는 일들을 실생활의 예를 통해서 알아보겠습니다.

- 친구와 콘서트 예매를 하기로 했는데 둘 다 티켓팅에 성공해버려서 총 4장의 티켓을 사버림 (원래는 2장을 사려고 했음) → **데이터 무결성 이슈 (data integrity)**
- 두 명이 같은 계정으로 동시에 로그인하려고 시도를 해서 계속 서로 로그아웃이 되어버림 (원래는 한 명만 로그인 할 수 있음) → **데드락 (deadlocks)**
- 공황에서 수화물 검사 시스템은 한 번에 하나의 일만 할 수 있는데 고객들이 수화물을 동시에 검색대에 밀어 넣었을 때 적절하게 처리를 하지 못함 → **데이터 경쟁 (race condition)**

![Untitled](Golang%E1%84%8B%E1%85%A6%E1%84%89%E1%85%A5%20Thread%20Safe%E1%84%92%E1%85%A1%E1%84%83%E1%85%A1%E1%84%82%E1%85%B3%E1%86%AB%20%E1%84%8B%E1%85%B4%E1%84%86%E1%85%B5%203c6dd0195fef489e86812d7a4f97e5b9/Untitled.png)

위 그림처럼 동시에 공유하고 있는 자원에 접근해서 읽고 값을 더해서 할당하는 로직이 있다고 가정하면 실제 유저가 의도한 것은 더하는 행동이 중첩되어야 하지만 읽을 당시에 1의 값을 인지했기 때문에 의도와 다르게 프로그래밍이 동작할 확률이 높습니다.

### Thread Safe하게 코드 작성하기

이 부분은 개발에서 요구하는 상황에 따라서 달라지겠지만 동시성 프로그래밍을 할 때는 아래 같은 문제가 없는지 고민해 봐야 합니다.

- 데이터 무결성 이슈 (data integrity)
- 데드락 (deadlocks)
- 데이터 경쟁 (race condition)

**이를 해결하기 위해서는 아래와 같은 방법들을 고려해볼 수 있습니다.**

- Lock을 통한 데이터 접근 동기화
- 원자적 연산을 사용
- 불변 데이터 구조 활용
- 테스트와 분석 도구 활용

## Golang에서 Thread Safe

Golang은 고루틴이라는 경량 쓰레드를 통해서 비동기 프로그램을 작성하게 됩니다. 전통적으로 쓰레드간의 통신은 공유 메모리를 통해서 많이들 이루어지는데 이때 Lock이나 Queue 등을 이용해서 메세지를 제어하는 방식으로도 코드를 작성합니다. 이렇게 되면 코드의 흐름이 복잡해지고 시간이 지날수록 관리하기 어려운 코드가 됩니다.

**Golang에서는 이를 해결하기 위해서 Channel을 활용합니다.**

> Do not communicate by sharing memory; instead, share memory by communicating

참조 : [https://go.dev/blog/codelab-share](https://go.dev/blog/codelab-share)

### Channel 예시

채널의 예시를 케이스별로 작성해 보겠습니다. 우선 간단하게 5개의 worker가 있고 각 worker는 1000번의 loop를 돌면서 counter를 1씩 증가시킵니다.

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	const numWorkers = 10
	const numNumbers = 10000

	// 채널 생성
	numberChannel := make(chan int)
	sumChannel := make(chan int)
	totalSum := 0

	// WaitGroup을 사용하여 모든 고루틴이 작업을 완료할 때까지 대기
	var wg sync.WaitGroup

	// 더하기 고루틴들 시작
	for i := 0; i < numWorkers; i++ {
		wg.Add(1)
		go func(id int) {
			defer wg.Done()
			sum := 0
			for num := range numberChannel {
				sum += num
			}

			sumChannel <- sum
			fmt.Printf("고루틴 %d: 합계 = %d\n", id, sum)
		}(i)
	}

	wg.Add(1)
	go func() {
		defer wg.Done()

		workerDoneCount := 0
		for sum := range sumChannel {
			totalSum += sum

			workerDoneCount++
			if workerDoneCount == numWorkers {
				close(sumChannel)
			}
		}
	}()

	// 숫자 전송
	for i := 1; i <= numNumbers; i++ {
		numberChannel <- i
	}

	// 모든 고루틴이 작업을 완료하고 채널을 닫음
	close(numberChannel)

	// 모든 고루틴의 작업이 완료될 때까지 대기
	wg.Wait()

	fmt.Printf("총합 ==> %d\n", totalSum)
}
```

**플로우**

1. **`numberChannel`** 채널로부터 각 고루틴은 숫자를 받아와 누적하여 합계를 계산합니다.
2. 합계가 계산된 고루틴은 **`sumChannel`** 채널을 통해 합계를 전송합니다.
3. 별도의 고루틴이 **`sumChannel`** 채널로부터 합계를 받아와서 총합을 계산합니다.
4. 모든 고루틴의 작업이 완료되면 **`sync.WaitGroup`**을 사용하여 대기하며, 메인 고루틴에서 총합을 출력합니다

채널을 통해서 각각에 비동기로 처리되는 작업들에 대해서 공유되는 총합이라는 공유자원에 대해서 동기화와 채널을 통해 실행을 제어하는 방식으로 안전하고 의도대로 작업을 수행할 수 있습니다.

하지만 채널도 한계는 있습니다. 채널의 패턴에 따라서 순서를 제어하기에 어려운 상황이 있을 수 있고 이럴 때는 Lock이나 원자적인 연산을 통해서 데이터 경쟁 (race condition)을 방지할 필요가 있습니다.

### 원자적 연산을 이용

Golang에서는 기본적으로 대부분의 연산들이 원자적 연산을 하지 않습니다. 예를 들어서 counter++ 연산도 읽고 데이터를 증가시킴으로 원자적이지 않습니다. 이를 위해서는 golang에서 제공하는 sync/atomic 패키지의 함수들을 이용해야만 합니다.

```go
package main

import (
	"fmt"
	"sync"
	"sync/atomic"
)

func main() {
	var counter int64
	var wg sync.WaitGroup

	for i := 0; i < 1000; i++ {
		wg.Add(1)
		go func() {
			atomic.AddInt64(&counter, 1)
			wg.Done()
		}()
	}

	wg.Wait()
	fmt.Println("Counter:", counter)
}
```

`atomic.AddInt64`  함수를 이용해서 해당 원자성을 보장합니다. 이를 통해서 여러 고루틴이 동시에 수행이 되더라도 문제없이 의도된 대로 1000값을 출력할 수 있습니다.

### Lock을 이용

Golang에서도 Lock을 선언해서 공유 자원에 대한 접근을 제어할 수 있습니다. 이 경우에는 Lock을 통해서 제어가 됨으로 위에 예제에서 사용했던 sync/atomic 패키지의 함수는 사용하지 않겠습니다.

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	var counter int64
	var mu sync.Mutex // 뮤텍스 선언

	var wg sync.WaitGroup

	for i := 0; i < 1000; i++ {
		wg.Add(1)
		go func() {
			mu.Lock()         // 뮤텍스 락 획득
			counter++         // 공유 변수 증가
			mu.Unlock()       // 뮤텍스 락 해제
			wg.Done()
		}()
	}

	wg.Wait()
	fmt.Println("Counter:", counter)
}
```

위에 결과도 동일하게 counter가 의도대로 1000이 나오는 것을 확인할 수 있습니다.

### race 옵션을 통해서 상세한 디버깅하기

Golang에서는 -race 옵션을 통해서 메모리에 동시에 읽거나 쓰는 부분이 있는지 리포트를 해주는 기능이 있습니다. 만약에 코드에서 데이터 경쟁(race condition)이 감지가 되면 아래처럼 리포팅 합니다.

```go
go run -race main.go

==================
WARNING: DATA RACE
Read at 0x00c000014108 by goroutine 8:
  main.main.func1()
      /path/to/yourprog.go:25 +0x3e

Previous write at 0x00c000014108 by goroutine 7:
  main.updateData()
      /path/to/yourprog.go:15 +0x2f

Goroutine 8 (running) created at:
  main.main()
      /path/to/yourprog.go:23 +0x86

Goroutine 7 (finished) created at:
  main.main()
      /path/to/yourprog.go:22 +0x68
==================
```

## 정리

해당 포스팅을 통해서 Thread Safe란 무엇인고 문제가 발생하는 상황과 이를 방지하기 위해서는 어떤 것들을 고려해야 하는지에 대해서 설명했습니다.

Golang 코드를 통해서 채널의 예시와 Thread Safe한 코드를 위해서 고려해 볼 수 있는 케이스와 예제들을 작성했는데 Thread Safe한 코드를 위해서는 어떤 것들을 고려해야 하는지에 대해서 이해하는데 많은 도움이 되었으면 좋겠습니다.