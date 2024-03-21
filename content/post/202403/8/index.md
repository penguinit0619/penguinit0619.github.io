+++
author = "penguinit"
title = "Golang 1.22에서 루프구문 개선"
date = "2024-03-21"
description = "오늘 포스팅에서는 Golang 1.22에서 for문 관련 개선사항들이 있었는데 어떤 개선들과 변경점이 있었는지 정리해보고자 합니다."
tags = [
"golang"
]
categories = [
"language"
]
+++

## 개요

오늘 포스팅에서는 Golang 1.22에서 반복문 관련 개선사항들이 있었는데 어떤 개선들과 변경점이 있었는지 정리해 보고자 합니다.

## 고루틴에서 반복문 변수 참조

아래는 반복문을 통해서 “a”, “b”, “c” 문자열을 순차대로 출력하기 위한 코드입니다. 다만 특이한 점은 반복문 내부에서 고루틴을 이용해서 출력하고 있고, 함수가 먼저 종료되어버리면 안되기 때문에 채널을 사용해서 기다려줍니다.

```go
package main

import "fmt"

func main() {
	done := make(chan bool)

	values := []string{"a", "b", "c"}
	for _, v := range values {
		go func() {
			fmt.Println(v)
			done <- true
		}()
	}

	// wait for all goroutines to complete before exiting
	for range values {
		<-done
	}
}
```

결과 : c값이 3번 출력
```go
$ go run main.go
c
c
c
```

하지만 결과는 예상과 다르게 마지막 값을 3번 출력하게 됩니다. 왜냐하면 고루틴이 반복문 마지막 변수를 참조해서 출력하기 때문에 이런 결과가 나오게 됩니다. 예전에 개발하면서 실제로 이런 케이스를 경험했어서 아래 처럼 우회해서 문제를 풀었습니다. 

```go
package main

import "fmt"

func main() {
	done := make(chan bool)

	values := []string{"a", "b", "c"}
	for _, v := range values {
		t := v

		go func() {
			fmt.Println(t)
			done <- true
		}()
	}

	// wait for all goroutines to complete before exiting
	for range values {
		<-done
	}
}
```

고루틴 내부에서 출력을 할 때 반복문 변수를 참조하는 게 아니라 해당 절 안에서 변수를 재할당해서 넘겨주는 형태로 잘못된 참조를 하는 것을 방지했습니다. 당시에는 이게 문제라고 생각하지는 않았고 비동기 프로그래밍에 있어서 주의해야 할 점 정도로 생각했던 것 같습니다. 

Golang 개발진도 이 문제를 이전부터 인지를 하고 있었고, 1.22 이후에 반복문에서의 참조를 명확하게 하게 하는 것으로 변경을 하였습니다. 즉 1.22 이후에는 반복문 내부에서 고루틴이 돌아가더라도 참조하는 변수는 변하지 않습니다!

**Golang 1.22 에서 수행**

```bash
$gvm use go1.22.0
$gvm list

gvm gos (installed)

   go1.21.0
=> go1.22.0
   system

$go run main.go
c
b
a
```

## 정수 반복문

이전에는 특정수만큼 반복해서 수행하려고 하면 Go에서는 아래처럼 작업을 했어야 했습니다. 

```go
package main

import "fmt"

func main() {
	for i := 0; i < 5; i++ {
		fmt.Println(i)
	}
}
```

하지만 1.22 부터는 아래 처럼 간단하게 단일 정수 값으로 반복문을 구현할 수 있습니다.  

```go
package main

import "fmt"

func main() {
	for i := range 5 {
		fmt.Println(i)
	}
}

```

## GOEXPERIMENT

`GOEXPERIMENT`는 Go 언어 개발자들이 새로운 기능이나 최적화를 실험적으로 테스트할 수 있게 하는 환경 변수입니다. Go 컴파일러와 런타임에서 다양한 실험적 기능을 활성화하거나 비활성화할 수 있도록 설계되었습니다. 이 기능은 주로 Go의 개발 과정에서 내부적으로 사용되며, 특정 기능의 성능 영향을 평가하거나 새로운 기능의 안정성을 테스트하는 데 유용합니다.

### rangefunc

1.22에서 rangefunc 이라는 기능을 내부적으로 사용할 수 있는데 함수를 재귀적으로 호출하는 형태로 함수 반복문을 구현하였습니다. 아래는 예시 코드입니다.

```go
package main

import (
	"fmt"
	"strings"
)

func Split(s string) func(func(int, string) bool) {
	parts := strings.Split(s, " ")
	return func(f func(int, string) bool) {
		for i, p := range parts {
			if !f(i, p) {
				break
			}
		}
	}
}

func main() {
	str := "hello my name is penguin"
	for i, x := range Split(str) {
		fmt.Println(i, x)
	}
}

```

```bash
GOEXPERIMENT=rangefunc go run main.go
0 hello
1 my
2 name
3 is
4 penguin
```

나름 재미있는 아이디어인데 개인적으로는 그렇게 매력적으로 보이지는 않아서… 무엇보다 Go 스럽지 않다고 생각이 들어서 별로인 것 같습니다. (개인적인 의견입니다)

## 정리

Golang 1.22 버전에서 반복문 관련해서 변경된 사항들을 예제 코드를 통해서 알아보았고 GOEXPERIMENT 변수와 1.22 버전에서 추가된 실험 기능을 하나(rangefunc)를 예시로 들어서 설명하였습니다.